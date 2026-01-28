//
//  WorkoutDetailView.swift
//  HealthTrack
//

import SwiftUI

struct WorkoutDetailView: View {

    // MARK: - Properties

    @State var viewModel: WorkoutDetailViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    workoutSummaryCard

                    if viewModel.workout.hasDistanceData {
                        cardioStatsCard
                    }

                    if viewModel.workout.isStrengthBased {
                        exercisesSection
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.workout.displayName)
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
            .sheet(isPresented: $viewModel.showingAddExercise) {
                AddExerciseBuilder.build { exercise in
                    viewModel.addExercise(exercise)
                }
            }
            .task {
                await viewModel.loadWorkoutDetail()
            }
        }
    }

    // MARK: - Subviews

    private var workoutSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: viewModel.workout.icon)
                    .font(.largeTitle)
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.workout.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(viewModel.workout.startDate, format: .dateTime.weekday(.wide).day().month().hour().minute())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            HStack(spacing: 0) {
                StatBox(title: "Duracion", value: viewModel.workout.formattedDuration, icon: "clock")
                StatBox(title: "Calorias", value: viewModel.workout.formattedCalories, icon: "flame.fill")

                if let hr = viewModel.workout.formattedHeartRate {
                    StatBox(title: "FC Media", value: hr, icon: "heart.fill")
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var cardioStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadisticas")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                if let distance = viewModel.workout.formattedDistance {
                    CardioStatItem(title: "Distancia", value: distance, icon: "figure.run")
                }

                if let pace = viewModel.workout.formattedPace {
                    CardioStatItem(title: "Ritmo medio", value: pace, icon: "speedometer")
                }

                if let maxHR = viewModel.workout.maxHeartRate {
                    CardioStatItem(title: "FC Maxima", value: "\(Int(maxHR)) bpm", icon: "heart.fill")
                }

                if let elevation = viewModel.workout.formattedElevation {
                    CardioStatItem(title: "Desnivel", value: elevation, icon: "arrow.up.right")
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ejercicios")
                    .font(.headline)

                Spacer()

                Button {
                    viewModel.didTapAddExercise()
                } label: {
                    Label("Anadir", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                }
            }

            if let detail = viewModel.workoutDetail, !detail.exercises.isEmpty {
                ForEach(detail.exercises) { exercise in
                    ExerciseRowView(exercise: exercise) {
                        viewModel.deleteExercise(exercise)
                    }
                }

                HStack {
                    Text("Volumen total")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(detail.formattedVolume)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.top, 8)
            } else {
                Text("No hay ejercicios registrados")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - StatBox

private struct StatBox: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - CardioStatItem

private struct CardioStatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - ExerciseRowView

private struct ExerciseRowView: View {
    let exercise: ExerciseModel
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(exercise.formattedSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }

            if !exercise.sets.isEmpty {
                HStack(spacing: 8) {
                    ForEach(exercise.sets) { set in
                        SetBadge(set: set)
                    }
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - SetBadge

private struct SetBadge: View {
    let set: SetModel

    var body: some View {
        VStack(spacing: 2) {
            Text("\(set.reps)")
                .font(.caption)
                .fontWeight(.semibold)
            if set.weight > 0 {
                Text("\(Int(set.weight))kg")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(set.isWarmup ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
