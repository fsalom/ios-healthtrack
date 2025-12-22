//
//  MealLocalDataSource.swift
//  HealthTrack
//

import Foundation

final class MealLocalDataSource: MealLocalDataSourceProtocol {

    // MARK: - Properties

    private let userDefaults: UserDefaults
    private let storageKey = "com.healthtrack.meals"

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public Methods

    func saveMeal(_ meal: MealDTO) throws {
        var meals = try getMeals()

        // Check if meal already exists (update) or is new (append)
        if let index = meals.firstIndex(where: { $0.id == meal.id }) {
            meals[index] = meal
        } else {
            meals.append(meal)
        }

        try saveMeals(meals)
    }

    func getMeals() throws -> [MealDTO] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode([MealDTO].self, from: data)
        } catch {
            throw MealStorageError.decodingFailed
        }
    }

    func deleteMeal(_ mealId: String) throws {
        var meals = try getMeals()
        meals.removeAll { $0.id == mealId }
        try saveMeals(meals)
    }

    // MARK: - Private Methods

    private func saveMeals(_ meals: [MealDTO]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(meals)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            throw MealStorageError.encodingFailed
        }
    }
}

// MARK: - Errors

enum MealStorageError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Error al guardar la comida"
        case .decodingFailed:
            return "Error al leer las comidas guardadas"
        }
    }
}
