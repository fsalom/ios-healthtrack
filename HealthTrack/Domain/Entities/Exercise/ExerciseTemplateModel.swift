//
//  ExerciseTemplateModel.swift
//  HealthTrack
//

import Foundation

struct ExerciseTemplateModel: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let muscleGroups: [MuscleGroup]
    let isCustom: Bool

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory,
        muscleGroups: [MuscleGroup],
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.muscleGroups = muscleGroups
        self.isCustom = isCustom
    }

    var primaryMuscle: MuscleGroup? {
        muscleGroups.first
    }
}
