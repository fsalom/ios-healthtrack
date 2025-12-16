//
//  GlucoseReadingModel.swift
//  HealthTrack
//

import Foundation

struct GlucoseReadingModel: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let valueInMgPerDl: Int
    let readingType: ReadingType

    var isHigh: Bool {
        valueInMgPerDl > 180
    }

    var isLow: Bool {
        valueInMgPerDl < 70
    }

    var formattedValue: String {
        "\(valueInMgPerDl) mg/dL"
    }

    var status: GlucoseStatus {
        if isLow { return .low }
        if isHigh { return .high }
        return .normal
    }

    enum ReadingType: Int {
        case history = 0      // Lectura automática cada ~15 min
        case scan = 1         // Escaneo manual
        case unknown = -1
    }
}
