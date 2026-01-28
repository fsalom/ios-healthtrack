//
//  AddExerciseBuilder.swift
//  HealthTrack
//

import Foundation

enum AddExerciseBuilder {
    static func build(onSave: @escaping (ExerciseModel) -> Void) -> AddExerciseView {
        let viewModel = AddExerciseViewModel(onSave: onSave)
        return AddExerciseView(viewModel: viewModel)
    }
}
