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

                    if !viewModel.selectedDayMeals.isEmpty {
                        mealsCard
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
        .sheet(isPresented: $viewModel.showingAddMeal) {
            AddMealBuilder.build(
                initialTime: viewModel.addMealTime,
                onMealSaved: { meal in
                    viewModel.addMeal(meal)
                }
            )
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

    @State private var lastDragValue: CGFloat = 0
    @State private var chartWidth: CGFloat = 0
    @State private var initialZoomHours: Double = 24
    @State private var selectedActivity: HourlyActivityModel?

    private var combinedChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Day navigator
            dayNavigator

            // Zoom controls
            zoomControls

            // Hourly chart for selected day
            Chart {
                // Target range area
                RectangleMark(
                    xStart: .value("Start", viewModel.chartStartTime),
                    xEnd: .value("End", viewModel.chartEndTime),
                    yStart: .value("Low", viewModel.targetLow),
                    yEnd: .value("High", viewModel.targetHigh)
                )
                .foregroundStyle(.green.opacity(0.1))

                // Activity bars (steps per hour) - drawn first so line appears on top
                if viewModel.showActivityData {
                    ForEach(viewModel.selectedDayActivity) { activity in
                        BarMark(
                            x: .value("Hora", activity.hour),
                            yStart: .value("Base", 40),
                            yEnd: .value("Pasos", normalizedSteps(activity.steps))
                        )
                        .foregroundStyle(
                            selectedActivity?.id == activity.id
                                ? (activity.hasWorkout ? .orange.opacity(0.7) : .gray.opacity(0.6))
                                : (activity.hasWorkout ? .orange.opacity(0.4) : .gray.opacity(0.3))
                        )
                    }
                }

                // Glucose readings - smooth line
                ForEach(viewModel.selectedDayReadings) { reading in
                    LineMark(
                        x: .value("Hora", reading.timestamp),
                        y: .value("Glucosa", reading.valueInMgPerDl)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
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

                // Meal markers
                if viewModel.showMealData {
                    ForEach(viewModel.selectedDayMeals) { meal in
                        RuleMark(x: .value("Meal", meal.timestamp))
                            .foregroundStyle(.green.opacity(0.6))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .annotation(position: .top) {
                                Image(systemName: "fork.knife")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                            }
                    }
                }

                // Steps annotation - drawn last so it appears on top of everything
                if viewModel.showActivityData, let selected = selectedActivity, selected.steps > 0 {
                    PointMark(
                        x: .value("Hora", selected.hour),
                        y: .value("Pasos", normalizedSteps(selected.steps))
                    )
                    .foregroundStyle(.clear)
                    .annotation(position: .top) {
                        Text("\(selected.steps) pasos")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    }
                }
            }
            .chartXScale(domain: viewModel.chartStartTime...viewModel.chartEndTime)
            .chartYScale(domain: 40...viewModel.chartYMax)
            .chartYAxis {
                AxisMarks(position: .leading, values: yAxisValues) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: xAxisStrideCount)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onAppear {
                            chartWidth = geometry.size.width
                        }
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let xPosition = value.location.x - geometry[proxy.plotFrame!].origin.x
                                    let yPosition = value.location.y - geometry[proxy.plotFrame!].origin.y
                                    let plotHeight = geometry[proxy.plotFrame!].height

                                    if let date: Date = proxy.value(atX: xPosition) {
                                        // If tapping in bottom 30% of chart, select activity bar
                                        if yPosition > plotHeight * 0.7 && viewModel.showActivityData {
                                            selectActivityAt(date: date)
                                        } else {
                                            // Clear selection and add meal
                                            selectedActivity = nil
                                            viewModel.didTapAddMealAtTime(date)
                                        }
                                    }
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let delta = value.translation.width - lastDragValue
                                    lastDragValue = value.translation.width
                                    viewModel.handlePanGesture(translation: delta, chartWidth: chartWidth)
                                }
                                .onEnded { _ in
                                    lastDragValue = 0
                                }
                        )
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    viewModel.handleZoomGesture(
                                        scale: value.magnification,
                                        initialHours: initialZoomHours
                                    )
                                }
                                .onEnded { _ in
                                    initialZoomHours = viewModel.zoomState.visibleHours
                                }
                        )
                        .onAppear {
                            initialZoomHours = viewModel.zoomState.visibleHours
                        }
                }
            }
            .frame(height: 220)
            .animation(.easeInOut(duration: 0.2), value: viewModel.zoomState)
            .onChange(of: viewModel.selectedDay) {
                selectedActivity = nil
            }

            // Legend and toggles
            HStack {
                HStack(spacing: 12) {
                    LegendItem(color: .blue, label: "Glucosa")
                    if viewModel.showActivityData {
                        LegendItem(color: .gray.opacity(0.5), label: "Pasos")
                        LegendItem(color: .orange, label: "Ejercicio")
                    }
                    if viewModel.showMealData {
                        LegendItem(color: .green, label: "Comidas")
                    }
                }
                .font(.caption2)

                Spacer()

                HStack(spacing: 8) {
                    // Meal toggle
                    Button {
                        viewModel.toggleMealData()
                    } label: {
                        Image(systemName: viewModel.showMealData ? "fork.knife.circle.fill" : "fork.knife.circle")
                            .font(.body)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.green)

                    // Activity toggle
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

    private var xAxisStrideCount: Int {
        // Adjust axis label density based on zoom level
        let hours = viewModel.zoomState.visibleHours
        if hours <= 4 { return 1 }
        if hours <= 8 { return 1 }
        if hours <= 12 { return 2 }
        return 2
    }

    private var yAxisValues: [Int] {
        // Generate Y axis values from 40 to chartYMax in steps of 40
        let maxY = viewModel.chartYMax
        var values: [Int] = []
        var current = 40
        while current <= maxY {
            values.append(current)
            current += 40
        }
        // Ensure we always include the max
        if let last = values.last, last < maxY {
            values.append(maxY)
        }
        return values
    }

    private var zoomControls: some View {
        HStack {
            // Zoom level indicator
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                if viewModel.isZoomed {
                    Text(timeRangeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Pellizca para zoom")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            if viewModel.isZoomed {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.resetZoom()
                        initialZoomHours = 24
                    }
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.secondary)
            }
        }
    }

    private var timeRangeText: String {
        let startHour = Int(viewModel.zoomState.effectiveStart)
        let endHour = Int(viewModel.zoomState.effectiveEnd)
        return String(format: "%02d:00 - %02d:00", startHour, endHour == 24 ? 0 : endHour)
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

    private var mealsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Comidas del dia")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.selectedDayMeals.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.selectedDayMeals) { meal in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "fork.knife")
                            .font(.title3)
                            .foregroundStyle(.green)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(meal.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(meal.timestamp, format: .dateTime.hour().minute())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(meal.totalNutrition.formattedCalories)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(Int(meal.totalNutrition.carbohydrates))g carbs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Show items summary
                    if !meal.items.isEmpty {
                        HStack {
                            Text(meal.items.map { $0.name }.joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                        .padding(.leading, 40)
                    }
                }
                .padding(.vertical, 4)

                if meal.id != viewModel.selectedDayMeals.last?.id {
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

    private func selectActivityAt(date: Date) {
        let calendar = Calendar.current
        let tappedHour = calendar.component(.hour, from: date)

        // Find activity matching the tapped hour
        if let activity = viewModel.selectedDayActivity.first(where: {
            calendar.component(.hour, from: $0.hour) == tappedHour
        }) {
            // Toggle selection
            if selectedActivity?.id == activity.id {
                selectedActivity = nil
            } else {
                selectedActivity = activity
            }
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
