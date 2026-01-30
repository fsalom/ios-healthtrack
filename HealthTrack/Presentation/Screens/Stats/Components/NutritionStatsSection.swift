//
//  NutritionStatsSection.swift
//  HealthTrack
//

import SwiftUI
import Charts

struct NutritionStatsSection: View {

    // MARK: - Properties

    let stats: NutritionStatsModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                energyBalanceCard
                macrosCard
                weeklyTrendCard
            }
            .padding()
        }
    }

    // MARK: - Subviews

    private var energyBalanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Balance Energetico", systemImage: "scalemass.fill")
                .font(.headline)
                .foregroundStyle(.green)

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Consumido")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(stats.todayBalance.formattedConsumed)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("vs")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Image(systemName: stats.todayBalance.isDeficit ? "arrow.down" : "arrow.up")
                        .font(.title3)
                        .foregroundStyle(stats.todayBalance.isDeficit ? .green : .orange)
                }

                VStack(spacing: 4) {
                    Text("Quemado")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(stats.todayBalance.formattedBurned)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }

            Divider()

            HStack {
                Text(stats.todayBalance.isDeficit ? "Deficit" : "Superavit")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(stats.todayBalance.formattedDeficit)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(stats.todayBalance.isDeficit ? .green : .orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var macrosCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Distribucion de Macros (hoy)", systemImage: "chart.pie.fill")
                .font(.headline)
                .foregroundStyle(.purple)

            if stats.todayMacros.total == 0 {
                emptyState(message: "No hay datos de macros")
            } else {
                MacrosPieChart(macros: stats.todayMacros)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var weeklyTrendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Tendencia Semanal", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(.blue)

            if stats.weeklyCaloriesConsumed.isEmpty {
                emptyState(message: "No hay datos de tendencia")
            } else {
                NutritionCaloriesChart(data: stats.weeklyCaloriesConsumed)
                    .frame(height: 150)

                HStack {
                    Text("Promedio")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(stats.formattedAverageCalories + "/dia")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func emptyState(message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 20)
    }
}
