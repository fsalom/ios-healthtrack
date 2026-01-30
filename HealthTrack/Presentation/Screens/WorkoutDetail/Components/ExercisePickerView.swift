//
//  ExercisePickerView.swift
//  HealthTrack
//

import SwiftUI

struct ExercisePickerView: View {

    // MARK: - Properties

    let exercises: [ExerciseTemplateModel]
    let recentExercises: [ExerciseHistoryModel]
    let onSelect: (ExerciseTemplateModel) -> Void

    @Binding var searchQuery: String
    @Binding var selectedCategory: ExerciseCategory?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
                .padding(.horizontal)
                .padding(.top, 8)

            // Category chips
            categoryChips
                .padding(.vertical, 12)

            // Content
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    // Recent section
                    if !recentExercises.isEmpty && searchQuery.isEmpty && selectedCategory == nil {
                        recentSection
                    }

                    // All exercises
                    exercisesSection
                }
                .padding()
            }
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Buscar ejercicio...", text: $searchQuery)
                .textFieldStyle(.plain)

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Todos" button
                Button {
                    selectedCategory = nil
                } label: {
                    Text("Todos")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == nil ? Color.blue : Color(.tertiarySystemBackground))
                        .foregroundStyle(selectedCategory == nil ? .white : .primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    CategoryChipView(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(.secondary)
                Text("Recientes")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }

            ForEach(recentExercises) { history in
                if let exercise = exercises.first(where: { $0.id == history.templateId }) {
                    ExerciseRowButton(
                        name: exercise.name,
                        category: exercise.category,
                        lastWeight: history.formattedLastWeight,
                        onTap: { onSelect(exercise) }
                    )
                }
            }
        }
    }

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "dumbbell")
                    .foregroundStyle(.secondary)
                Text(selectedCategory?.displayName ?? "Todos los ejercicios")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(filteredExercises.count)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            ForEach(filteredExercises) { exercise in
                ExerciseRowButton(
                    name: exercise.name,
                    category: exercise.category,
                    lastWeight: recentExercises.first(where: { $0.templateId == exercise.id })?.formattedLastWeight,
                    onTap: { onSelect(exercise) }
                )
            }
        }
    }

    // MARK: - Computed

    private var filteredExercises: [ExerciseTemplateModel] {
        var result = exercises

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        return result
    }
}

// MARK: - ExerciseRowButton

private struct ExerciseRowButton: View {
    let name: String
    let category: ExerciseCategory
    let lastWeight: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let weight = lastWeight {
                    Text(weight)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
