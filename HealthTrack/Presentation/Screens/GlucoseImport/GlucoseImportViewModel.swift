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
    var hasGlucoseData: Bool = false
    var importedFileName: String = ""
    var healthKitAuthorized: Bool = false
    var showGlucoseData: Bool = true
    var showMealData: Bool = true
    var hasLoadedInitialData: Bool = false

    // Day navigation - defaults to today
    var selectedDay: Date = Calendar.current.startOfDay(for: Date())
    var hourRange: HourRange = .fullDay

    // Chart zoom state
    var zoomState: ChartZoomState = .defaultState

    let targetLow: Int = 70
    let targetHigh: Int = 180

    // Dynamic chart Y scale - minimum 180, or higher if readings exceed it
    var chartYMax: Int {
        guard hasGlucoseData else { return 180 }
        let maxReading = selectedDayReadings.map { $0.valueInMgPerDl }.max() ?? 180
        // Round up to nearest 20 for cleaner axis labels
        let rounded = ((max(maxReading, 180) + 19) / 20) * 20
        return rounded
    }

    var latestReading: GlucoseReadingModel? {
        readings.first
    }

    // Today's total steps
    var todayTotalSteps: Int {
        selectedDayActivity.reduce(into: 0) { result, activity in
            result += activity.steps
        }
    }

    // Today's total calories burned
    var todayTotalCalories: Int {
        selectedDayWorkouts.reduce(into: 0) { result, workout in
            result += Int(workout.activeCalories)
        }
    }

    // Navigation is based on today +/- days, not glucose data
    var canGoToPreviousDay: Bool {
        // Can go back up to 30 days
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return selectedDay > thirtyDaysAgo
    }

    var canGoToNextDay: Bool {
        // Can't go past today
        let today = Calendar.current.startOfDay(for: Date())
        return selectedDay < today
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

    /// Called on appear to load today's data
    @MainActor
    func loadInitialData() async {
        guard !hasLoadedInitialData else { return }
        hasLoadedInitialData = true
        isLoading = true

        do {
            try await fetchActivityUseCase.requestAuthorization()
            healthKitAuthorized = true
        } catch {
            print("HealthKit authorization error: \(error.localizedDescription)")
        }

        await fetchActivityForSelectedDay()
        await fetchMealsForSelectedDay()
        isLoading = false
    }

    @MainActor
    func fetchActivityForSelectedDay() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDay)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        do {
            let activityData = try await fetchActivityUseCase.execute(
                from: startOfDay,
                to: endOfDay
            )
            // Merge with existing data, avoiding duplicates
            let existingIds = Set(hourlyActivity.map { $0.id })
            let newActivity = activityData.hourlySteps.filter { !existingIds.contains($0.id) }
            hourlyActivity.append(contentsOf: newActivity)

            let existingWorkoutIds = Set(workouts.map { $0.id })
            let newWorkouts = activityData.workouts.filter { !existingWorkoutIds.contains($0.id) }
            workouts.append(contentsOf: newWorkouts)

            healthKitAuthorized = true
        } catch {
            print("HealthKit error: \(error.localizedDescription)")
        }
    }

    @MainActor
    func fetchMealsForSelectedDay() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDay)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        do {
            let dayMeals = try await getMealsUseCase.execute(from: startOfDay, to: endOfDay)
            // Merge avoiding duplicates
            let existingIds = Set(meals.map { $0.id })
            let newMeals = dayMeals.filter { !existingIds.contains($0.id) }
            meals.append(contentsOf: newMeals)
        } catch {
            print("Error fetching meals: \(error.localizedDescription)")
        }
    }

    func importFile(from url: URL) {
        isLoading = true

        do {
            readings = try importUseCase.execute(from: url)
            hasGlucoseData = !readings.isEmpty
            importedFileName = url.lastPathComponent

            // If we have glucose data, select the most recent day with readings
            if hasGlucoseData, let mostRecentReading = readings.first {
                selectedDay = Calendar.current.startOfDay(for: mostRecentReading.timestamp)
                // Fetch activity for the glucose date range
                Task {
                    await fetchActivityForSelectedDay()
                    await fetchMealsForSelectedDay()
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

    func clearGlucoseData() {
        readings = []
        hasGlucoseData = false
        importedFileName = ""
        selectedDay = Calendar.current.startOfDay(for: Date())
    }

    func toggleGlucoseData() {
        showGlucoseData.toggle()
    }

    func toggleMealData() {
        showMealData.toggle()
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
        guard canGoToPreviousDay else { return }
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDay) {
            selectedDay = Calendar.current.startOfDay(for: previousDay)
            Task {
                await fetchActivityForSelectedDay()
                await fetchMealsForSelectedDay()
            }
        }
    }

    func goToNextDay() {
        guard canGoToNextDay else { return }
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDay) {
            selectedDay = Calendar.current.startOfDay(for: nextDay)
            Task {
                await fetchActivityForSelectedDay()
                await fetchMealsForSelectedDay()
            }
        }
    }

    func selectDay(_ date: Date) {
        selectedDay = Calendar.current.startOfDay(for: date)
        Task {
            await fetchActivityForSelectedDay()
            await fetchMealsForSelectedDay()
        }
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
