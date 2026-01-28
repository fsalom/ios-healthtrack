//
//  ExerciseModel.swift
//  HealthTrack
//

import Foundation

struct ExerciseModel: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var sets: [SetModel]

    init(id: UUID = UUID(), name: String, sets: [SetModel] = []) {
        self.id = id
        self.name = name
        self.sets = sets
    }

    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }

    var formattedSummary: String {
        if sets.isEmpty {
            return "Sin series"
        }
        let totalSets = sets.count
        let avgReps = sets.map { $0.reps }.reduce(0, +) / max(totalSets, 1)
        let maxWeight = sets.map { $0.weight }.max() ?? 0

        if maxWeight > 0 {
            return "\(totalSets)x\(avgReps) @ \(Int(maxWeight))kg"
        } else {
            return "\(totalSets)x\(avgReps)"
        }
    }
}
