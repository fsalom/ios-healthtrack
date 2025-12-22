//
//  MealRepository.swift
//  HealthTrack
//

import Foundation

final class MealRepository: MealRepositoryProtocol {

    // MARK: - Properties

    private let localDataSource: MealLocalDataSourceProtocol
    private let remoteApi: OpenFoodFactsApiProtocol

    // MARK: - Init

    init(
        localDataSource: MealLocalDataSourceProtocol = MealLocalDataSource(),
        remoteApi: OpenFoodFactsApiProtocol = OpenFoodFactsApi()
    ) {
        self.localDataSource = localDataSource
        self.remoteApi = remoteApi
    }

    // MARK: - Public Methods

    func saveMeal(_ meal: MealModel) async throws {
        do {
            let dto = MealDTO.fromDomain(meal)
            try localDataSource.saveMeal(dto)
        } catch {
            throw mapError(error)
        }
    }

    func getMeals(from startDate: Date, to endDate: Date) async throws -> [MealModel] {
        do {
            let allMeals = try localDataSource.getMeals()
            return allMeals
                .map { $0.toDomain() }
                .filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
                .sorted { $0.timestamp > $1.timestamp }
        } catch {
            throw mapError(error)
        }
    }

    func getMealsForDay(_ date: Date) async throws -> [MealModel] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        return try await getMeals(from: startOfDay, to: endOfDay)
    }

    func deleteMeal(_ mealId: UUID) async throws {
        do {
            try localDataSource.deleteMeal(mealId.uuidString)
        } catch {
            throw mapError(error)
        }
    }

    func fetchFoodInfo(barcode: String) async throws -> FoodItemModel? {
        do {
            guard let product = try await remoteApi.fetchProduct(barcode: barcode) else {
                return nil
            }
            return product.toDomain(barcode: barcode)
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Private Methods

    private func mapError(_ error: Error) -> AppError {
        if let storageError = error as? MealStorageError {
            return AppError.customError(storageError.localizedDescription, nil)
        }
        if let apiError = error as? OpenFoodFactsError {
            return AppError.customError(apiError.localizedDescription, nil)
        }
        if (error as NSError).domain == NSURLErrorDomain {
            return AppError.noInternet
        }
        return AppError.generalError
    }
}
