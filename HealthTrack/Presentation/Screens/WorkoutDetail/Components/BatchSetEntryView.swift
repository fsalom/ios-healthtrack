//
//  BatchSetEntryView.swift
//  HealthTrack
//

import SwiftUI

struct BatchSetEntryView: View {

    // MARK: - Properties

    @Binding var numberOfSets: Int
    @Binding var reps: String
    @Binding var weight: String
    let onAddBatch: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.stack.3d.up")
                    .foregroundStyle(.blue)
                Text("Agregar multiples series")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            HStack(spacing: 16) {
                // Number of sets
                VStack(alignment: .leading, spacing: 4) {
                    Text("Series")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Button {
                            if numberOfSets > 1 { numberOfSets -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.secondary)
                        }

                        Text("\(numberOfSets)")
                            .font(.headline)
                            .frame(width: 30)

                        Button {
                            if numberOfSets < 10 { numberOfSets += 1 }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    .buttonStyle(.plain)
                }

                // Reps
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("10", text: $reps)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 55)
                }

                // Weight
                VStack(alignment: .leading, spacing: 4) {
                    Text("Peso (kg)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $weight)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 65)
                }
            }

            // Add button
            Button(action: onAddBatch) {
                Text("Agregar \(numberOfSets) series")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
