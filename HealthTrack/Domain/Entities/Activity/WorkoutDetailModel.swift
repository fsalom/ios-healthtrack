//
//  WorkoutDetailModel.swift
//  HealthTrack
//

import Foundation

struct WorkoutDetailModel: Identifiable, Equatable, Codable {
    let id: UUID
    let workoutId: UUID // Links to WorkoutModel
    var exercises: [ExerciseModel]
    var notes: String?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        workoutId: UUID,
        exercises: [ExerciseModel] = [],
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.workoutId = workoutId
        self.exercises = exercises
        self.notes = notes
        self.createdAt = createdAt
    }

    var totalExercises: Int {
        exercises.count
    }

    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }

    var formattedVolume: String {
        if totalVolume >= 1000 {
            return String(format: "%.1f t", totalVolume / 1000)
        }
        return "\(Int(totalVolume)) kg"
    }
}
