//
//  MealLocalDataSourceProtocol.swift
//  HealthTrack
//

import Foundation

protocol MealLocalDataSourceProtocol {
    func saveMeal(_ meal: MealDTO) throws
    func getMeals() throws -> [MealDTO]
    func deleteMeal(_ mealId: String) throws
}
