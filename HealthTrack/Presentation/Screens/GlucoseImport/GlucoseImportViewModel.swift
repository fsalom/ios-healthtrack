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
}

@Observable
final class GlucoseImportViewModel {

    // MARK: - Properties

    var readings: [GlucoseReadingModel] = []
    var hourlyActivity: [HourlyActivityModel] = []
    var workouts: [WorkoutModel] = []
    var isLoading: Bool = false
    var showingFilePicker: Bool = false
    var hasImportedData: Bool = false
    var importedFileName: String = ""
    var healthKitAuthorized: Bool = false
    var showActivityData: Bool = true

    // Day navigation
    var selectedDay: Date = Date()
    var hourRange: HourRange = .fullDay

    let targetLow: Int = 70
    let targetHigh: Int = 180

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

    // Readings for the selected day filtered by hour range
    var selectedDayReadings: [GlucoseReadingModel] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDay)

        return readings.filter { reading in
            let readingDayStart = calendar.startOfDay(for: reading.timestamp)
            guard readingDayStart == dayStart else { return false }

            let hour = calendar.component(.hour, from: reading.timestamp)
            return hour >= hourRange.start && hour < hourRange.end
        }
    }

    // Activity for the selected day filtered by hour range
    var selectedDayActivity: [HourlyActivityModel] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDay)

        return hourlyActivity.filter { activity in
            let activityDayStart = calendar.startOfDay(for: activity.hour)
            guard activityDayStart == dayStart else { return false }

            let hour = calendar.component(.hour, from: activity.hour)
            return hour >= hourRange.start && hour < hourRange.end
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

    // MARK: - Init

    init(
        router: Router,
        importUseCase: ImportGlucoseDataUseCaseProtocol = ImportGlucoseDataUseCase(),
        fetchActivityUseCase: FetchActivityDataUseCaseProtocol = FetchActivityDataUseCase()
    ) {
        self.router = router
        self.importUseCase = importUseCase
        self.fetchActivityUseCase = fetchActivityUseCase
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

            // Fetch activity data for the same date range
            if hasImportedData {
                Task {
                    await fetchActivityData()
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
}
