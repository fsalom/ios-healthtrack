//
//  GetMealsUseCase.swift
//  HealthTrack
//

import Foundation

protocol GetMealsUseCaseProtocol {
    func execute(from startDate: Date, to endDate: Date) async throws -> [MealModel]
    func executeForDay(_ date: Date) async throws -> [MealModel]
}

final class GetMealsUseCase: GetMealsUseCaseProtocol {

    // MARK: - Properties

    private let repository: MealRepositoryProtocol

    // MARK: - Init

    init(repository: MealRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func execute(from startDate: Date, to endDate: Date) async throws -> [MealModel] {
        try await repository.getMeals(from: startDate, to: endDate)
    }

    func executeForDay(_ date: Date) async throws -> [MealModel] {
        try await repository.getMealsForDay(date)
    }
}
