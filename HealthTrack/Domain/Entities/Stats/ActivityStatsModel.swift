//
//  ActivityStatsModel.swift
//  HealthTrack
//

import Foundation

struct ActivityStatsModel: Equatable {

    // MARK: - Nested Types

    struct DailySteps: Identifiable, Equatable {
        let id: UUID
        let date: Date
        let steps: Int

        init(id: UUID = UUID(), date: Date, steps: Int) {
            self.id = id
            self.date = date
            self.steps = steps
        }

        var formattedSteps: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
        }

        var dayLabel: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            formatter.locale = Locale(identifier: "es_ES")
            return formatter.string(from: date)
        }
    }

    struct DailyCalories: Identifiable, Equatable {
        let id: UUID
        let date: Date
        let calories: Double

        init(id: UUID = UUID(), date: Date, calories: Double) {
            self.id = id
            self.date = date
            self.calories = calories
        }

        var formattedCalories: String {
            "\(Int(calories)) kcal"
        }

        var dayLabel: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            formatter.locale = Locale(identifier: "es_ES")
            return formatter.string(from: date)
        }
    }

    // MARK: - Properties

    let dailySteps: [DailySteps]
    let dailyCaloriesBurned: [DailyCalories]
    let workoutCount: Int
    let totalWorkoutDuration: TimeInterval

    // MARK: - Computed Properties

    var totalStepsThisWeek: Int {
        dailySteps.reduce(0) { $0 + $1.steps }
    }

    var averageStepsPerDay: Int {
        guard !dailySteps.isEmpty else { return 0 }
        return totalStepsThisWeek / dailySteps.count
    }

    var totalCaloriesBurnedThisWeek: Double {
        dailyCaloriesBurned.reduce(0) { $0 + $1.calories }
    }

    var averageCaloriesPerDay: Double {
        guard !dailyCaloriesBurned.isEmpty else { return 0 }
        return totalCaloriesBurnedThisWeek / Double(dailyCaloriesBurned.count)
    }

    var formattedTotalSteps: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalStepsThisWeek)) ?? "\(totalStepsThisWeek)"
    }

    var formattedAverageSteps: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: averageStepsPerDay)) ?? "\(averageStepsPerDay)"
    }

    var formattedTotalCalories: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: Int(totalCaloriesBurnedThisWeek))) ?? "\(Int(totalCaloriesBurnedThisWeek))") kcal"
    }

    var formattedAverageCalories: String {
        "\(Int(averageCaloriesPerDay)) kcal"
    }

    var formattedWorkoutDuration: String {
        let hours = Int(totalWorkoutDuration) / 3600
        let minutes = (Int(totalWorkoutDuration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        }
        return "\(minutes) min"
    }

    // MARK: - Static

    static let empty = ActivityStatsModel(
        dailySteps: [],
        dailyCaloriesBurned: [],
        workoutCount: 0,
        totalWorkoutDuration: 0
    )
}
