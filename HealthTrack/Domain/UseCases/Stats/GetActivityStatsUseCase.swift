//
//  GetActivityStatsUseCase.swift
//  HealthTrack
//

import Foundation

protocol GetActivityStatsUseCaseProtocol {
    func execute() async throws -> ActivityStatsModel
}

final class GetActivityStatsUseCase: GetActivityStatsUseCaseProtocol {

    // MARK: - Properties

    private let healthKitManager: HealthKitManagerProtocol

    // MARK: - Init

    init(healthKitManager: HealthKitManagerProtocol) {
        self.healthKitManager = healthKitManager
    }

    // MARK: - Public Methods

    func execute() async throws -> ActivityStatsModel {
        let calendar = Calendar.current
        let now = Date()

        guard let startOfWeek = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)),
              let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) else {
            return .empty
        }

        async let hourlySteps = healthKitManager.fetchHourlySteps(from: startOfWeek, to: endOfDay)
        async let workouts = healthKitManager.fetchWorkouts(from: startOfWeek, to: endOfDay)

        let (steps, workoutList) = try await (hourlySteps, workouts)

        let dailySteps = aggregateDailySteps(from: steps)
        let dailyCalories = calculateDailyCalories(from: workoutList)
        let totalDuration = workoutList.reduce(0.0) { $0 + $1.duration }

        return ActivityStatsModel(
            dailySteps: dailySteps,
            dailyCaloriesBurned: dailyCalories,
            workoutCount: workoutList.count,
            totalWorkoutDuration: totalDuration
        )
    }

    // MARK: - Private Methods

    private func aggregateDailySteps(from hourlySteps: [HourlyActivityModel]) -> [ActivityStatsModel.DailySteps] {
        let calendar = Calendar.current

        var stepsPerDay: [Date: Int] = [:]

        for hourlyData in hourlySteps {
            let dayStart = calendar.startOfDay(for: hourlyData.hour)
            stepsPerDay[dayStart, default: 0] += hourlyData.steps
        }

        return stepsPerDay
            .map { date, steps in
                ActivityStatsModel.DailySteps(date: date, steps: steps)
            }
            .sorted { $0.date < $1.date }
    }

    private func calculateDailyCalories(from workouts: [WorkoutModel]) -> [ActivityStatsModel.DailyCalories] {
        let calendar = Calendar.current

        var caloriesPerDay: [Date: Double] = [:]

        for workout in workouts {
            let dayStart = calendar.startOfDay(for: workout.startDate)
            caloriesPerDay[dayStart, default: 0] += workout.activeCalories
        }

        // Fill in missing days with 0
        let now = Date()
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: calendar.startOfDay(for: now)) {
                if caloriesPerDay[date] == nil {
                    caloriesPerDay[date] = 0
                }
            }
        }

        return caloriesPerDay
            .map { date, calories in
                ActivityStatsModel.DailyCalories(date: date, calories: calories)
            }
            .sorted { $0.date < $1.date }
    }
}
