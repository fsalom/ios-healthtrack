//
//  NutritionStatsModel.swift
//  HealthTrack
//

import Foundation

struct NutritionStatsModel: Equatable {

    // MARK: - Nested Types

    struct EnergyBalance: Equatable {
        let consumed: Double
        let burned: Double

        var deficit: Double {
            consumed - burned
        }

        var isDeficit: Bool {
            deficit < 0
        }

        var formattedConsumed: String {
            "\(Int(consumed)) kcal"
        }

        var formattedBurned: String {
            "\(Int(burned)) kcal"
        }

        var formattedDeficit: String {
            let sign = deficit >= 0 ? "+" : ""
            return "\(sign)\(Int(deficit)) kcal"
        }

        static let empty = EnergyBalance(consumed: 0, burned: 0)
    }

    struct MacroDistribution: Equatable {
        let carbohydrates: Double
        let proteins: Double
        let fats: Double

        var total: Double {
            carbohydrates + proteins + fats
        }

        var carbsPercentage: Int {
            guard total > 0 else { return 0 }
            return Int((carbohydrates / total) * 100)
        }

        var proteinsPercentage: Int {
            guard total > 0 else { return 0 }
            return Int((proteins / total) * 100)
        }

        var fatsPercentage: Int {
            guard total > 0 else { return 0 }
            return Int((fats / total) * 100)
        }

        var formattedCarbs: String {
            "\(Int(carbohydrates))g"
        }

        var formattedProteins: String {
            "\(Int(proteins))g"
        }

        var formattedFats: String {
            "\(Int(fats))g"
        }

        static let empty = MacroDistribution(carbohydrates: 0, proteins: 0, fats: 0)
    }

    struct DailyCaloriesConsumed: Identifiable, Equatable {
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

    let todayBalance: EnergyBalance
    let todayMacros: MacroDistribution
    let weeklyCaloriesConsumed: [DailyCaloriesConsumed]

    // MARK: - Computed Properties

    var averageCaloriesPerDay: Double {
        guard !weeklyCaloriesConsumed.isEmpty else { return 0 }
        let total = weeklyCaloriesConsumed.reduce(0) { $0 + $1.calories }
        return total / Double(weeklyCaloriesConsumed.count)
    }

    var formattedAverageCalories: String {
        "\(Int(averageCaloriesPerDay)) kcal"
    }

    // MARK: - Static

    static let empty = NutritionStatsModel(
        todayBalance: .empty,
        todayMacros: .empty,
        weeklyCaloriesConsumed: []
    )
}
