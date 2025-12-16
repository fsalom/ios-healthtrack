//
//  GlucoseUnit.swift
//  HealthTrack
//

import Foundation

enum GlucoseStatus {
    case low
    case normal
    case high

    var description: String {
        switch self {
        case .low: return "Bajo"
        case .normal: return "Normal"
        case .high: return "Alto"
        }
    }
}
