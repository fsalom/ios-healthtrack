//
//  QuickSetEntryView.swift
//  HealthTrack
//

import SwiftUI

struct QuickSetEntryView: View {

    // MARK: - Properties

    @Binding var reps: String
    @Binding var weight: String
    @Binding var isWarmup: Bool
    @Binding var notes: String

    let previousWeight: Double?
    let previousReps: Int?
    let onAddSet: () -> Void
    let onDuplicateLast: () -> Void
    let hasLastSet: Bool

    @State private var showNotes: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nueva serie")
                .font(.headline)

            // Input row
            HStack(spacing: 16) {
                // Reps
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField(
                        previousReps.map { "\($0)" } ?? "10",
                        text: $reps
                    )
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 70)
                }

                // Weight
                VStack(alignment: .leading, spacing: 4) {
                    Text("Peso (kg)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField(
                        previousWeight.map { formatWeight($0) } ?? "0",
                        text: $weight
                    )
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
                }

                Spacer()

                // Add button
                Button(action: onAddSet) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                }
            }

            // Quick actions
            HStack(spacing: 12) {
                // Warmup toggle
                Button {
                    isWarmup.toggle()
                } label: {
                    Label("Calentamiento", systemImage: isWarmup ? "flame.fill" : "flame")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(isWarmup ? .orange : .gray)

                // Duplicate button
                if hasLastSet {
                    Button(action: onDuplicateLast) {
                        Label("Duplicar", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                // Notes toggle
                Button {
                    withAnimation {
                        showNotes.toggle()
                    }
                } label: {
                    Image(systemName: showNotes ? "note.text" : "note")
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .tint(notes.isEmpty ? .gray : .blue)
            }

            // Quick weight buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach([10, 20, 30, 40, 50, 60, 70, 80, 90, 100], id: \.self) { w in
                        Button {
                            weight = "\(w)"
                        } label: {
                            Text("\(w)kg")
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

            // Notes field (expandable)
            if showNotes {
                TextField("Notas (opcional)", text: $notes)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func formatWeight(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }
}
