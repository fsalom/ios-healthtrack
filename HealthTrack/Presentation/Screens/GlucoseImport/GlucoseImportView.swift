//
//  GlucoseImportView.swift
//  HealthTrack
//

import SwiftUI
import Charts
import UniformTypeIdentifiers

struct GlucoseImportView: View {

    // MARK: - Properties

    @State var viewModel: GlucoseImportViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                importSection

                if viewModel.hasImportedData {
                    if let latest = viewModel.latestReading {
                        currentReadingCard(latest)
                    }

                    glucoseChart

                    statisticsCard

                    readingsList
                }
            }
            .padding()
        }
        .navigationTitle("Glucosa")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if viewModel.hasImportedData {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.openFilePicker()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .fileImporter(
            isPresented: $viewModel.showingFilePicker,
            allowedContentTypes: [UTType.commaSeparatedText, UTType.text],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.importFile(from: url)
                }
            case .failure(let error):
                print("Error selecting file: \(error)")
            }
        }
    }

    // MARK: - Subviews

    private var importSection: some View {
        VStack(spacing: 16) {
            if !viewModel.hasImportedData {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text("Importar datos de glucosa")
                    .font(.headline)

                Text("Selecciona un archivo CSV exportado desde FreeStyle LibreLink")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    viewModel.openFilePicker()
                } label: {
                    Label("Seleccionar archivo", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(viewModel.importedFileName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(viewModel.readings.count) lecturas")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func currentReadingCard(_ reading: GlucoseReadingModel) -> some View {
        VStack(spacing: 8) {
            Text("Última lectura")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(reading.valueInMgPerDl)")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(colorForStatus(reading.status))

            Text("mg/dL")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(reading.timestamp, format: .dateTime.day().month().hour().minute())
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var glucoseChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Historial")
                .font(.headline)

            Chart {
                // Target range area
                RectangleMark(
                    xStart: .value("Start", viewModel.readings.last?.timestamp ?? Date()),
                    xEnd: .value("End", viewModel.readings.first?.timestamp ?? Date()),
                    yStart: .value("Low", viewModel.targetLow),
                    yEnd: .value("High", viewModel.targetHigh)
                )
                .foregroundStyle(.green.opacity(0.1))

                // Glucose readings line
                ForEach(viewModel.readings) { reading in
                    LineMark(
                        x: .value("Hora", reading.timestamp),
                        y: .value("Glucosa", reading.valueInMgPerDl)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Hora", reading.timestamp),
                        y: .value("Glucosa", reading.valueInMgPerDl)
                    )
                    .foregroundStyle(colorForStatus(reading.status))
                    .symbolSize(20)
                }
            }
            .chartYScale(domain: 40...300)
            .chartYAxis {
                AxisMarks(position: .leading, values: [40, 70, 100, 140, 180, 220, 260, 300]) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statisticsCard: some View {
        let values = viewModel.readings.map { $0.valueInMgPerDl }
        let average = values.isEmpty ? 0 : values.reduce(0, +) / values.count
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        let inRange = viewModel.readings.filter { !$0.isLow && !$0.isHigh }.count
        let inRangePercent = viewModel.readings.isEmpty ? 0 : (inRange * 100) / viewModel.readings.count

        return VStack(alignment: .leading, spacing: 12) {
            Text("Estadísticas")
                .font(.headline)

            HStack(spacing: 16) {
                StatItem(title: "Promedio", value: "\(average)", unit: "mg/dL")
                StatItem(title: "Mínimo", value: "\(min)", unit: "mg/dL", color: .red)
                StatItem(title: "Máximo", value: "\(max)", unit: "mg/dL", color: .orange)
                StatItem(title: "En rango", value: "\(inRangePercent)%", unit: "", color: .green)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var readingsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Todas las lecturas")
                .font(.headline)

            ForEach(viewModel.sortedDays, id: \.self) { day in
                VStack(alignment: .leading, spacing: 8) {
                    Text(day, format: .dateTime.weekday(.wide).day().month())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    ForEach(viewModel.readingsGroupedByDay[day] ?? []) { reading in
                        HStack {
                            Text(reading.timestamp, format: .dateTime.hour().minute())
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            Spacer()
                            Text(reading.formattedValue)
                                .fontWeight(.medium)
                            Circle()
                                .fill(colorForStatus(reading.status))
                                .frame(width: 8, height: 8)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.vertical, 8)

                if day != viewModel.sortedDays.last {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func colorForStatus(_ status: GlucoseStatus) -> Color {
        switch status {
        case .low: return .red
        case .normal: return .primary
        case .high: return .orange
        }
    }
}

// MARK: - StatItem

private struct StatItem: View {
    let title: String
    let value: String
    let unit: String
    var color: Color = .primary

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
