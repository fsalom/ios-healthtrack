//
//  TrainingViewModel.swift
//  HealthTrack
//

import Foundation

@Observable
final class TrainingViewModel {

    // MARK: - Properties

    private(set) var recentWorkouts: [WorkoutModel] = []
    private(set) var isLoading: Bool = false
    private(set) var weeklyWorkoutCount: Int = 0
    private(set) var weeklyDuration: TimeInterval = 0
    private(set) var weeklyCalories: Double = 0

    var showingWorkoutDetail: Bool = false
    var selectedWorkout: WorkoutModel?

    private let router: Router
    private let healthKitManager: HealthKitManagerProtocol

    // MARK: - Computed Properties

    var formattedWeeklyDuration: String {
        let hours = Int(weeklyDuration) / 3600
        let minutes = (Int(weeklyDuration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }

    var formattedWeeklyCalories: String {
        "\(Int(weeklyCalories))"
    }

    // MARK: - Init

    init(
        router: Router,
        healthKitManager: HealthKitManagerProtocol
    ) {
        self.router = router
        self.healthKitManager = healthKitManager
    }

    // MARK: - Public Methods

    @MainActor
    func loadData() async {
        isLoading = true

        let calendar = Calendar.current
        let now = Date()

        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else {
            isLoading = false
            return
        }

        do {
            let workouts = try await healthKitManager.fetchWorkouts(from: startOfWeek, to: endOfWeek)

            recentWorkouts = workouts.sorted { $0.startDate > $1.startDate }
            weeklyWorkoutCount = workouts.count
            weeklyDuration = workouts.reduce(0) { $0 + $1.duration }
            weeklyCalories = workouts.reduce(0) { $0 + $1.activeCalories }
        } catch {
            print("Error loading workouts: \(error)")
        }

        isLoading = false
    }

    func didTapWorkout(_ workout: WorkoutModel) {
        selectedWorkout = workout
        showingWorkoutDetail = true
    }

    func didTapStartWorkout() {
        // For now, show a placeholder workout
        // In a full implementation, this would open a workout creation flow
        let newWorkout = WorkoutModel(
            type: .strengthTraining,
            startDate: Date(),
            endDate: Date(),
            duration: 0,
            activeCalories: 0
        )
        selectedWorkout = newWorkout
        showingWorkoutDetail = true
    }

    func didTapQuickStart(type: WorkoutType) {
        let newWorkout = WorkoutModel(
            type: type,
            startDate: Date(),
            endDate: Date(),
            duration: 0,
            activeCalories: 0
        )
        selectedWorkout = newWorkout
        showingWorkoutDetail = true
    }
}
