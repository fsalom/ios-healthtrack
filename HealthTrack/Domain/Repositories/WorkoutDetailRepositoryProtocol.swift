//
//  WorkoutDetailRepositoryProtocol.swift
//  HealthTrack
//

import Foundation

protocol WorkoutDetailRepositoryProtocol {
    func getDetail(for workoutId: UUID) async throws -> WorkoutDetailModel?
    func saveDetail(_ detail: WorkoutDetailModel) async throws
    func deleteDetail(for workoutId: UUID) async throws
    func getAllDetails() async throws -> [WorkoutDetailModel]
}
