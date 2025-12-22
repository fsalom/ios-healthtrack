//
//  FetchFoodInfoUseCase.swift
//  HealthTrack
//

import Foundation

protocol FetchFoodInfoUseCaseProtocol {
    func execute(barcode: String) async throws -> FoodItemModel?
}

final class FetchFoodInfoUseCase: FetchFoodInfoUseCaseProtocol {

    // MARK: - Properties

    private let repository: MealRepositoryProtocol

    // MARK: - Init

    init(repository: MealRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func execute(barcode: String) async throws -> FoodItemModel? {
        try await repository.fetchFoodInfo(barcode: barcode)
    }
}
