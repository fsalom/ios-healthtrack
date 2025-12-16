//
//  CustomTabbar.swift
//  Gula
//
//  Created by Eduard on 3/9/25.
//

import SwiftUI

// MARK: Example tabs, replace with your actual tabs
enum TabItem: Int, CaseIterable, Identifiable {
    case login
    case images
    case documents

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .login: return "Login"
        case .images: return "Images"
        case .documents: return "Documents"
        }
    }

    var systemImage: String {
        switch self {
        case .login: return "paperplane.fill"
        case .images: return "photo.fill"
        case .documents: return "document.fill"
        }
    }

    var color: Color {
        switch self {
        case .login: return .blue
        case .images: return .yellow
        case .documents: return .green
        }
    }

    var badge: Int {
        switch self {
        case .login: return 0
        case .images: return 0
        case .documents: return 0
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .login:
            // TODO: - Change at correct screen
            Text("Login")
        case .images:
            // TODO: - Change at correct screen
            Text("Images")
        case .documents:
            // TODO: - Change at correct screen
            Text("Documents")
        }
    }
}

// MARK: - CustomTabBar
struct CustomTabBar: View {
    @State private var navigator = Navigator.shared
    private var config: TabBarConfig

    init(initialTab: TabItem = .login) {
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
