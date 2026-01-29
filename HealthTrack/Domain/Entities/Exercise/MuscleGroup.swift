//
//  MuscleGroup.swift
//  HealthTrack
//

import Foundation

enum MuscleGroup: String, CaseIterable, Codable {
    case ppiectoralMajor
    case latissimusDorsi
    case trapezius
    case deltoids
    case biceps
    case triceps
    case quadriceps
    case hamstrings
    case glutes
    case calves
    case abs
    case obliques
    case lowerBack
    case forearms

    var displayName: String {
        switch self {
        case .ppiectoralMajor: return "Pectoral"
        case .latissimusDorsi: return "Dorsal"
        case .trapezius: return "Trapecio"
        case .deltoids: return "Deltoides"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .quadriceps: return "Cuadriceps"
        case .hamstrings: return "Isquiotibiales"
        case .glutes: return "Gluteos"
        case .calves: return "Gemelos"
        case .abs: return "Abdominales"
        case .obliques: return "Oblicuos"
        case .lowerBack: return "Lumbar"
        case .forearms: return "Antebrazos"
        }
    }
}
