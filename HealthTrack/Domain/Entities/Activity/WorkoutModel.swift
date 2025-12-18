//
//  WorkoutModel.swift
//  HealthTrack
//

import Foundation

// MARK: - WorkoutType

enum WorkoutType: String, CaseIterable {
    case running
    case walking
    case cycling
    case swimming
    case hiking
    case yoga
    case strengthTraining
    case hiit
    case elliptical
    case rowing
    case stairClimbing
    case dance
    case pilates
    case crossTraining
    case other

    var displayName: String {
        switch self {
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .hiking: return "Hiking"
        case .yoga: return "Yoga"
        case .strengthTraining: return "Strength"
        case .hiit: return "HIIT"
        case .elliptical: return "Elliptical"
        case .rowing: return "Rowing"
        case .stairClimbing: return "Stairs"
        case .dance: return "Dance"
        case .pilates: return "Pilates"
        case .crossTraining: return "Cross Training"
        case .other: return "Workout"
        }
    }

    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .hiking: return "figure.hiking"
        case .yoga: return "figure.yoga"
        case .strengthTraining: return "dumbbell.fill"
        case .hiit: return "bolt.heart.fill"
        case .elliptical: return "figure.elliptical"
        case .rowing: return "figure.rower"
        case .stairClimbing: return "figure.stair.stepper"
        case .dance: return "figure.dance"
        case .pilates: return "figure.pilates"
        case .crossTraining: return "figure.cross.training"
        case .other: return "figure.mixed.cardio"
        }
    }
}

// MARK: - WorkoutModel

struct WorkoutModel: Identifiable, Equatable {
    let id: UUID
    let type: WorkoutType
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let activeCalories: Double

    var displayName: String {
        type.displayName
    }

    var icon: String {
        type.icon
    }

    var formattedDuration: String {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }

    var formattedCalories: String {
        "\(Int(activeCalories)) kcal"
    }
}
