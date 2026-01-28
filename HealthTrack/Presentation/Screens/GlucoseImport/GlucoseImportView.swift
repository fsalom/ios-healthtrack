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
    @State private var lastDragValue: CGFloat = 0
    @State private var chartWidth: CGFloat = 0
    @State private var initialZoomHours: Double = 24
    @State private var selectedActivity: HourlyActivityModel?

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary cards
                summaryCards

                // Activity chart (always visible)
                activityChart

                // Workouts card
                if !viewModel.selectedDayWorkouts.isEmpty {
                    workoutsCard
                }

                // Meals card
                if !viewModel.selectedDayMeals.isEmpty {
                    mealsCard
                }

                // Glucose section (if imported)
                if viewModel.hasGlucoseData {
                    glucoseStatsCard
                }
            }
            .padding()
        }
        .navigationTitle("Actividad")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if viewModel.hasGlucoseData {
                        Button {
                            viewModel.toggleGlucoseData()
                        } label: {
                            Label(
                                viewModel.showGlucoseData ? "Ocultar glucosa" : "Mostrar glucosa",
                                systemImage: viewModel.showGlucoseData ? "eye.slash" : "eye"
                            )
                        }

                        Button(role: .destructive) {
                            viewModel.clearGlucoseData()
                        } label: {
                            Label("Eliminar datos de glucosa", systemImage: "trash")
                        }

                        Divider()
                    }

                    Button {
                        viewModel.openFilePicker()
                    } label: {
                        Label(
                            viewModel.hasGlucoseData ? "Reimportar glucosa" : "Importar glucosa",
                            systemImage: "doc.badge.plus"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
        .sheet(isPresented: $viewModel.showingWorkoutDetail) {
            if let workout = viewModel.selectedWorkout {
                WorkoutDetailBuilder.build(workout: workout)
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 12) {
            // Steps card
            SummaryCard(
                icon: "figure.walk",
                iconColor: .blue,
                title: "Pasos",
                value: "\(viewModel.todayTotalSteps.formatted())",
                subtitle: "hoy"
            )

            // Workouts card
            SummaryCard(
                icon: "flame.fill",
                iconColor: .orange,
                title: "Ejercicio",
                value: "\(viewModel.selectedDayWorkouts.count)",
                subtitle: viewModel.selectedDayWorkouts.count == 1 ? "entrenamiento" : "entrenamientos"
            )

            // Glucose card (if available)
            if viewModel.hasGlucoseData, let latest = viewModel.latestReading {
                SummaryCard(
                    icon: "drop.fill",
                    iconColor: colorForStatus(latest.status),
                    title: "Glucosa",
                    value: "\(latest.valueInMgPerDl)",
                    subtitle: "mg/dL"
                )
            }
        }
    }

    // MARK: - Activity Chart

    private var activityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Day navigator
            dayNavigator

            // Zoom controls
            zoomControls

            // Chart
            Chart {
                // Target range (only if glucose data)
                if viewModel.hasGlucoseData && viewModel.showGlucoseData {
                    RectangleMark(
                        xStart: .value("Start", viewModel.chartStartTime),
                        xEnd: .value("End", viewModel.chartEndTime),
                        yStart: .value("Low", viewModel.targetLow),
                        yEnd: .value("High", viewModel.targetHigh)
                    )
                    .foregroundStyle(.green.opacity(0.1))
                }

                // Activity bars (steps per hour)
                ForEach(viewModel.selectedDayActivity) { activity in
                    BarMark(
                        x: .value("Hora", activity.hour),
                        yStart: .value("Base", chartYMin),
                        yEnd: .value("Pasos", normalizedSteps(activity.steps))
                    )
                    .foregroundStyle(
                        selectedActivity?.id == activity.id
                            ? (activity.hasWorkout ? .orange.opacity(0.7) : .blue.opacity(0.5))
                            : (activity.hasWorkout ? .orange.opacity(0.4) : .blue.opacity(0.3))
                    )
                }

                // Glucose line (only if data and visible)
                if viewModel.hasGlucoseData && viewModel.showGlucoseData {
                    ForEach(viewModel.selectedDayReadings) { reading in
                        LineMark(
                            x: .value("Hora", reading.timestamp),
                            y: .value("Glucosa", reading.valueInMgPerDl)
                        )
                        .foregroundStyle(.red)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }
                }

                // Workout markers
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

                // Steps annotation
                if let selected = selectedActivity, selected.steps > 0 {
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
            .chartYScale(domain: chartYMin...chartYMax)
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
                                        // If tapping in bottom 40% of chart, select activity bar
                                        if yPosition > plotHeight * 0.6 {
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

            // Legend
            chartLegend
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var chartLegend: some View {
        HStack {
            HStack(spacing: 12) {
                LegendItem(color: .blue.opacity(0.5), label: "Pasos")
                LegendItem(color: .orange, label: "Ejercicio")
                if viewModel.hasGlucoseData && viewModel.showGlucoseData {
                    LegendItem(color: .red, label: "Glucosa")
                }
                if viewModel.showMealData && !viewModel.selectedDayMeals.isEmpty {
                    LegendItem(color: .green, label: "Comidas")
                }
            }
            .font(.caption2)

            Spacer()

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
        }
    }

    // MARK: - Supporting Views

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

    private var zoomControls: some View {
        HStack {
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

    private var xAxisStrideCount: Int {
        let hours = viewModel.zoomState.visibleHours
        if hours <= 4 { return 1 }
        if hours <= 8 { return 1 }
        if hours <= 12 { return 2 }
        return 2
    }

    // MARK: - Chart Scale Helpers

    private var chartYMin: Int {
        viewModel.hasGlucoseData && viewModel.showGlucoseData ? 40 : 0
    }

    private var chartYMax: Int {
        if viewModel.hasGlucoseData && viewModel.showGlucoseData {
            return viewModel.chartYMax
        } else {
            // For steps only, use the max normalized value
            return max(normalizedSteps(viewModel.selectedDayMaxSteps), 100)
        }
    }

    private var yAxisValues: [Int] {
        if viewModel.hasGlucoseData && viewModel.showGlucoseData {
            let maxY = viewModel.chartYMax
            var values: [Int] = []
            var current = 40
            while current <= maxY {
                values.append(current)
                current += 40
            }
            if let last = values.last, last < maxY {
                values.append(maxY)
            }
            return values
        } else {
            // For steps-only chart
            return [0, 25, 50, 75, 100]
        }
    }

    private func normalizedSteps(_ steps: Int) -> Int {
        if viewModel.hasGlucoseData && viewModel.showGlucoseData {
            // When showing glucose, normalize to 40-120 range
            let maxSteps = max(viewModel.selectedDayMaxSteps, 1)
            let normalizedValue = 40 + (Double(steps) / Double(maxSteps)) * 80
            return Int(normalizedValue)
        } else {
            // When showing only steps, use 0-100 range
            let maxSteps = max(viewModel.selectedDayMaxSteps, 1)
            let normalizedValue = (Double(steps) / Double(maxSteps)) * 100
            return Int(normalizedValue)
        }
    }

    private func selectActivityAt(date: Date) {
        let calendar = Calendar.current
        let tappedHour = calendar.component(.hour, from: date)

        if let activity = viewModel.selectedDayActivity.first(where: {
            calendar.component(.hour, from: $0.hour) == tappedHour
        }) {
            if selectedActivity?.id == activity.id {
                selectedActivity = nil
            } else {
                selectedActivity = activity
            }
        }
    }

    // MARK: - Cards

    private var workoutsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Entrenamientos")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.selectedDayWorkouts.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.selectedDayWorkouts) { workout in
                WorkoutRowView(workout: workout)
                    .onTapGesture {
                        viewModel.didTapWorkout(workout)
                    }

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
                Text("Comidas")
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

                    if !meal.items.isEmpty {
                        Text(meal.items.map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
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

    private var glucoseStatsCard: some View {
        let dayReadings = viewModel.selectedDayReadings
        let values = dayReadings.map { $0.valueInMgPerDl }
        let average = values.isEmpty ? 0 : values.reduce(0, +) / values.count
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        let inRange = dayReadings.filter { !$0.isLow && !$0.isHigh }.count
        let inRangePercent = dayReadings.isEmpty ? 0 : (inRange * 100) / dayReadings.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Glucosa")
                    .font(.headline)
                Spacer()
                Text("\(dayReadings.count) lecturas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                StatItem(title: "Promedio", value: "\(average)", unit: "mg/dL")
                StatItem(title: "Minimo", value: "\(min)", unit: "mg/dL", color: .red)
                StatItem(title: "Maximo", value: "\(max)", unit: "mg/dL", color: .orange)
                StatItem(title: "En rango", value: "\(inRangePercent)%", unit: "", color: .green)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func colorForStatus(_ status: GlucoseStatus) -> Color {
        switch status {
        case .low: return .red
        case .normal: return .green
        case .high: return .orange
        }
    }
}

// MARK: - Summary Card

private struct SummaryCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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

// MARK: - WorkoutRowView

private struct WorkoutRowView: View {
    let workout: WorkoutModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main row
            HStack {
                Image(systemName: workout.icon)
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(workout.startDate, format: .dateTime.hour().minute())
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

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Extended data row (if available)
            if hasExtendedData {
                HStack(spacing: 16) {
                    if let distance = workout.formattedDistance {
                        WorkoutStatBadge(icon: "figure.run", value: distance)
                    }

                    if let pace = workout.formattedPace {
                        WorkoutStatBadge(icon: "speedometer", value: pace)
                    }

                    if let hr = workout.formattedHeartRate {
                        WorkoutStatBadge(icon: "heart.fill", value: hr, color: .red)
                    }
                }
                .padding(.leading, 40)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private var hasExtendedData: Bool {
        workout.formattedDistance != nil ||
        workout.formattedPace != nil ||
        workout.formattedHeartRate != nil
    }
}

// MARK: - WorkoutStatBadge

private struct WorkoutStatBadge: View {
    let icon: String
    let value: String
    var color: Color = .secondary

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(value)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
