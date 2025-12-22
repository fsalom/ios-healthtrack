//
//  AddMealView.swift
//  HealthTrack
//

import SwiftUI

struct AddMealView: View {

    // MARK: - Properties

    @State var viewModel: AddMealViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Meal info section
                        mealInfoSection

                        // Action buttons
                        actionButtons

                        // Items list
                        if !viewModel.items.isEmpty {
                            itemsSection
                        }

                        // Manual entry section
                        if viewModel.showingManualEntry {
                            manualEntrySection
                        }

                        // Totals
                        if !viewModel.items.isEmpty {
                            totalsSection
                        }
                    }
                    .padding()
                }

                // Save button at bottom
                saveButton
            }
            .navigationTitle("Agregar Comida")
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
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .sheet(isPresented: $viewModel.showingBarcodeScanner) {
                BarcodeScannerBuilder.build { foodItem in
                    viewModel.addScannedFood(foodItem)
                }
            }
        }
    }

    // MARK: - Subviews

    private var mealInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informacion")
                .font(.headline)

            TextField("Nombre de la comida", text: $viewModel.mealName)
                .textFieldStyle(.roundedBorder)

            // Custom time picker with 15-min intervals
            VStack(alignment: .leading, spacing: 8) {
                Text("Hora")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    // Hour picker
                    Picker("Hora", selection: $viewModel.selectedHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(String(format: "%02d", hour))
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 100)
                    .clipped()

                    Text(":")
                        .font(.title2)
                        .fontWeight(.medium)

                    // Minute picker (15-min intervals)
                    Picker("Minutos", selection: $viewModel.selectedMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text(String(format: "%02d", minute))
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 100)
                    .clipped()

                    Spacer()

                    // Date info
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(viewModel.selectedTime, format: .dateTime.weekday(.abbreviated))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text(viewModel.selectedTime, format: .dateTime.day().month())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveMeal()
                dismiss()
            }
        } label: {
            Text("Guardar Comida")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.canSave)
        .padding()
        .background(Color(.systemBackground))
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.didTapScanBarcode()
            } label: {
                Label("Escanear", systemImage: "barcode.viewfinder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                withAnimation {
                    viewModel.showingManualEntry.toggle()
                }
            } label: {
                Label("Manual", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Alimentos")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.items.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
            }

            ForEach(viewModel.items) { item in
                FoodItemRow(
                    item: item,
                    onQuantityChange: { quantity in
                        viewModel.updateItemQuantity(id: item.id, quantity: quantity)
                    },
                    onIncrement: {
                        viewModel.incrementQuantity(id: item.id)
                    },
                    onDecrement: {
                        viewModel.decrementQuantity(id: item.id)
                    },
                    onDelete: {
                        viewModel.removeItem(id: item.id)
                    }
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var manualEntrySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Entrada manual")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation {
                        viewModel.showingManualEntry = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            TextField("Nombre del alimento", text: $viewModel.manualName)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calorias")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $viewModel.manualCalories)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Carbos (g)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $viewModel.manualCarbs)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Proteinas (g)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $viewModel.manualProteins)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Grasas (g)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $viewModel.manualFats)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
            }

            Button {
                viewModel.addManualFood()
            } label: {
                Text("Agregar alimento")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.manualName.isEmpty)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var totalsSection: some View {
        VStack(spacing: 16) {
            Text("TOTALES")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                NutritionSummaryItem(
                    label: "Calorias",
                    value: "\(Int(viewModel.totalNutrition.calories))",
                    unit: "kcal",
                    color: .orange
                )

                Divider()
                    .frame(height: 40)

                NutritionSummaryItem(
                    label: "Carbos",
                    value: "\(Int(viewModel.totalNutrition.carbohydrates))",
                    unit: "g",
                    color: .green
                )

                Divider()
                    .frame(height: 40)

                NutritionSummaryItem(
                    label: "Proteinas",
                    value: "\(Int(viewModel.totalNutrition.proteins))",
                    unit: "g",
                    color: .blue
                )

                Divider()
                    .frame(height: 40)

                NutritionSummaryItem(
                    label: "Grasas",
                    value: "\(Int(viewModel.totalNutrition.fats))",
                    unit: "g",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - NutritionSummaryItem

private struct NutritionSummaryItem: View {
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }
}
