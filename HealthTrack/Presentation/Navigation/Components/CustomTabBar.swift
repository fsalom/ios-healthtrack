//
//  CustomTabbar.swift
//  Gula
//
//  Created by Eduard on 3/9/25.
//

import SwiftUI

enum TabItem: Int, CaseIterable, Identifiable {
    case activity
    case training
    case nutrition
    case stats

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .activity: return "Actividad"
        case .training: return "Entreno"
        case .nutrition: return "Nutricion"
        case .stats: return "Stats"
        }
    }

    var systemImage: String {
        switch self {
        case .activity: return "figure.walk"
        case .training: return "dumbbell.fill"
        case .nutrition: return "fork.knife"
        case .stats: return "chart.bar.fill"
        }
    }

    var color: Color {
        switch self {
        case .activity: return .blue
        case .training: return .orange
        case .nutrition: return .green
        case .stats: return .purple
        }
    }

    var badge: Int {
        switch self {
        case .activity: return 0
        case .training: return 0
        case .nutrition: return 0
        case .stats: return 0
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .activity:
            ActivityTabView()
        case .training:
            TrainingTabView()
        case .nutrition:
            NutritionTabView()
        case .stats:
            StatsTabView()
        }
    }
}

// MARK: - BaseTabView

private struct BaseTabView<Content: View>: View {
    @State private var navigator = Navigator.shared
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationStack(path: $navigator.path) {
            content
                .navigationDestination(for: Page.self) { page in
                    page
                }
        }
        .sheet(item: $navigator.sheet) { page in
            NestedSheetHost(navigator: navigator, content: page)
        }
        .alert(LocalizedStringKey(navigator.alertModel.title), isPresented: $navigator.isPresentingAlert) {
            AnyView(navigator.alertModel.style.buttons)
        } message: {
            Text(LocalizedStringKey(navigator.alertModel.message))
        }
        .overlay(
            VStack {
                Spacer()
                if let toastView = navigator.toastView {
                    AnyView(toastView)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                withAnimation { navigator.toastView = nil }
                            }
                        }
                        .padding(.bottom, 8)
                }
            }
            .ignoresSafeArea(.keyboard)
        )
    }
}

// MARK: - ActivityTabView

struct ActivityTabView: View {
    var body: some View {
        BaseTabView {
            GlucoseImportBuilder.build()
        }
    }
}

// MARK: - TrainingTabView

struct TrainingTabView: View {
    var body: some View {
        BaseTabView {
            TrainingBuilder.build()
        }
    }
}

// MARK: - NutritionTabView

struct NutritionTabView: View {
    var body: some View {
        BaseTabView {
            MealsBuilder.build()
        }
    }
}

// MARK: - StatsTabView

struct StatsTabView: View {
    var body: some View {
        BaseTabView {
            StatsBuilder.build()
        }
    }
}

// MARK: - CustomTabBar
struct CustomTabBar: View {
    @State private var navigator = Navigator.shared
    private var config: TabBarConfig

    init(initialTab: TabItem = .activity) {
        self.config = TabBarConfig.default
        navigator.tabIndex = initialTab.rawValue
        configureTabBarAppearance(config: self.config)
    }

    var body: some View {
        TabView(selection: $navigator.tabIndex) {
            ForEach(TabItem.allCases) { tab in
                tab.view
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                            .foregroundStyle(tab.color)
                    }
                    .tag(tab.rawValue)
                    .badge(navigator.tabBadges[tab] ?? 0)
            }
        }
    }

    private func configureTabBarAppearance(config: TabBarConfig) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = config.backgroundColor
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = config.badgeColor
        appearance.stackedLayoutAppearance.normal.badgeTextAttributes = [.foregroundColor: config.badgeTextColor]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: config.textTabColor]

        appearance.stackedLayoutAppearance.selected.badgeBackgroundColor = config.badgeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: config.selectedTabColor]
        appearance.stackedLayoutAppearance.selected.badgeTextAttributes = [.foregroundColor: config.badgeTextColor]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct TabBarConfig {
    var backgroundColor: UIColor
    var badgeColor: UIColor
    var badgeTextColor: UIColor
    var selectedTabColor: UIColor
    var textTabColor: UIColor

    init(backgroundColor: UIColor = .systemBackground,
         badgeColor: UIColor = .red,
         badgeTextColor: UIColor = .red,
         selectedTabColor: UIColor = .blue,
         textTabColor: UIColor = .black) {
        self.backgroundColor = backgroundColor
        self.badgeColor = badgeColor
        self.badgeTextColor = badgeTextColor
        self.selectedTabColor = selectedTabColor
        self.textTabColor = textTabColor
    }

    static let `default` = TabBarConfig(
        backgroundColor: .systemBackground,
        badgeColor: .green,
        badgeTextColor: .white,
        selectedTabColor: .green,
        textTabColor: .black
    )
}
