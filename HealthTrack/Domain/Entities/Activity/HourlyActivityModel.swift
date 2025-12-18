//
//  HourlyActivityModel.swift
//  HealthTrack
//

import Foundation

struct HourlyActivityModel: Identifiable, Equatable {
    let id: UUID
    let hour: Date
    let steps: Int
    let hasWorkout: Bool
    let workoutType: String?

    init(
        id: UUID = UUID(),
        hour: Date,
        steps: Int,
        hasWorkout: Bool = false,
        workoutType: String? = nil
    ) {
        self.id = id
        self.hour = hour
        self.steps = steps
        self.hasWorkout = hasWorkout
        self.workoutType = workoutType
    }
}
