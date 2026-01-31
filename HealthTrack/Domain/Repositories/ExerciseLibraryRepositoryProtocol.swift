//
//  ExerciseLibraryRepositoryProtocol.swift
//  HealthTrack
//

import Foundation

protocol ExerciseLibraryRepositoryProtocol {
    // Templates
    func getAllTemplates() async throws -> [ExerciseTemplateModel]
    func getTemplates(for category: ExerciseCategory) async throws -> [ExerciseTemplateModel]
    func searchTemplates(query: String) async throws -> [ExerciseTemplateModel]

    // Custom exercises
    func saveCustomTemplate(_ template: ExerciseTemplateModel) async throws
    func deleteCustomTemplate(id: UUID) async throws

    // History
    func getHistory() async throws -> [ExerciseHistoryModel]
    func getRecentExercises(limit: Int) async throws -> [ExerciseHistoryModel]
    func getMostUsedExercises(limit: Int) async throws -> [ExerciseHistoryModel]
    func updateHistory(for templateId: UUID, exerciseName: String, weight: Double?, reps: Int?) async throws
}
