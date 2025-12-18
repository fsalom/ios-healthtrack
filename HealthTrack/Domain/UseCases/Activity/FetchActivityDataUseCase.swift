//
//  FetchActivityDataUseCase.swift
//  HealthTrack
//

import Foundation

protocol FetchActivityDataUseCaseProtocol {
    func requestAuthorization() async throws
    func execute(from startDate: Date, to endDate: Date) async throws -> ActivityData
}

struct ActivityData {
    let hourlySteps: [HourlyActivityModel]
    let workouts: [WorkoutModel]

    static let empty = ActivityData(hourlySteps: [], workouts: [])
}

final class FetchActivityDataUseCase: FetchActivityDataUseCaseProtocol {

    // MARK: - Properties

    private let healthKitManager: HealthKitManagerProtocol

    // MARK: - Init

    init(healthKitManager: HealthKitManagerProtocol = HealthKitManager()) {
        self.healthKitManager = healthKitManager
    }

    // MARK: - Public Methods

    func requestAuthorization() async throws {
        try await healthKitManager.requestAuthorization()
    }

    func execute(from startDate: Date, to endDate: Date) async throws -> ActivityData {
        async let hourlySteps = healthKitManager.fetchHourlySteps(from: startDate, to: endDate)
        async let workouts = healthKitManager.fetchWorkouts(from: startDate, to: endDate)

        let (steps, workoutList) = try await (hourlySteps, workouts)

        // Enrich hourly data with workout information
        let enrichedSteps = enrichWithWorkouts(hourlySteps: steps, workouts: workoutList)

        return ActivityData(hourlySteps: enrichedSteps, workouts: workoutList)
    }

    // MARK: - Private Methods

    private func enrichWithWorkouts(hourlySteps: [HourlyActivityModel], workouts: [WorkoutModel]) -> [HourlyActivityModel] {
        hourlySteps.map { hourlyData in
            let calendar = Calendar.current
            let hourEnd = calendar.date(byAdding: .hour, value: 1, to: hourlyData.hour) ?? hourlyData.hour

            // Find workout that overlaps with this hour
            let overlappingWorkout = workouts.first { workout in
                workout.startDate < hourEnd && workout.endDate > hourlyData.hour
            }

            if let workout = overlappingWorkout {
                return HourlyActivityModel(
                    id: hourlyData.id,
                    hour: hourlyData.hour,
                    steps: hourlyData.steps,
                    hasWorkout: true,
                    workoutType: workout.displayName
                )
            }

            return hourlyData
        }
    }
}
