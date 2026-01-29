//
//  ExerciseHistoryModel.swift
//  HealthTrack
//

import Foundation

struct ExerciseHistoryModel: Identifiable, Equatable, Codable {
    let id: UUID
    let templateId: UUID
    let exerciseName: String
    var lastUsedDate: Date
    var useCount: Int
    var lastWeight: Double?
    var lastReps: Int?

    init(
        id: UUID = UUID(),
        templateId: UUID,
        exerciseName: String,
        lastUsedDate: Date = Date(),
        useCount: Int = 1,
        lastWeight: Double? = nil,
        lastReps: Int? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.exerciseName = exerciseName
        self.lastUsedDate = lastUsedDate
        self.useCount = useCount
        self.lastWeight = lastWeight
        self.lastReps = lastReps
    }

    var formattedLastWeight: String? {
        guard let weight = lastWeight, weight > 0 else { return nil }
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(weight))kg"
        }
        return String(format: "%.1fkg", weight)
    }
}
