//
//  FoodItemRow.swift
//  HealthTrack
//

import SwiftUI

struct FoodItemRow: View {

    // MARK: - Properties

    let item: FoodItemModel
    let onQuantityChange: (Double) -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Product image
                productImage

                // Product info
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)

                    if let barcode = item.barcode {
                        Text(barcode)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    // Nutrition for current quantity
                    Text("\(Int(item.actualNutrition.calories)) kcal - \(Int(item.actualNutrition.carbohydrates))g carbs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Delete button
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }

            // Quantity controls
            HStack {
                Text("Cantidad:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                QuantityPicker(
                    quantity: item.quantity,
                    servingSize: item.servingSize,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement
                )
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Subviews

    @ViewBuilder
    private var productImage: some View {
        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    imagePlaceholder
                case .empty:
                    ProgressView()
                        .frame(width: 50, height: 50)
                @unknown default:
                    imagePlaceholder
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 50, height: 50)
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
    }
}

// MARK: - QuantityPicker

struct QuantityPicker: View {

    // MARK: - Properties

    let quantity: Double
    let servingSize: Double?
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            Button {
                onDecrement()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .disabled(quantity <= 10)

            VStack(spacing: 0) {
                Text("\(Int(quantity))g")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .monospacedDigit()

                if let servingSize = servingSize, servingSize > 0 {
                    let servings = quantity / servingSize
                    Text(formatServings(servings))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 60)

            Button {
                onIncrement()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Private Methods

    private func formatServings(_ servings: Double) -> String {
        if servings == floor(servings) {
            return "\(Int(servings)) porc."
        }
        return String(format: "%.1f porc.", servings)
    }
}
