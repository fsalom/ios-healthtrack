//
//  StrengthStatsModel.swift
//  HealthTrack
//

import Foundation

struct StrengthStatsModel: Equatable {

    // MARK: - Nested Types

    struct PersonalRecord: Identifiable, Equatable {
        let id: UUID
        let exerciseName: String
        let weight: Double
        let date: Date

        var formattedWeight: String {
            if weight.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(weight)) kg"
            }
            return String(format: "%.1f kg", weight)
        }

        var formattedDate: String {
            date.formatted(.dateTime.day().month(.abbreviated))
        }
    }

    struct WeeklyVolume: Identifiable, Equatable {
        let id: UUID
        let weekStartDate: Date
        let volume: Double

        init(id: UUID = UUID(), weekStartDate: Date, volume: Double) {
            self.id = id
            self.weekStartDate = weekStartDate
            self.volume = volume
        }

        var formattedVolume: String {
            if volume >= 1000 {
                return String(format: "%.1f t", volume / 1000)
            }
            return "\(Int(volume)) kg"
        }

        var weekLabel: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.string(from: weekStartDate)
        }
    }

    struct FrequentExercise: Identifiable, Equatable {
        let id: UUID
        let exerciseName: String
        let count: Int

        var formattedCount: String {
            "\(count) veces"
        }
    }

    // MARK: - Properties

    let personalRecords: [PersonalRecord]
    let weeklyVolumes: [WeeklyVolume]
    let frequentExercises: [FrequentExercise]

    // MARK: - Computed Properties

    var currentWeekVolume: Double {
        weeklyVolumes.first?.volume ?? 0
    }

    var previousWeekVolume: Double {
        weeklyVolumes.count > 1 ? weeklyVolumes[1].volume : 0
    }

    var weeklyVolumeChange: Double? {
        guard previousWeekVolume > 0 else { return nil }
        return ((currentWeekVolume - previousWeekVolume) / previousWeekVolume) * 100
    }

    var formattedCurrentWeekVolume: String {
        if currentWeekVolume >= 1000 {
            return String(format: "%.1f t", currentWeekVolume / 1000)
        }
        return "\(Int(currentWeekVolume)) kg"
    }

    var formattedVolumeChange: String? {
        guard let change = weeklyVolumeChange else { return nil }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(Int(change))%"
    }

    // MARK: - Static

    static let empty = StrengthStatsModel(
        personalRecords: [],
        weeklyVolumes: [],
        frequentExercises: []
    )
}
