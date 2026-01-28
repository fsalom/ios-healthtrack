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

    // Extended data from HealthKit
    let distance: Double? // in meters
    let averageHeartRate: Double? // bpm
    let maxHeartRate: Double? // bpm
    let averagePace: Double? // seconds per kilometer
    let elevationGain: Double? // in meters

    init(
        id: UUID = UUID(),
        type: WorkoutType,
        startDate: Date,
        endDate: Date,
        duration: TimeInterval,
        activeCalories: Double,
        distance: Double? = nil,
        averageHeartRate: Double? = nil,
        maxHeartRate: Double? = nil,
        averagePace: Double? = nil,
        elevationGain: Double? = nil
    ) {
        self.id = id
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.activeCalories = activeCalories
        self.distance = distance
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.averagePace = averagePace
        self.elevationGain = elevationGain
    }

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

    var formattedDistance: String? {
        guard let distance = distance, distance > 0 else { return nil }
        if distance >= 1000 {
            return String(format: "%.2f km", distance / 1000)
        } else {
            return String(format: "%.0f m", distance)
        }
    }

    var formattedPace: String? {
        guard let pace = averagePace, pace > 0 else { return nil }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }

    var formattedHeartRate: String? {
        guard let hr = averageHeartRate else { return nil }
        return "\(Int(hr)) bpm"
    }

    var formattedElevation: String? {
        guard let elevation = elevationGain, elevation > 0 else { return nil }
        return String(format: "+%.0f m", elevation)
    }

    // Whether this workout type typically has distance data
    var hasDistanceData: Bool {
        switch type {
        case .running, .walking, .cycling, .swimming, .hiking, .elliptical, .rowing:
            return true
        default:
            return false
        }
    }

    // Whether this workout type is strength-based (can have sets/reps)
    var isStrengthBased: Bool {
        switch type {
        case .strengthTraining, .crossTraining:
            return true
        default:
            return false
        }
    }
}
