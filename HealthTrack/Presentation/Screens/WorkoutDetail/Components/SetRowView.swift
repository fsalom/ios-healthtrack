//
//  SetRowView.swift
//  HealthTrack
//

import SwiftUI

struct SetRowView: View {

    // MARK: - Properties

    let setNumber: Int
    let set: SetModel
    let isEditing: Bool
    let onTapEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onUpdate: (SetModel) -> Void

    @State private var editReps: String = ""
    @State private var editWeight: String = ""
    @State private var editIsWarmup: Bool = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // Set number badge
            setNumberBadge

            if isEditing {
                editingContent
            } else {
                displayContent
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(set.isWarmup ? Color.orange.opacity(0.1) : Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear {
            editReps = "\(set.reps)"
            editWeight = set.weight > 0 ? formatWeight(set.weight) : ""
            editIsWarmup = set.isWarmup
        }
    }

    // MARK: - Subviews

    private var setNumberBadge: some View {
        ZStack {
            Circle()
                .fill(set.isWarmup ? Color.orange : Color.blue)
                .frame(width: 28, height: 28)
            Text("\(setNumber)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
    }

    private var displayContent: some View {
        HStack {
            // Reps x Weight
            HStack(spacing: 4) {
                Text("\(set.reps)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("reps")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if set.weight > 0 {
                    Text("x")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(set.formattedWeight)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            // Warmup indicator
            if set.isWarmup {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            // Notes indicator
            if set.notes != nil {
                Image(systemName: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Action buttons
            HStack(spacing: 16) {
                Button(action: onTapEdit) {
                    Image(systemName: "pencil")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button(action: onDuplicate) {
                    Image(systemName: "doc.on.doc")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.subheadline)
                        .foregroundStyle(.red.opacity(0.7))
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var editingContent: some View {
        HStack(spacing: 8) {
            TextField("Reps", text: $editReps)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 55)

            Text("x")
                .foregroundStyle(.secondary)

            TextField("Peso", text: $editWeight)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(width: 65)

            Text("kg")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                editIsWarmup.toggle()
            } label: {
                Image(systemName: editIsWarmup ? "flame.fill" : "flame")
                    .foregroundStyle(editIsWarmup ? .orange : .secondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                saveEdit()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func formatWeight(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private func saveEdit() {
        guard let reps = Int(editReps), reps > 0 else { return }
        let weight = Double(editWeight) ?? 0

        var updatedSet = set
        updatedSet.reps = reps
        updatedSet.weight = weight
        updatedSet.isWarmup = editIsWarmup
        onUpdate(updatedSet)
    }
}
