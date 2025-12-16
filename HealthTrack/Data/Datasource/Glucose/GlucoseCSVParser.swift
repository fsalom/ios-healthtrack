//
//  GlucoseCSVParser.swift
//  HealthTrack
//

import Foundation

protocol GlucoseCSVParserProtocol {
    func parse(from url: URL) throws -> [GlucoseReadingModel]
}

final class GlucoseCSVParser: GlucoseCSVParserProtocol {

    // MARK: - Column Indices

    private enum Column: Int {
        case device = 0
        case serialNumber = 1
        case timestamp = 2
        case recordType = 3
        case historyGlucose = 4
        case scanGlucose = 5
    }

    // MARK: - Date Formatter

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()

    // MARK: - Public Methods

    func parse(from url: URL) throws -> [GlucoseReadingModel] {
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        guard lines.count > 2 else {
            throw CSVParserError.emptyFile
        }

        var readings: [GlucoseReadingModel] = []

        // Skip first 2 lines (metadata and headers)
        for lineIndex in 2..<lines.count {
            let line = lines[lineIndex]
            guard !line.isEmpty else { continue }

            if let reading = parseLine(line) {
                readings.append(reading)
            }
        }

        // Sort by timestamp descending (most recent first)
        readings.sort { $0.timestamp > $1.timestamp }

        return readings
    }

    // MARK: - Private Methods

    private func parseLine(_ line: String) -> GlucoseReadingModel? {
        let columns = parseCSVLine(line)

        guard columns.count > Column.scanGlucose.rawValue else {
            return nil
        }

        // Get record type
        guard let recordType = Int(columns[Column.recordType.rawValue]) else {
            return nil
        }

        // Only process type 0 (history) and type 1 (scan)
        guard recordType == 0 || recordType == 1 else {
            return nil
        }

        // Get glucose value based on record type
        let glucoseValue: Int?
        if recordType == 0 {
            glucoseValue = Int(columns[Column.historyGlucose.rawValue])
        } else {
            glucoseValue = Int(columns[Column.scanGlucose.rawValue])
        }

        guard let value = glucoseValue, value > 0 else {
            return nil
        }

        // Parse timestamp
        let timestampString = columns[Column.timestamp.rawValue]
        guard let timestamp = dateFormatter.date(from: timestampString) else {
            return nil
        }

        return GlucoseReadingModel(
            id: UUID(),
            timestamp: timestamp,
            valueInMgPerDl: value,
            readingType: GlucoseReadingModel.ReadingType(rawValue: recordType) ?? .unknown
        )
    }

    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                result.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        result.append(currentField)

        return result
    }
}

// MARK: - Errors

enum CSVParserError: Error, LocalizedError {
    case emptyFile
    case invalidFormat
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "El archivo CSV está vacío"
        case .invalidFormat:
            return "El formato del archivo CSV no es válido"
        case .fileNotFound:
            return "No se encontró el archivo"
        }
    }
}
