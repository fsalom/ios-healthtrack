//
//  GlucoseImportViewModel.swift
//  HealthTrack
//

import Foundation
import UniformTypeIdentifiers

// MARK: - HourRange

struct HourRange: Equatable {
    var start: Int
    var end: Int

    static let fullDay = HourRange(start: 0, end: 24)
    static let morning = HourRange(start: 6, end: 12)
    static let afternoon = HourRange(start: 12, end: 18)
    static let evening = HourRange(start: 18, end: 24)
    static let night = HourRange(start: 0, end: 6)

    var duration: Int { end - start }
}

// MARK: - ChartZoomState

struct ChartZoomState: Equatable {
    var visibleHours: Double = 24  // 2 to 24 hours
    var centerHour: Double = 12     // 0 to 24

    static let defaultState = ChartZoomState(visibleHours: 24, centerHour: 12)

    var startHour: Double {
        max(0, centerHour - visibleHours / 2)
    }

    var endHour: Double {
        min(24, centerHour + visibleHours / 2)
    }

    var effectiveStart: Double {
        // Adjust if we're at boundaries
        if endHour >= 24 {
            return max(0, 24 - visibleHours)
        }
        return startHour
    }

    var effectiveEnd: Double {
        if startHour <= 0 {
            return min(24, visibleHours)
        }
        return endHour
    }

    var zoomLevel: Double {
        // 1.0 = full day, higher = more zoom
        24.0 / visibleHours
    }

    mutating func zoom(by factor: Double) {
        let newHours = max(2, min(24, visibleHours / factor))
        visibleHours = newHours
        // Clamp center to keep view within bounds
        clampCenter()
    }

    mutating func pan(by hours: Double) {
        centerHour += hours
        clampCenter()
    }

    private mutating func clampCenter() {
        let halfVisible = visibleHours / 2
        centerHour = max(halfVisible, min(24 - halfVisible, centerHour))
    }

    mutating func reset() {
        self = .defaultState
    }
}

@Observable
final class GlucoseImportViewModel {

    // MARK: - Properties

    var readings: [GlucoseReadingModel] = []
    var hourlyActivity: [HourlyActivityModel] = []
    var workouts: [WorkoutModel] = []
    var meals: [MealModel] = []
    var isLoading: Bool = false
    var showingFilePicker: Bool = false
    var showingAddMeal: Bool = false
    var addMealTime: Date = Date()
    var hasImportedData: Bool = false
    var importedFileName: String = ""
    var healthKitAuthorized: Bool = false
    var showActivityData: Bool = true
    var showMealData: Bool = true

    // Day navigation
    var selectedDay: Date = Date()
    var hourRange: HourRange = .fullDay

    // Chart zoom state
    var zoomState: ChartZoomState = .defaultState

    let targetLow: Int = 70
    let targetHigh: Int = 180

    // Dynamic chart Y scale - minimum 180, or higher if readings exceed it
    var chartYMax: Int {
        let maxReading = selectedDayReadings.map { $0.valueInMgPerDl }.max() ?? 180
        // Round up to nearest 20 for cleaner axis labels
        let rounded = ((max(maxReading, 180) + 19) / 20) * 20
        return rounded
    }

    var latestReading: GlucoseReadingModel? {
        readings.first
    }

    // Available days from imported data
    var availableDays: [Date] {
        let grouped = Dictionary(grouping: readings) { reading in
            Calendar.current.startOfDay(for: reading.timestamp)
        }
        return grouped.keys.sorted()
    }

    var selectedDayIndex: Int? {
        let dayStart = Calendar.current.startOfDay(for: selectedDay)
        return availableDays.firstIndex(of: dayStart)
    }

    var canGoToPreviousDay: Bool {
        guard let index = selectedDayIndex else { return false }
        return index > 0
    }

    var canGoToNextDay: Bool {
        guard let index = selectedDayIndex else { return false }
        return index < availableDays.count - 1
    }

