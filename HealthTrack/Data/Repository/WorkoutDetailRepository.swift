//
//  WorkoutDetailRepository.swift
//  HealthTrack
//

import Foundation

final class WorkoutDetailRepository: WorkoutDetailRepositoryProtocol {

    private let userDefaults: UserDefaults
    private let storageKey = "workout_details_v1"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getDetail(for workoutId: UUID) async throws -> WorkoutDetailModel? {
        let allDetails = try await getAllDetails()
        return allDetails.first { $0.workoutId == workoutId }
    }

    func saveDetail(_ detail: WorkoutDetailModel) async throws {
        var allDetails = try await getAllDetails()

        // Remove existing detail for this workout if exists
        allDetails.removeAll { $0.workoutId == detail.workoutId }

        // Add the new/updated detail
        allDetails.append(detail)

        // Save
        let encoder = JSONEncoder()
        let data = try encoder.encode(allDetails)
        userDefaults.set(data, forKey: storageKey)
    }

    func deleteDetail(for workoutId: UUID) async throws {
        var allDetails = try await getAllDetails()
        allDetails.removeAll { $0.workoutId == workoutId }

        let encoder = JSONEncoder()
        let data = try encoder.encode(allDetails)
        userDefaults.set(data, forKey: storageKey)
    }

    func getAllDetails() async throws -> [WorkoutDetailModel] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }

        let decoder = JSONDecoder()
        return try decoder.decode([WorkoutDetailModel].self, from: data)
    }
}
