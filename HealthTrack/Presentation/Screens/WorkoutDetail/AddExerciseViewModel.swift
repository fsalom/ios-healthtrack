//
//  AddExerciseViewModel.swift
//  HealthTrack
//

import Foundation

@Observable
final class AddExerciseViewModel {

    // MARK: - Properties

    // Exercise selection
    var selectedTemplate: ExerciseTemplateModel?
    var exerciseName: String = ""
    var searchQuery: String = ""
    var selectedCategory: ExerciseCategory?
    private(set) var allExercises: [ExerciseTemplateModel] = []
    private(set) var recentExercises: [ExerciseHistoryModel] = []

    // Set entry
    var sets: [SetModel] = []
    var currentReps: String = ""
    var currentWeight: String = ""
    var currentIsWarmup: Bool = false
    var currentNotes: String = ""

    // Batch entry
    var showBatchEntry: Bool = false
    var batchSetCount: Int = 3
    var batchReps: String = "10"
    var batchWeight: String = ""

    // Inline editing
    var editingSetId: UUID?

    // History suggestions
    private(set) var previousWeight: Double?
    private(set) var previousReps: Int?

    // State
    private(set) var isLoading: Bool = false

    // Dependencies
    private let exerciseLibraryRepository: ExerciseLibraryRepositoryProtocol
    private let onSave: (ExerciseModel) -> Void

    // MARK: - Computed Properties

    var canSave: Bool {
        !exerciseName.isEmpty && !sets.isEmpty
    }

    var lastSet: SetModel? {
        sets.last
    }

    var hasSelectedExercise: Bool {
        !exerciseName.isEmpty
    }

    var filteredExercises: [ExerciseTemplateModel] {
        var result = allExercises

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        // Sort: recent first, then alphabetically
        let recentIds = Set(recentExercises.map { $0.templateId })
        result.sort { ex1, ex2 in
            let ex1Recent = recentIds.contains(ex1.id)
            let ex2Recent = recentIds.contains(ex2.id)

            if ex1Recent && !ex2Recent { return true }
            if !ex1Recent && ex2Recent { return false }
            return ex1.name < ex2.name
        }

        return result
    }

    // MARK: - Init

    init(
        exerciseLibraryRepository: ExerciseLibraryRepositoryProtocol,
        onSave: @escaping (ExerciseModel) -> Void
    ) {
        self.exerciseLibraryRepository = exerciseLibraryRepository
        self.onSave = onSave
    }

    // MARK: - Public Methods

    @MainActor
    func loadExercises() async {
        isLoading = true
        do {
            allExercises = try await exerciseLibraryRepository.getAllTemplates()
            recentExercises = try await exerciseLibraryRepository.getRecentExercises(limit: 5)
        } catch {
            print("Error loading exercises: \(error)")
        }
        isLoading = false
    }

    func selectExercise(_ template: ExerciseTemplateModel) {
        selectedTemplate = template
        exerciseName = template.name

        // Load previous weight/reps
        if let history = recentExercises.first(where: { $0.templateId == template.id }) {
            previousWeight = history.lastWeight
            previousReps = history.lastReps
        } else {
            previousWeight = nil
            previousReps = nil
        }
    }

    func clearSelection() {
        selectedTemplate = nil
        exerciseName = ""
        sets = []
        previousWeight = nil
        previousReps = nil
        searchQuery = ""
        selectedCategory = nil
    }

    func addSet() {
        let repsValue: Int
        if currentReps.isEmpty {
            repsValue = previousReps ?? 10
        } else {
            guard let parsed = Int(currentReps), parsed > 0 else { return }
            repsValue = parsed
        }

        let weightValue: Double
        if currentWeight.isEmpty {
            weightValue = previousWeight ?? 0
        } else {
            weightValue = Double(currentWeight) ?? 0
        }

        let set = SetModel(
            reps: repsValue,
            weight: weightValue,
            isWarmup: currentIsWarmup,
            notes: currentNotes.isEmpty ? nil : currentNotes
        )
        sets.append(set)

        // Clear for next entry (keep weight for convenience)
        currentReps = ""
        currentIsWarmup = false
        currentNotes = ""
    }

    func duplicateLastSet() {
        guard let lastSet = sets.last else { return }
        let newSet = SetModel(
            reps: lastSet.reps,
            weight: lastSet.weight,
            isWarmup: false,
            notes: nil
        )
        sets.append(newSet)
    }

    func addBatchSets() {
        guard let reps = Int(batchReps), reps > 0 else { return }
        let weight = Double(batchWeight) ?? 0

        for _ in 0..<batchSetCount {
            let set = SetModel(reps: reps, weight: weight)
            sets.append(set)
        }

        showBatchEntry = false
        batchSetCount = 3
        batchReps = "10"
        batchWeight = ""
    }

    func startEditingSet(_ set: SetModel) {
        editingSetId = set.id
    }

    func cancelEditing() {
        editingSetId = nil
    }

    func updateSet(_ updatedSet: SetModel) {
        if let index = sets.firstIndex(where: { $0.id == updatedSet.id }) {
            sets[index] = updatedSet
        }
        editingSetId = nil
    }

    func removeSet(at index: Int) {
        guard index < sets.count else { return }
        sets.remove(at: index)
    }

    func removeSet(_ set: SetModel) {
        sets.removeAll { $0.id == set.id }
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

        // Update history
        if let template = selectedTemplate, let lastSet = sets.last {
            Task {
                try? await exerciseLibraryRepository.updateHistory(
                    for: template.id,
                    exerciseName: template.name,
                    weight: lastSet.weight,
                    reps: lastSet.reps
                )
            }
        }

        onSave(exercise)
    }
}
