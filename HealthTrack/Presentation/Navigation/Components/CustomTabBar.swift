//
//  CustomTabbar.swift
//  Gula
//
//  Created by Eduard on 3/9/25.
//

import SwiftUI

enum TabItem: Int, CaseIterable, Identifiable {
    case glucose
    case images
    case documents

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .glucose: return "Glucosa"
        case .images: return "Images"
        case .documents: return "Documents"
        }
    }

    var systemImage: String {
        switch self {
        case .glucose: return "drop.fill"
        case .images: return "photo.fill"
        case .documents: return "document.fill"
        }
    }

    var color: Color {
        switch self {
        case .glucose: return .red
        case .images: return .yellow
        case .documents: return .green
        }
    }

    var badge: Int {
        switch self {
        case .glucose: return 0
        case .images: return 0
        case .documents: return 0
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .glucose:
            GlucoseTabView()
        case .images:
            Text("Images")
        case .documents:
            Text("Documents")
        }
    }
}

// MARK: - GlucoseTabView
struct GlucoseTabView: View {
    @State private var navigator = Navigator.shared

    var body: some View {
        NavigationStack(path: $navigator.path) {
            GlucoseImportBuilder.build()
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

// MARK: - CustomTabBar
struct CustomTabBar: View {
    @State private var navigator = Navigator.shared
    private var config: TabBarConfig

    init(initialTab: TabItem = .glucose) {
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
