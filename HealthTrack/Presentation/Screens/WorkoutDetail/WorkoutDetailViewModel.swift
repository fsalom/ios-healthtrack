//
//  WorkoutDetailViewModel.swift
//  HealthTrack
//

import Foundation

@Observable
final class WorkoutDetailViewModel {

    // MARK: - Properties

    let workout: WorkoutModel
    private(set) var workoutDetail: WorkoutDetailModel?
    private(set) var isLoading: Bool = true
    var showingAddExercise: Bool = false

    private let router: Router
    private let repository: WorkoutDetailRepositoryProtocol

    // MARK: - Init

    init(
        workout: WorkoutModel,
        router: Router,
        repository: WorkoutDetailRepositoryProtocol
    ) {
        self.workout = workout
        self.router = router
        self.repository = repository
    }

    // MARK: - Public Methods

    @MainActor
    func loadWorkoutDetail() async {
        isLoading = true
        do {
            workoutDetail = try await repository.getDetail(for: workout.id)
        } catch {
            print("Error loading workout detail: \(error)")
        }
        isLoading = false
    }

    func didTapAddExercise() {
        showingAddExercise = true
    }

    func addExercise(_ exercise: ExerciseModel) {
        var detail = workoutDetail ?? WorkoutDetailModel(workoutId: workout.id)
        detail.exercises.append(exercise)
        workoutDetail = detail

        Task {
            try? await repository.saveDetail(detail)
        }
    }

    func deleteExercise(_ exercise: ExerciseModel) {
        guard var detail = workoutDetail else { return }
        detail.exercises.removeAll { $0.id == exercise.id }
        workoutDetail = detail

        Task {
            try? await repository.saveDetail(detail)
        }
    }

    func dismiss() {
        router.navigator.dismiss()
    }
}
