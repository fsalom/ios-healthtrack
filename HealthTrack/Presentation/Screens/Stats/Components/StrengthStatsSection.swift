//
//  StrengthStatsSection.swift
//  HealthTrack
//

import SwiftUI
import Charts

struct StrengthStatsSection: View {

    // MARK: - Properties

    let stats: StrengthStatsModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                personalRecordsCard
                weeklyVolumeCard
                frequentExercisesCard
            }
            .padding()
        }
    }

    // MARK: - Subviews

    private var personalRecordsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Records Personales", systemImage: "trophy.fill")
                .font(.headline)
                .foregroundStyle(.orange)

            if stats.personalRecords.isEmpty {
                emptyState(message: "No hay records registrados")
            } else {
                VStack(spacing: 0) {
                    ForEach(stats.personalRecords) { record in
                        PersonalRecordRow(
                            exerciseName: record.exerciseName,
                            weight: record.formattedWeight,
                            date: record.formattedDate
                        )

                        if record.id != stats.personalRecords.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var weeklyVolumeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Volumen Semanal", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundStyle(.blue)

            if stats.weeklyVolumes.isEmpty {
                emptyState(message: "No hay datos de volumen")
            } else {
                Chart(stats.weeklyVolumes) { volume in
                    BarMark(
                        x: .value("Semana", volume.weekLabel),
                        y: .value("Volumen", volume.volume)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Esta semana")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(stats.formattedCurrentWeekVolume)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    if let change = stats.formattedVolumeChange {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("vs anterior")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(change)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(stats.weeklyVolumeChange ?? 0 >= 0 ? .green : .red)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var frequentExercisesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Ejercicios Frecuentes", systemImage: "dumbbell.fill")
                .font(.headline)
                .foregroundStyle(.purple)

            if stats.frequentExercises.isEmpty {
                emptyState(message: "No hay ejercicios registrados")
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(stats.frequentExercises.enumerated()), id: \.element.id) { index, exercise in
                        HStack {
                            Text("\(index + 1).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 24, alignment: .leading)

                            Text(exercise.exerciseName)
                                .font(.subheadline)
                                .lineLimit(1)

                            Spacer()

                            Text(exercise.formattedCount)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
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
