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

                    combinedChart

                    if !viewModel.healthKitAuthorized {
                        healthKitAuthorizationCard
                    }

                    if !viewModel.selectedDayWorkouts.isEmpty {
                        workoutsCard
                    }

                    statisticsCard

                    viewAllReadingsButton
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

    private var combinedChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Day navigator
            dayNavigator

            // Hour range filter
            hourRangeFilter

            // Hourly chart for selected day
            Chart {
                // Target range area
                RectangleMark(
                    xStart: .value("Start", chartStartTime),
                    xEnd: .value("End", chartEndTime),
                    yStart: .value("Low", viewModel.targetLow),
                    yEnd: .value("High", viewModel.targetHigh)
                )
                .foregroundStyle(.green.opacity(0.1))

                // Activity bars (steps per hour)
                if viewModel.showActivityData {
                    ForEach(viewModel.selectedDayActivity) { activity in
                        BarMark(
                            x: .value("Hora", activity.hour),
                            y: .value("Pasos", normalizedSteps(activity.steps))
                        )
                        .foregroundStyle(activity.hasWorkout ? .orange.opacity(0.4) : .gray.opacity(0.3))
                    }
                }

                // Glucose readings line
                ForEach(viewModel.selectedDayReadings) { reading in
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
                    .symbolSize(30)
                }

                // Workout markers
                if viewModel.showActivityData {
                    ForEach(viewModel.selectedDayWorkouts) { workout in
                        RuleMark(x: .value("Workout", workout.startDate))
                            .foregroundStyle(.orange.opacity(0.6))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .annotation(position: .top) {
                                Image(systemName: workout.icon)
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                    }
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
                AxisMarks(values: .stride(by: .hour, count: 2)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .frame(height: 220)

            // Legend and activity toggle
            HStack {
                HStack(spacing: 12) {
                    LegendItem(color: .blue, label: "Glucosa")
                    if viewModel.showActivityData {
                        LegendItem(color: .gray.opacity(0.5), label: "Pasos")
                        LegendItem(color: .orange, label: "Ejercicio")
                    }
                }
                .font(.caption2)

                Spacer()

                if viewModel.healthKitAuthorized && !viewModel.hourlyActivity.isEmpty {
                    Button {
                        viewModel.toggleActivityData()
                    } label: {
                        Image(systemName: viewModel.showActivityData ? "figure.walk.circle.fill" : "figure.walk.circle")
                            .font(.body)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var dayNavigator: some View {
        HStack {
            Button {
                viewModel.goToPreviousDay()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .disabled(!viewModel.canGoToPreviousDay)

            Spacer()

            VStack(spacing: 2) {
                Text(viewModel.selectedDay, format: .dateTime.weekday(.wide))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.selectedDay, format: .dateTime.day().month(.wide))
                    .font(.headline)
            }

            Spacer()

            Button {
                viewModel.goToNextDay()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .disabled(!viewModel.canGoToNextDay)
        }
        .padding(.vertical, 4)
    }

    private var hourRangeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                HourRangeButton(title: "Todo", range: .fullDay, selected: viewModel.hourRange) {
                    viewModel.setHourRange(.fullDay)
                }
                HourRangeButton(title: "Noche", subtitle: "0-6h", range: .night, selected: viewModel.hourRange) {
                    viewModel.setHourRange(.night)
                }
                HourRangeButton(title: "Mañana", subtitle: "6-12h", range: .morning, selected: viewModel.hourRange) {
                    viewModel.setHourRange(.morning)
                }
                HourRangeButton(title: "Tarde", subtitle: "12-18h", range: .afternoon, selected: viewModel.hourRange) {
                    viewModel.setHourRange(.afternoon)
                }
                HourRangeButton(title: "Noche", subtitle: "18-24h", range: .evening, selected: viewModel.hourRange) {
                    viewModel.setHourRange(.evening)
                }
            }
        }
    }

    private var chartStartTime: Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: viewModel.hourRange.start, minute: 0, second: 0, of: viewModel.selectedDay) ?? viewModel.selectedDay
    }

    private var chartEndTime: Date {
        let calendar = Calendar.current
        let hour = viewModel.hourRange.end == 24 ? 23 : viewModel.hourRange.end
        let minute = viewModel.hourRange.end == 24 ? 59 : 0
        return calendar.date(bySettingHour: hour, minute: minute, second: 59, of: viewModel.selectedDay) ?? viewModel.selectedDay
    }

    private var healthKitAuthorizationCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 32))
                .foregroundStyle(.pink)

            Text("Conectar con Apple Health")
                .font(.subheadline)
                .fontWeight(.medium)

            Text("Visualiza tus pasos y entrenamientos junto con los datos de glucosa")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.requestHealthKitAuthorization()
                }
            } label: {
                Label("Permitir acceso", systemImage: "heart.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.pink)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var workoutsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Entrenamientos del día")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.selectedDayWorkouts.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.selectedDayWorkouts) { workout in
                HStack {
                    Image(systemName: workout.icon)
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(workout.startDate, format: .dateTime.weekday(.abbreviated).day().month().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(workout.formattedDuration)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(workout.formattedCalories)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)

                if workout.id != viewModel.selectedDayWorkouts.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statisticsCard: some View {
        let dayReadings = viewModel.selectedDayReadings
        let values = dayReadings.map { $0.valueInMgPerDl }
        let average = values.isEmpty ? 0 : values.reduce(0, +) / values.count
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        let inRange = dayReadings.filter { !$0.isLow && !$0.isHigh }.count
        let inRangePercent = dayReadings.isEmpty ? 0 : (inRange * 100) / dayReadings.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Estadísticas del día")
                    .font(.headline)
                Spacer()
                Text("\(dayReadings.count) lecturas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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

    private var viewAllReadingsButton: some View {
        NavigationLink {
            GlucoseReadingsListView(readings: viewModel.readings)
        } label: {
            HStack {
                Image(systemName: "list.bullet")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ver todas las lecturas")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(viewModel.readings.count) registros")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func colorForStatus(_ status: GlucoseStatus) -> Color {
        switch status {
        case .low: return .red
        case .normal: return .primary
        case .high: return .orange
        }
    }

    private func normalizedSteps(_ steps: Int) -> Int {
        // Normalize steps to fit within glucose chart range (40-300)
        // Map steps (0 - maxSteps) to (40 - 120) to show at bottom of chart
        let maxSteps = max(viewModel.selectedDayMaxSteps, 1)
        let normalizedValue = 40 + (Double(steps) / Double(maxSteps)) * 80
        return Int(normalizedValue)
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

// MARK: - LegendItem

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - HourRangeButton

private struct HourRangeButton: View {
    let title: String
    var subtitle: String? = nil
    let range: HourRange
    let selected: HourRange
    let action: () -> Void

    private var isSelected: Bool {
        range == selected
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .foregroundStyle(isSelected ? .primary : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
