//
//  ActivityStatsSection.swift
//  HealthTrack
//

import SwiftUI
import Charts

struct ActivityStatsSection: View {

    // MARK: - Properties

    let stats: ActivityStatsModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                stepsCard
                caloriesCard
                workoutSummaryCard
            }
            .padding()
        }
    }

    // MARK: - Subviews

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Pasos", systemImage: "figure.walk")
                .font(.headline)
                .foregroundStyle(.blue)

            if stats.dailySteps.isEmpty {
                emptyState(message: "No hay datos de pasos")
            } else {
                StepsLineChart(data: stats.dailySteps)
                    .frame(height: 150)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Promedio")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(stats.formattedAverageSteps) pasos/dia")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Esta semana")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(stats.formattedTotalSteps) pasos")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var caloriesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Calorias Quemadas", systemImage: "flame.fill")
                .font(.headline)
                .foregroundStyle(.orange)

            if stats.dailyCaloriesBurned.isEmpty {
                emptyState(message: "No hay datos de calorias")
            } else {
                CaloriesBarChart(data: stats.dailyCaloriesBurned, color: .orange)
                    .frame(height: 150)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Promedio")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(stats.formattedAverageCalories)/dia")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Total semana")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(stats.formattedTotalCalories)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var workoutSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Entrenamientos", systemImage: "figure.run")
                .font(.headline)
                .foregroundStyle(.green)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(stats.workoutCount)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("sesiones")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 50)

                VStack(spacing: 4) {
                    Text(stats.formattedWorkoutDuration)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("tiempo total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
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
