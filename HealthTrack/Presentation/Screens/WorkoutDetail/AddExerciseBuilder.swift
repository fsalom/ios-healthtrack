//
//  AddExerciseBuilder.swift
//  HealthTrack
//

import Foundation

enum AddExerciseBuilder {
    static func build(onSave: @escaping (ExerciseModel) -> Void) -> AddExerciseView {
        let exerciseLibraryRepository = ExerciseLibraryRepository()
        let viewModel = AddExerciseViewModel(
            exerciseLibraryRepository: exerciseLibraryRepository,
            onSave: onSave
        )
        return AddExerciseView(viewModel: viewModel)
    }
}
