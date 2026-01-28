//
//  HealthKitManager.swift
//  HealthTrack
//

import Foundation
import HealthKit

final class HealthKitManager: HealthKitManagerProtocol {

    // MARK: - Properties

    private let healthStore = HKHealthStore()

    private let typesToRead: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.distanceWalkingRunning),
        HKQuantityType(.distanceCycling),
        HKQuantityType(.distanceSwimming),
        HKQuantityType(.heartRate),
        HKQuantityType(.runningSpeed),
        HKWorkoutType.workoutType()
    ]

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    var isAuthorized: Bool {
        guard isAvailable else { return false }
        let stepType = HKQuantityType(.stepCount)
        return healthStore.authorizationStatus(for: stepType) == .sharingAuthorized
    }

    // MARK: - Public Methods

    func requestAuthorization() async throws {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }

    func fetchHourlySteps(from startDate: Date, to endDate: Date) async throws -> [HourlyActivityModel] {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        let stepType = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let interval = DateComponents(hour: 1)
        let anchorDate = Calendar.current.startOfDay(for: startDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = results else {
                    continuation.resume(returning: [])
                    return
                }

                var hourlyData: [HourlyActivityModel] = []

                results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    let steps = Int(statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    let model = HourlyActivityModel(
                        hour: statistics.startDate,
                        steps: steps
                    )
                    hourlyData.append(model)
                }

                continuation.resume(returning: hourlyData)
            }

            healthStore.execute(query)
        }
    }

    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [WorkoutModel] {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let workouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: [])
                    return
                }

                continuation.resume(returning: workouts)
            }

            healthStore.execute(query)
        }

        // Convert HKWorkouts to WorkoutModels with extended data
        var models: [WorkoutModel] = []
        for workout in workouts {
            let model = await createWorkoutModel(from: workout)
            models.append(model)
        }

        return models
    }

    private func createWorkoutModel(from workout: HKWorkout) async -> WorkoutModel {
        let workoutType = mapWorkoutType(workout.workoutActivityType)

        // Get distance based on workout type
        var distance: Double?
        if let totalDistance = workout.totalDistance {
            distance = totalDistance.doubleValue(for: .meter())
        }

        // Calculate average pace for running/walking
        var averagePace: Double?
        if let dist = distance, dist > 0, workout.duration > 0 {
            // Pace in seconds per kilometer
            let distanceInKm = dist / 1000
            averagePace = workout.duration / distanceInKm
        }

        // Fetch heart rate data for this workout
        let heartRateData = await fetchHeartRateForWorkout(workout)

        return WorkoutModel(
            id: UUID(),
            type: workoutType,
            startDate: workout.startDate,
            endDate: workout.endDate,
            duration: workout.duration,
            activeCalories: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
            distance: distance,
            averageHeartRate: heartRateData.average,
            maxHeartRate: heartRateData.max,
            averagePace: averagePace,
            elevationGain: nil // Would need workout route data
        )
    }

    private func fetchHeartRateForWorkout(_ workout: HKWorkout) async -> (average: Double?, max: Double?) {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: [.discreteAverage, .discreteMax]
            ) { _, statistics, _ in
                let avgHR = statistics?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                let maxHR = statistics?.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: (avgHR, maxHR))
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - Private Methods

    private func mapWorkoutType(_ hkType: HKWorkoutActivityType) -> WorkoutType {
        switch hkType {
        case .running: return .running
        case .walking: return .walking
        case .cycling: return .cycling
        case .swimming: return .swimming
        case .hiking: return .hiking
        case .yoga: return .yoga
        case .functionalStrengthTraining, .traditionalStrengthTraining: return .strengthTraining
        case .highIntensityIntervalTraining: return .hiit
        case .elliptical: return .elliptical
        case .rowing: return .rowing
        case .stairClimbing: return .stairClimbing
        case .dance: return .dance
        case .pilates: return .pilates
        case .crossTraining: return .crossTraining
        default: return .other
        }
    }
}

// MARK: - Errors

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case notAuthorized
    case queryFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit no está disponible en este dispositivo"
        case .notAuthorized:
            return "No se han concedido permisos para acceder a HealthKit"
        case .queryFailed:
            return "Error al consultar datos de HealthKit"
        }
    }
}
