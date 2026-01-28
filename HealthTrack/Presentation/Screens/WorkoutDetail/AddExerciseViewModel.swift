//
//  AddExerciseViewModel.swift
//  HealthTrack
//

import Foundation

@Observable
final class AddExerciseViewModel {

    // MARK: - Properties

    var exerciseName: String = ""
    var sets: [SetModel] = []
    var currentReps: String = "10"
    var currentWeight: String = ""

    let onSave: (ExerciseModel) -> Void

    // MARK: - Computed Properties

    var canSave: Bool {
        !exerciseName.isEmpty && !sets.isEmpty
    }

    var exerciseSuggestions: [String] {
        [
            "Press banca",
            "Sentadilla",
            "Peso muerto",
            "Press militar",
            "Dominadas",
            "Remo",
            "Curl biceps",
            "Extension triceps",
            "Zancadas",
            "Hip thrust"
        ]
    }

    // MARK: - Init

    init(onSave: @escaping (ExerciseModel) -> Void) {
        self.onSave = onSave
    }

    // MARK: - Public Methods

    func selectSuggestion(_ suggestion: String) {
        exerciseName = suggestion
    }

    func addSet() {
        guard let reps = Int(currentReps), reps > 0 else { return }
        let weight = Double(currentWeight) ?? 0

        let set = SetModel(reps: reps, weight: weight)
        sets.append(set)
    }

    func removeSet(at index: Int) {
        guard index < sets.count else { return }
        sets.remove(at: index)
    }

    func clearSets() {
        sets.removeAll()
    }

    func setQuickWeight(_ weight: Int) {
        currentWeight = "\(weight)"
    }

    func saveExercise() {
        guard canSave else { return }
        let exercise = ExerciseModel(name: exerciseName, sets: sets)
        onSave(exercise)
    }
}
