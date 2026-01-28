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
                ScrollView {
                    VStack(spacing: 20) {
                        nameSection
                        addSetSection

                        if !viewModel.sets.isEmpty {
                            setsListSection
                        }
                    }
                    .padding()
                }

                saveButton
            }
            .navigationTitle("Anadir Ejercicio")
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
        }
    }

    // MARK: - Subviews

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nombre del ejercicio")
                .font(.headline)

            TextField("Ej: Press banca, Sentadilla...", text: $viewModel.exerciseName)
                .textFieldStyle(.roundedBorder)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.exerciseSuggestions, id: \.self) { suggestion in
                        Button {
                            viewModel.selectSuggestion(suggestion)
                        } label: {
                            Text(suggestion)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewModel.exerciseName == suggestion ? Color.blue : Color(.tertiarySystemBackground))
                                .foregroundStyle(viewModel.exerciseName == suggestion ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var addSetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nueva serie")
                .font(.headline)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("10", text: $viewModel.currentReps)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Peso (kg)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $viewModel.currentWeight)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                }

                Spacer()

                Button {
                    viewModel.addSet()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
                .disabled(viewModel.currentReps.isEmpty)
            }

            HStack(spacing: 8) {
                ForEach([20, 40, 60, 80, 100], id: \.self) { weight in
                    Button {
                        viewModel.setQuickWeight(weight)
                    } label: {
                        Text("\(weight)kg")
                            .font(.caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var setsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Series (\(viewModel.sets.count))")
                    .font(.headline)

                Spacer()

                if !viewModel.sets.isEmpty {
                    Button("Limpiar") {
                        viewModel.clearSets()
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                }
            }

            ForEach(Array(viewModel.sets.enumerated()), id: \.element.id) { index, set in
                HStack {
                    Text("Serie \(index + 1)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(set.reps) reps")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if set.weight > 0 {
                        Text("@ \(set.formattedWeight)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        viewModel.removeSet(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
        .disabled(!viewModel.canSave)
        .padding()
        .background(Color(.systemBackground))
    }
}
