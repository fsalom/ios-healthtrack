//
//  GlucoseReadingsListView.swift
//  HealthTrack
//

import SwiftUI

struct GlucoseReadingsListView: View {

    // MARK: - Properties

    let readings: [GlucoseReadingModel]

    @State private var selectedFilter: GlucoseFilter = .all
    @State private var searchText: String = ""

    private var filteredReadings: [GlucoseReadingModel] {
        var result = readings

        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .low:
            result = result.filter { $0.isLow }
        case .normal:
            result = result.filter { !$0.isLow && !$0.isHigh }
        case .high:
            result = result.filter { $0.isHigh }
        }

        // Apply search (by date)
        if !searchText.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "d/M"
            result = result.filter { reading in
                formatter.string(from: reading.timestamp).contains(searchText)
            }
        }

        return result
    }

    private var readingsGroupedByDay: [Date: [GlucoseReadingModel]] {
        Dictionary(grouping: filteredReadings) { reading in
            Calendar.current.startOfDay(for: reading.timestamp)
        }
    }

    private var sortedDays: [Date] {
        readingsGroupedByDay.keys.sorted(by: >)
    }

    // MARK: - Body

    var body: some View {
        List {
            // Filter section
            Section {
                Picker("Filtrar", selection: $selectedFilter) {
                    ForEach(GlucoseFilter.allCases, id: \.self) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Stats for current filter
            if !filteredReadings.isEmpty {
                Section {
                    HStack {
                        FilterStatItem(
                            title: "Lecturas",
                            value: "\(filteredReadings.count)"
                        )
                        Divider()
                        FilterStatItem(
                            title: "Promedio",
                            value: "\(averageValue) mg/dL"
                        )
                        Divider()
                        FilterStatItem(
                            title: "Rango",
                            value: "\(minValue)-\(maxValue)"
                        )
                    }
                    .frame(height: 50)
                }
            }

            // Readings grouped by day
            ForEach(sortedDays, id: \.self) { day in
                Section {
                    ForEach(readingsGroupedByDay[day] ?? []) { reading in
                        ReadingRow(reading: reading)
                    }
                } header: {
                    Text(day, format: .dateTime.weekday(.wide).day().month())
                }
            }

            if filteredReadings.isEmpty {
                Section {
                    ContentUnavailableView(
                        "Sin resultados",
                        systemImage: "magnifyingglass",
                        description: Text("No hay lecturas que coincidan con el filtro seleccionado")
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Lecturas")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Buscar por fecha (d/m)")
    }

    // MARK: - Computed Properties

    private var averageValue: Int {
        guard !filteredReadings.isEmpty else { return 0 }
        let sum = filteredReadings.map { $0.valueInMgPerDl }.reduce(0, +)
        return sum / filteredReadings.count
    }

    private var minValue: Int {
        filteredReadings.map { $0.valueInMgPerDl }.min() ?? 0
    }

    private var maxValue: Int {
        filteredReadings.map { $0.valueInMgPerDl }.max() ?? 0
    }
}

// MARK: - GlucoseFilter

private enum GlucoseFilter: CaseIterable {
    case all
    case low
    case normal
    case high

    var displayName: String {
        switch self {
        case .all: return "Todas"
        case .low: return "Bajas"
        case .normal: return "Normal"
        case .high: return "Altas"
        }
    }
}

// MARK: - ReadingRow

private struct ReadingRow: View {
    let reading: GlucoseReadingModel

    var body: some View {
        HStack {
            Text(reading.timestamp, format: .dateTime.hour().minute())
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)

            Spacer()

            Text(reading.formattedValue)
                .font(.body)
                .fontWeight(.medium)

            Circle()
                .fill(colorForStatus(reading.status))
                .frame(width: 10, height: 10)
        }
    }

    private func colorForStatus(_ status: GlucoseStatus) -> Color {
        switch status {
        case .low: return .red
        case .normal: return .green
        case .high: return .orange
        }
    }
}

// MARK: - FilterStatItem

private struct FilterStatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}
