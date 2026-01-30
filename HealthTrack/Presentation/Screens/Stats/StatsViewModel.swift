//
//  StatsViewModel.swift
//  HealthTrack
//

import Foundation

enum StatsTab: Int, CaseIterable {
    case strength
    case activity
    case nutrition

    var title: String {
        switch self {
        case .strength: return "Fuerza"
        case .activity: return "Actividad"
        case .nutrition: return "Nutricion"
        }
    }

    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .activity: return "figure.run"
        case .nutrition: return "fork.knife"
        }
    }
}

@Observable
final class StatsViewModel {

    // MARK: - Properties

    var selectedTab: StatsTab = .strength
    private(set) var strengthStats: StrengthStatsModel = .empty
    private(set) var activityStats: ActivityStatsModel = .empty
    private(set) var nutritionStats: NutritionStatsModel = .empty
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    private let router: Router
    private let getStrengthStatsUseCase: GetStrengthStatsUseCaseProtocol
    private let getActivityStatsUseCase: GetActivityStatsUseCaseProtocol
    private let getNutritionStatsUseCase: GetNutritionStatsUseCaseProtocol

    // MARK: - Init

    init(
        router: Router,
        getStrengthStatsUseCase: GetStrengthStatsUseCaseProtocol,
        getActivityStatsUseCase: GetActivityStatsUseCaseProtocol,
        getNutritionStatsUseCase: GetNutritionStatsUseCaseProtocol
    ) {
        self.router = router
        self.getStrengthStatsUseCase = getStrengthStatsUseCase
        self.getActivityStatsUseCase = getActivityStatsUseCase
        self.getNutritionStatsUseCase = getNutritionStatsUseCase
    }

    // MARK: - Public Methods

    @MainActor
    func loadAllStats() async {
        isLoading = true
        errorMessage = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadStrengthStats() }
            group.addTask { await self.loadActivityStats() }
            group.addTask { await self.loadNutritionStats() }
        }

        isLoading = false
    }

    @MainActor
    func loadStatsForSelectedTab() async {
        isLoading = true
        errorMessage = nil

        switch selectedTab {
        case .strength:
            await loadStrengthStats()
        case .activity:
            await loadActivityStats()
        case .nutrition:
            await loadNutritionStats()
        }

        isLoading = false
    }

    func dismiss() {
        router.dismissSheet()
    }

    // MARK: - Private Methods

    @MainActor
    private func loadStrengthStats() async {
        do {
            strengthStats = try await getStrengthStatsUseCase.execute()
        } catch {
            print("Error loading strength stats: \(error)")
        }
    }

    @MainActor
    private func loadActivityStats() async {
        do {
            activityStats = try await getActivityStatsUseCase.execute()
        } catch {
            print("Error loading activity stats: \(error)")
        }
    }

    @MainActor
    private func loadNutritionStats() async {
        do {
            nutritionStats = try await getNutritionStatsUseCase.execute()
        } catch {
            print("Error loading nutrition stats: \(error)")
        }
    }
}
