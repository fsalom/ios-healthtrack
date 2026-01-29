//
//  GetStrengthStatsUseCase.swift
//  HealthTrack
//

import Foundation

protocol GetStrengthStatsUseCaseProtocol {
    func execute() async throws -> StrengthStatsModel
}

final class GetStrengthStatsUseCase: GetStrengthStatsUseCaseProtocol {

    // MARK: - Properties

    private let workoutDetailRepository: WorkoutDetailRepositoryProtocol
    private let exerciseLibraryRepository: ExerciseLibraryRepositoryProtocol

    // MARK: - Init

    init(
        workoutDetailRepository: WorkoutDetailRepositoryProtocol,
        exerciseLibraryRepository: ExerciseLibraryRepositoryProtocol
    ) {
        self.workoutDetailRepository = workoutDetailRepository
        self.exerciseLibraryRepository = exerciseLibraryRepository
    }

    // MARK: - Public Methods

    func execute() async throws -> StrengthStatsModel {
        async let workoutDetails = workoutDetailRepository.getAllDetails()
        async let exerciseHistory = exerciseLibraryRepository.getMostUsedExercises(limit: 10)

        let (details, history) = try await (workoutDetails, exerciseHistory)

        let personalRecords = calculatePersonalRecords(from: details, history: history)
        let weeklyVolumes = calculateWeeklyVolumes(from: details)
        let frequentExercises = calculateFrequentExercises(from: history)

        return StrengthStatsModel(
            personalRecords: personalRecords,
            weeklyVolumes: weeklyVolumes,
            frequentExercises: frequentExercises
        )
    }

    // MARK: - Private Methods

    private func calculatePersonalRecords(
        from details: [WorkoutDetailModel],
        history: [ExerciseHistoryModel]
    ) -> [StrengthStatsModel.PersonalRecord] {
        var maxWeightPerExercise: [String: (weight: Double, date: Date)] = [:]

        for detail in details {
            for exercise in detail.exercises {
                for set in exercise.sets where !set.isWarmup && set.weight > 0 {
                    let currentMax = maxWeightPerExercise[exercise.name]
                    if currentMax == nil || set.weight > currentMax!.weight {
                        maxWeightPerExercise[exercise.name] = (set.weight, detail.createdAt)
                    }
                }
            }
        }

        // Also include lastWeight from history if higher
        for historyItem in history {
            if let lastWeight = historyItem.lastWeight, lastWeight > 0 {
                let currentMax = maxWeightPerExercise[historyItem.exerciseName]
                if currentMax == nil || lastWeight > currentMax!.weight {
                    maxWeightPerExercise[historyItem.exerciseName] = (lastWeight, historyItem.lastUsedDate)
                }
            }
        }

        return maxWeightPerExercise
            .map { name, data in
                StrengthStatsModel.PersonalRecord(
                    id: UUID(),
                    exerciseName: name,
                    weight: data.weight,
                    date: data.date
                )
            }
            .sorted { $0.weight > $1.weight }
            .prefix(5)
            .map { $0 }
    }

    private func calculateWeeklyVolumes(from details: [WorkoutDetailModel]) -> [StrengthStatsModel.WeeklyVolume] {
        let calendar = Calendar.current
        let now = Date()

        var weeklyVolumes: [StrengthStatsModel.WeeklyVolume] = []

        for weekOffset in 0..<4 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now),
                  let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: weekStart)?.start,
                  let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: weekStart)?.end else {
                continue
            }

            let weekDetails = details.filter { detail in
                detail.createdAt >= startOfWeek && detail.createdAt < endOfWeek
            }

            let totalVolume = weekDetails.reduce(0.0) { $0 + $1.totalVolume }

            weeklyVolumes.append(StrengthStatsModel.WeeklyVolume(
                weekStartDate: startOfWeek,
                volume: totalVolume
            ))
        }

        return weeklyVolumes
    }

    private func calculateFrequentExercises(
        from history: [ExerciseHistoryModel]
    ) -> [StrengthStatsModel.FrequentExercise] {
        history
            .prefix(5)
            .map { historyItem in
                StrengthStatsModel.FrequentExercise(
                    id: historyItem.id,
                    exerciseName: historyItem.exerciseName,
                    count: historyItem.useCount
                )
            }
    }
}
