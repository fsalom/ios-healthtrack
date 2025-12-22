//
//  SaveMealUseCase.swift
//  HealthTrack
//

import Foundation

protocol SaveMealUseCaseProtocol {
    func execute(_ meal: MealModel) async throws
}

final class SaveMealUseCase: SaveMealUseCaseProtocol {

    // MARK: - Properties

    private let repository: MealRepositoryProtocol

    // MARK: - Init

    init(repository: MealRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func execute(_ meal: MealModel) async throws {
        try await repository.saveMeal(meal)
    }
}
