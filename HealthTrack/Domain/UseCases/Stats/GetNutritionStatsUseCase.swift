//
//  GetNutritionStatsUseCase.swift
//  HealthTrack
//

import Foundation

protocol GetNutritionStatsUseCaseProtocol {
    func execute() async throws -> NutritionStatsModel
}

final class GetNutritionStatsUseCase: GetNutritionStatsUseCaseProtocol {

    // MARK: - Properties

    private let mealRepository: MealRepositoryProtocol
    private let healthKitManager: HealthKitManagerProtocol
    private let basalMetabolicRate: Double

    // MARK: - Init

    init(
        mealRepository: MealRepositoryProtocol,
        healthKitManager: HealthKitManagerProtocol,
        basalMetabolicRate: Double = 1800 // Default BMR estimate
    ) {
        self.mealRepository = mealRepository
        self.healthKitManager = healthKitManager
        self.basalMetabolicRate = basalMetabolicRate
    }

    // MARK: - Public Methods

    func execute() async throws -> NutritionStatsModel {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)

        guard let startOfWeek = calendar.date(byAdding: .day, value: -6, to: today),
              let endOfDay = calendar.date(byAdding: .day, value: 1, to: today) else {
            return .empty
        }

        async let todayMeals = mealRepository.getMealsForDay(today)
        async let weekMeals = mealRepository.getMeals(from: startOfWeek, to: endOfDay)
        async let workouts = healthKitManager.fetchWorkouts(from: today, to: endOfDay)

        let (todayMealsList, weekMealsList, todayWorkouts) = try await (todayMeals, weekMeals, workouts)

        let todayBalance = calculateTodayBalance(meals: todayMealsList, workouts: todayWorkouts)
        let todayMacros = calculateTodayMacros(meals: todayMealsList)
        let weeklyCalories = calculateWeeklyCalories(meals: weekMealsList)

        return NutritionStatsModel(
            todayBalance: todayBalance,
            todayMacros: todayMacros,
            weeklyCaloriesConsumed: weeklyCalories
        )
    }

    // MARK: - Private Methods

    private func calculateTodayBalance(
        meals: [MealModel],
        workouts: [WorkoutModel]
    ) -> NutritionStatsModel.EnergyBalance {
        let consumed = meals.reduce(0.0) { $0 + $1.totalNutrition.calories }
        let activeCalories = workouts.reduce(0.0) { $0 + $1.activeCalories }
        let totalBurned = basalMetabolicRate + activeCalories

        return NutritionStatsModel.EnergyBalance(
            consumed: consumed,
            burned: totalBurned
        )
    }

    private func calculateTodayMacros(meals: [MealModel]) -> NutritionStatsModel.MacroDistribution {
        let totalNutrition = meals.reduce(NutritionInfoModel.empty) { result, meal in
            result + meal.totalNutrition
        }

        return NutritionStatsModel.MacroDistribution(
            carbohydrates: totalNutrition.carbohydrates,
            proteins: totalNutrition.proteins,
            fats: totalNutrition.fats
        )
    }

    private func calculateWeeklyCalories(meals: [MealModel]) -> [NutritionStatsModel.DailyCaloriesConsumed] {
        let calendar = Calendar.current

        var caloriesPerDay: [Date: Double] = [:]

        for meal in meals {
            let dayStart = calendar.startOfDay(for: meal.timestamp)
            caloriesPerDay[dayStart, default: 0] += meal.totalNutrition.calories
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
                NutritionStatsModel.DailyCaloriesConsumed(date: date, calories: calories)
            }
            .sorted { $0.date < $1.date }
    }
}
