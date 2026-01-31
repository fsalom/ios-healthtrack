//
//  MealsViewModel.swift
//  HealthTrack
//

import Foundation

@Observable
final class MealsViewModel {

    // MARK: - Properties

    private(set) var todayMeals: [MealModel] = []
    private(set) var isLoading: Bool = false

    var showingAddMeal: Bool = false

    private let router: Router
    private let getMealsUseCase: GetMealsUseCaseProtocol

    // MARK: - Computed Properties

    var todayCalories: Double {
        todayMeals.reduce(0) { $0 + $1.totalNutrition.calories }
    }

    var todayProtein: Double {
        todayMeals.reduce(0) { $0 + $1.totalNutrition.proteins }
    }

    var todayCarbs: Double {
        todayMeals.reduce(0) { $0 + $1.totalNutrition.carbohydrates }
    }

    var todayFat: Double {
        todayMeals.reduce(0) { $0 + $1.totalNutrition.fats }
    }

    // MARK: - Init

    init(
        router: Router,
        getMealsUseCase: GetMealsUseCaseProtocol
    ) {
        self.router = router
        self.getMealsUseCase = getMealsUseCase
    }

    // MARK: - Public Methods

    @MainActor
    func loadData() async {
        isLoading = true

        do {
            todayMeals = try await getMealsUseCase.executeForDay(Date())
        } catch {
            print("Error loading meals: \(error)")
        }

        isLoading = false
    }

    func didTapAddMeal() {
        showingAddMeal = true
    }

    func didTapQuickAdd(mealName: String) {
        // For now, just open the add meal sheet
        // Could pre-populate the meal name
        showingAddMeal = true
    }

    @MainActor
    func addMeal(_ meal: MealModel) {
        todayMeals.insert(meal, at: 0)
    }
}
