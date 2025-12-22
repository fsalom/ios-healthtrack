//
//  MealRepositoryProtocol.swift
//  HealthTrack
//

import Foundation

protocol MealRepositoryProtocol {
    /// Saves a meal to persistent storage
    func saveMeal(_ meal: MealModel) async throws

    /// Retrieves all meals within a date range
    func getMeals(from startDate: Date, to endDate: Date) async throws -> [MealModel]

    /// Retrieves all meals for a specific day
    func getMealsForDay(_ date: Date) async throws -> [MealModel]

    /// Deletes a meal by its ID
    func deleteMeal(_ mealId: UUID) async throws

    /// Fetches food info from Open Food Facts API by barcode
    func fetchFoodInfo(barcode: String) async throws -> FoodItemModel?
}
