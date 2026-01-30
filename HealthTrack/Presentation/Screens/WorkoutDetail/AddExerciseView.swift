//
//  AddExerciseView.swift
//  HealthTrack
//

import SwiftUI

struct AddExerciseView: View {

    // MARK: - Properties

    @State var viewModel: AddExerciseViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.hasSelectedExercise {
                    // Mode 2: Set entry
                    setEntryContent
                } else {
                    // Mode 1: Exercise selection
                    exerciseSelectionContent
                }
            }
            .navigationTitle(viewModel.hasSelectedExercise ? viewModel.exerciseName : "Seleccionar ejercicio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.hasSelectedExercise {
                        Button {
                            viewModel.clearSelection()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Cambiar")
                            }
                            .font(.subheadline)
                        }
                    }
                }

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
                await viewModel.loadExercises()
            }
        }
    }

    // MARK: - Exercise Selection Mode

    private var exerciseSelectionContent: some View {
        ExercisePickerView(
            exercises: viewModel.filteredExercises,
            recentExercises: viewModel.recentExercises,
            onSelect: { template in
                viewModel.selectExercise(template)
            },
            searchQuery: $viewModel.searchQuery,
            selectedCategory: $viewModel.selectedCategory
        )
    }

    // MARK: - Set Entry Mode

    private var setEntryContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // Quick set entry
                    QuickSetEntryView(
                        reps: $viewModel.currentReps,
                        weight: $viewModel.currentWeight,
                        isWarmup: $viewModel.currentIsWarmup,
                        notes: $viewModel.currentNotes,
                        previousWeight: viewModel.previousWeight,
                        previousReps: viewModel.previousReps,
                        onAddSet: { viewModel.addSet() },
                        onDuplicateLast: { viewModel.duplicateLastSet() },
                        hasLastSet: viewModel.lastSet != nil
                    )

                    // Sets list
                    if !viewModel.sets.isEmpty {
                        setsListSection
                    }

                    // Batch entry toggle
                    batchEntrySection
                }
                .padding()
            }

            // Save button
            if viewModel.canSave {
                saveButton
            }
        }
    }

    private var setsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Series (\(viewModel.sets.count))")
                    .font(.headline)

                Spacer()

                Button("Limpiar") {
                    viewModel.clearSets()
                }
                .font(.caption)
                .foregroundStyle(.red)
            }

            ForEach(Array(viewModel.sets.enumerated()), id: \.element.id) { index, set in
                SetRowView(
                    setNumber: index + 1,
                    set: set,
                    isEditing: viewModel.editingSetId == set.id,
                    onTapEdit: { viewModel.startEditingSet(set) },
                    onDuplicate: {
                        let newSet = SetModel(reps: set.reps, weight: set.weight)
                        viewModel.sets.append(newSet)
                    },
                    onDelete: { viewModel.removeSet(set) },
                    onUpdate: { viewModel.updateSet($0) }
                )
            }

            // Volume summary
            HStack {
                Text("Volumen total")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(formattedTotalVolume)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var batchEntrySection: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation {
                    viewModel.showBatchEntry.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: viewModel.showBatchEntry ? "chevron.down" : "chevron.right")
                        .font(.caption)
                    Text("Agregar multiples series")
                        .font(.subheadline)
                    Spacer()
                }
                .foregroundStyle(.secondary)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            if viewModel.showBatchEntry {
                BatchSetEntryView(
                    numberOfSets: $viewModel.batchSetCount,
                    reps: $viewModel.batchReps,
                    weight: $viewModel.batchWeight,
                    onAddBatch: { viewModel.addBatchSets() }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var saveButton: some View {
        Button {
            viewModel.saveExercise()
            dismiss()
        } label: {
            Text("Guardar Ejercicio")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Helpers

    private var formattedTotalVolume: String {
        let total = viewModel.sets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
        if total >= 1000 {
            return String(format: "%.1f t", total / 1000)
        }
        return "\(Int(total)) kg"
    }
}
