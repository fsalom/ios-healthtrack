//
//  StatsView.swift
//  HealthTrack
//

import SwiftUI

struct StatsView: View {

    // MARK: - Properties

    @State var viewModel: StatsViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabSelector
                    .padding(.horizontal)
                    .padding(.top, 8)

                Divider()
                    .padding(.top, 12)

                if viewModel.isLoading {
                    loadingView
                } else {
                    tabContent
                }
            }
            .navigationTitle("Estadisticas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task {
                await viewModel.loadAllStats()
            }
        }
    }

    // MARK: - Subviews

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(StatsTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(viewModel.selectedTab == tab ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.selectedTab == tab ? Color(.tertiarySystemBackground) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Cargando estadisticas...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 12)
            Spacer()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .strength:
            StrengthStatsSection(stats: viewModel.strengthStats)
        case .activity:
            ActivityStatsSection(stats: viewModel.activityStats)
        case .nutrition:
            NutritionStatsSection(stats: viewModel.nutritionStats)
        }
    }
}