    // Chart time boundaries based on zoom
    var chartStartTime: Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDay)
        let startHour = Int(zoomState.effectiveStart)
        let startMinute = Int((zoomState.effectiveStart - Double(startHour)) * 60)
        return calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: startOfDay) ?? startOfDay
    }

    var chartEndTime: Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDay)
        var endHour = Int(zoomState.effectiveEnd)
        var endMinute = Int((zoomState.effectiveEnd - Double(endHour)) * 60)
        if endHour >= 24 {
            endHour = 23
            endMinute = 59
        }
        return calendar.date(bySettingHour: endHour, minute: endMinute, second: 59, of: startOfDay) ?? startOfDay
    }

    // Readings for the selected day (all readings, chart will clip)
    var selectedDayReadings: [GlucoseReadingModel] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDay)

        return readings.filter { reading in
            let readingDayStart = calendar.startOfDay(for: reading.timestamp)
            return readingDayStart == dayStart
        }
    }

    // Activity for the selected day
    var selectedDayActivity: [HourlyActivityModel] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDay)

        return hourlyActivity.filter { activity in
            let activityDayStart = calendar.startOfDay(for: activity.hour)
            return activityDayStart == dayStart
        }
    }

    // Workouts for the selected day
    var selectedDayWorkouts: [WorkoutModel] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDay)

        return workouts.filter { workout in
            let workoutDayStart = calendar.startOfDay(for: workout.startDate)
            return workoutDayStart == dayStart
        }
    }

    // Meals for the selected day
    var selectedDayMeals: [MealModel] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDay)

        return meals.filter { meal in
            let mealDayStart = calendar.startOfDay(for: meal.timestamp)
            return mealDayStart == dayStart
        }.sorted { $0.timestamp < $1.timestamp }
    }

    var selectedDayMaxSteps: Int {
        selectedDayActivity.map { $0.steps }.max() ?? 1000
    }

    var readingsGroupedByDay: [Date: [GlucoseReadingModel]] {
        Dictionary(grouping: readings) { reading in
            Calendar.current.startOfDay(for: reading.timestamp)
        }
    }

    var sortedDays: [Date] {
        readingsGroupedByDay.keys.sorted(by: >)
    }

    var dateRange: (start: Date, end: Date)? {
        guard let first = readings.last?.timestamp,
              let last = readings.first?.timestamp else {
            return nil
        }
        return (first, last)
    }

    var maxStepsPerHour: Int {
        hourlyActivity.map { $0.steps }.max() ?? 1000
    }

    private let router: Router
    private let importUseCase: ImportGlucoseDataUseCaseProtocol
    private let fetchActivityUseCase: FetchActivityDataUseCaseProtocol
    private let getMealsUseCase: GetMealsUseCaseProtocol

    // MARK: - Init

    init(
        router: Router,
        importUseCase: ImportGlucoseDataUseCaseProtocol = ImportGlucoseDataUseCase(),
        fetchActivityUseCase: FetchActivityDataUseCaseProtocol = FetchActivityDataUseCase(),
        getMealsUseCase: GetMealsUseCaseProtocol = GetMealsUseCase(repository: MealRepository())
    ) {
        self.router = router
        self.importUseCase = importUseCase
        self.fetchActivityUseCase = fetchActivityUseCase
        self.getMealsUseCase = getMealsUseCase
    }

    // MARK: - Public Methods

    func importFile(from url: URL) {
        isLoading = true

        do {
            readings = try importUseCase.execute(from: url)
            hasImportedData = !readings.isEmpty
            importedFileName = url.lastPathComponent

            // Set selected day to the most recent day with data
            if let mostRecentDay = availableDays.last {
                selectedDay = mostRecentDay
            }

            // Fetch activity data and meals for the same date range
            if hasImportedData {
                Task {
                    await fetchActivityData()
                    await fetchMeals()
                }
            }
        } catch {
            router.showAlert(
                title: "Error",
                message: error.localizedDescription
            )
        }

        isLoading = false
    }

    func openFilePicker() {
        showingFilePicker = true
    }

    func clearData() {
        readings = []
        hourlyActivity = []
        workouts = []
        meals = []
        hasImportedData = false
        importedFileName = ""
    }

    func requestHealthKitAuthorization() async {
        do {
            try await fetchActivityUseCase.requestAuthorization()
            healthKitAuthorized = true
            await fetchActivityData()
        } catch {
            router.showAlert(
                title: "HealthKit",
                message: "No se pudieron obtener los permisos de HealthKit"
            )
        }
    }

    @MainActor
    func fetchActivityData() async {
        guard let range = dateRange else { return }

        do {
            let activityData = try await fetchActivityUseCase.execute(
                from: range.start,
                to: range.end
            )
            hourlyActivity = activityData.hourlySteps
            workouts = activityData.workouts
            healthKitAuthorized = true
        } catch {
            // HealthKit may not be authorized yet, don't show error
            print("HealthKit error: \(error.localizedDescription)")
        }
    }

    func toggleActivityData() {
        showActivityData.toggle()
    }

    func toggleMealData() {
        showMealData.toggle()
    }

    // MARK: - Meal Methods

    @MainActor
    func fetchMeals() async {
        guard let range = dateRange else { return }

        do {
            meals = try await getMealsUseCase.execute(from: range.start, to: range.end)
        } catch {
            print("Error fetching meals: \(error.localizedDescription)")
        }
    }

    func didTapAddMealAtTime(_ time: Date) {
        addMealTime = time
        showingAddMeal = true
    }

    func addMeal(_ meal: MealModel) {
        meals.append(meal)
        meals.sort { $0.timestamp < $1.timestamp }
    }

    // MARK: - Day Navigation

    func goToPreviousDay() {
        guard let index = selectedDayIndex, index > 0 else { return }
        selectedDay = availableDays[index - 1]
    }

    func goToNextDay() {
        guard let index = selectedDayIndex, index < availableDays.count - 1 else { return }
        selectedDay = availableDays[index + 1]
    }

    func selectDay(_ date: Date) {
        let dayStart = Calendar.current.startOfDay(for: date)
        if availableDays.contains(dayStart) {
            selectedDay = dayStart
        }
    }

    func setHourRange(_ range: HourRange) {
        hourRange = range
    }

    // MARK: - Chart Zoom

    func zoomIn() {
        zoomState.zoom(by: 1.5)
    }

    func zoomOut() {
        zoomState.zoom(by: 0.67)
    }

    func handleZoomGesture(scale: Double, initialHours: Double) {
        // Apply zoom relative to initial state, with dampening for smoother control
        let dampening = 0.5 // Makes zoom less aggressive
        let adjustedScale = 1 + (scale - 1) * dampening
        let newHours = initialHours / adjustedScale
        zoomState.visibleHours = max(2, min(24, newHours))

        // Keep center within bounds
        let halfVisible = zoomState.visibleHours / 2
        zoomState.centerHour = max(halfVisible, min(24 - halfVisible, zoomState.centerHour))
    }

    func handlePanGesture(translation: Double, chartWidth: Double) {
        // Convert pixel translation to hours
        let hoursPerPixel = zoomState.visibleHours / chartWidth
        let hoursDelta = -translation * hoursPerPixel
        zoomState.pan(by: hoursDelta)
    }

    func resetZoom() {
        zoomState.reset()
    }

    func setVisibleHours(_ hours: Double) {
        zoomState.visibleHours = max(2, min(24, hours))
        // Recalculate center to stay in bounds
        let halfVisible = zoomState.visibleHours / 2
        zoomState.centerHour = max(halfVisible, min(24 - halfVisible, zoomState.centerHour))
    }

    var isZoomed: Bool {
        zoomState.visibleHours < 24
    }
}
