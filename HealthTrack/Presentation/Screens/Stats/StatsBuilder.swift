//
//  StatsBuilder.swift
//  HealthTrack
//

import Foundation

enum StatsBuilder {
    static func build(router: Router = Router()) -> StatsView {
        // Repositories
        let workoutDetailRepository = WorkoutDetailRepository()
        let exerciseLibraryRepository = ExerciseLibraryRepository()
        let mealRepository = MealRepository()
        let healthKitManager = HealthKitManager()

        // Use Cases
        let getStrengthStatsUseCase = GetStrengthStatsUseCase(
            workoutDetailRepository: workoutDetailRepository,
            exerciseLibraryRepository: exerciseLibraryRepository
        )

        let getActivityStatsUseCase = GetActivityStatsUseCase(
            healthKitManager: healthKitManager
        )

        let getNutritionStatsUseCase = GetNutritionStatsUseCase(
            mealRepository: mealRepository,
            healthKitManager: healthKitManager
        )

        // ViewModel
        let viewModel = StatsViewModel(
            router: router,
            getStrengthStatsUseCase: getStrengthStatsUseCase,
            getActivityStatsUseCase: getActivityStatsUseCase,
            getNutritionStatsUseCase: getNutritionStatsUseCase
        )

        return StatsView(viewModel: viewModel)
    }
}
