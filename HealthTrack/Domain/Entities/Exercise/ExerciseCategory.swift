//
//  ExerciseCategory.swift
//  HealthTrack
//

import Foundation

enum ExerciseCategory: String, CaseIterable, Codable {
    case chest
    case back
    case legs
    case shoulders
    case arms
    case core
    case cardio

    var displayName: String {
        switch self {
        case .chest: return "Pecho"
        case .back: return "Espalda"
        case .legs: return "Piernas"
        case .shoulders: return "Hombros"
        case .arms: return "Brazos"
        case .core: return "Core"
        case .cardio: return "Cardio"
        }
    }

    var icon: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rowing"
        case .legs: return "figure.run"
        case .shoulders: return "figure.boxing"
        case .arms: return "figure.mixed.cardio"
        case .core: return "figure.core.training"
        case .cardio: return "figure.highintensity.intervaltraining"
        }
    }
}
