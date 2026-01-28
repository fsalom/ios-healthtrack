//
//  SetModel.swift
//  HealthTrack
//

import Foundation

struct SetModel: Identifiable, Equatable, Codable {
    let id: UUID
    var reps: Int
    var weight: Double // in kg
    var isWarmup: Bool
    var notes: String?

    init(
        id: UUID = UUID(),
        reps: Int,
        weight: Double = 0,
        isWarmup: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.isWarmup = isWarmup
        self.notes = notes
    }

    var formattedWeight: String {
        if weight > 0 {
            if weight.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(weight)) kg"
            } else {
                return String(format: "%.1f kg", weight)
            }
        }
        return "Peso corporal"
    }
}
