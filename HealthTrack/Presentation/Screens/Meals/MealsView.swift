//
//  MealsView.swift
//  HealthTrack
//

import SwiftUI

struct MealsView: View {

    // MARK: - Properties

    @State var viewModel: MealsViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's summary
                todaySummaryCard

                // Today's meals
                todayMealsSection

                // Quick add
                quickAddSection
            }
            .padding()
        }
        .navigationTitle("Nutricion")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.didTapAddMeal()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddMeal) {
            AddMealBuilder.build(
                initialTime: Date(),
                onMealSaved: { meal in
                    viewModel.addMeal(meal)
                }
            )
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Subviews

    private var todaySummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resumen de hoy")
                .font(.headline)

            HStack(spacing: 0) {
                NutritionSummaryItem(
                    title: "Calorias",
                    value: "\(Int(viewModel.todayCalories))",
                    unit: "kcal",
                    color: .orange
                )

                Divider()
                    .frame(height: 50)

                NutritionSummaryItem(
                    title: "Proteina",
                    value: "\(Int(viewModel.todayProtein))",
                    unit: "g",
                    color: .red
                )

                Divider()
                    .frame(height: 50)

                NutritionSummaryItem(
                    title: "Carbos",
                    value: "\(Int(viewModel.todayCarbs))",
                    unit: "g",
                    color: .blue
                )

                Divider()
                    .frame(height: 50)

                NutritionSummaryItem(
                    title: "Grasa",
                    value: "\(Int(viewModel.todayFat))",
                    unit: "g",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var todayMealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Comidas de hoy")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.todayMeals.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else if viewModel.todayMeals.isEmpty {
                emptyMealsView
            } else {
                ForEach(viewModel.todayMeals) { meal in
                    MealCard(meal: meal)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Registrar comida")
                .font(.headline)

            HStack(spacing: 12) {
                QuickMealButton(
                    title: "Desayuno",
                    icon: "sunrise.fill",
                    color: .orange
                ) {
                    viewModel.didTapQuickAdd(mealName: "Desayuno")
                }

                QuickMealButton(
                    title: "Almuerzo",
                    icon: "sun.max.fill",
                    color: .yellow
                ) {
                    viewModel.didTapQuickAdd(mealName: "Almuerzo")
                }

                QuickMealButton(
                    title: "Cena",
                    icon: "moon.fill",
                    color: .purple
                ) {
                    viewModel.didTapQuickAdd(mealName: "Cena")
                }

                QuickMealButton(
                    title: "Snack",
                    icon: "leaf.fill",
                    color: .green
                ) {
                    viewModel.didTapQuickAdd(mealName: "Snack")
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var emptyMealsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)

            Text("No hay comidas registradas")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                viewModel.didTapAddMeal()
            } label: {
                Text("Registrar comida")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

// MARK: - NutritionSummaryItem

private struct NutritionSummaryItem: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(color)

            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - MealCard

private struct MealCard: View {
    let meal: MealModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundStyle(.green)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(meal.timestamp, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(meal.totalNutrition.formattedCalories)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("\(Int(meal.totalNutrition.proteins))g prot")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !meal.items.isEmpty {
                Text(meal.items.map { $0.name }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .padding(.leading, 40)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - QuickMealButton

private struct QuickMealButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
