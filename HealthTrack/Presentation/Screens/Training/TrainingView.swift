//
//  TrainingView.swift
//  HealthTrack
//

import SwiftUI

struct TrainingView: View {

    // MARK: - Properties

    @State var viewModel: TrainingViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick start section
                quickStartSection

                // Recent workouts
                recentWorkoutsSection

                // Weekly summary
                weeklySummarySection
            }
            .padding()
        }
        .navigationTitle("Entreno")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.didTapStartWorkout()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingWorkoutDetail) {
            if let workout = viewModel.selectedWorkout {
                WorkoutDetailBuilder.build(workout: workout)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Subviews

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inicio rapido")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickStartCard(
                    title: "Fuerza",
                    icon: "dumbbell.fill",
                    color: .orange
                ) {
                    viewModel.didTapQuickStart(type: .strengthTraining)
                }

                QuickStartCard(
                    title: "Cardio",
                    icon: "figure.run",
                    color: .green
                ) {
                    viewModel.didTapQuickStart(type: .running)
                }

                QuickStartCard(
                    title: "HIIT",
                    icon: "bolt.heart.fill",
                    color: .red
                ) {
                    viewModel.didTapQuickStart(type: .hiit)
                }

                QuickStartCard(
                    title: "Yoga",
                    icon: "figure.yoga",
                    color: .purple
                ) {
                    viewModel.didTapQuickStart(type: .yoga)
                }
            }
        }
    }

    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Entrenamientos recientes")
                    .font(.headline)
                Spacer()
                if !viewModel.recentWorkouts.isEmpty {
                    Text("\(viewModel.recentWorkouts.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else if viewModel.recentWorkouts.isEmpty {
                emptyWorkoutsView
            } else {
                ForEach(viewModel.recentWorkouts) { workout in
                    WorkoutCard(workout: workout) {
                        viewModel.didTapWorkout(workout)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Esta semana")
                .font(.headline)

            HStack(spacing: 0) {
                SummaryItem(
                    title: "Sesiones",
                    value: "\(viewModel.weeklyWorkoutCount)",
                    icon: "flame.fill",
                    color: .orange
                )

                Divider()
                    .frame(height: 50)

                SummaryItem(
                    title: "Tiempo",
                    value: viewModel.formattedWeeklyDuration,
                    icon: "clock.fill",
                    color: .blue
                )

                Divider()
                    .frame(height: 50)

                SummaryItem(
                    title: "Calorias",
                    value: viewModel.formattedWeeklyCalories,
                    icon: "bolt.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var emptyWorkoutsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)

            Text("No hay entrenamientos recientes")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                viewModel.didTapStartWorkout()
            } label: {
                Text("Empezar entreno")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

// MARK: - QuickStartCard

private struct QuickStartCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - WorkoutCard

private struct WorkoutCard: View {
    let workout: WorkoutModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: workout.icon)
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(workout.startDate, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(workout.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(workout.formattedCalories)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SummaryItem

private struct SummaryItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
