//
//  MacrosPieChart.swift
//  HealthTrack
//

import SwiftUI
import Charts

struct MacrosPieChart: View {

    // MARK: - Properties

    let macros: NutritionStatsModel.MacroDistribution

    // MARK: - Private Properties

    private var chartData: [MacroData] {
        [
            MacroData(name: "Carbos", value: macros.carbohydrates, color: .blue),
            MacroData(name: "Proteina", value: macros.proteins, color: .red),
            MacroData(name: "Grasa", value: macros.fats, color: .yellow)
        ]
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            Chart(chartData) { item in
                SectorMark(
                    angle: .value("Cantidad", item.value),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }
            .frame(height: 150)

            HStack(spacing: 20) {
                MacroLegendItem(
                    name: "Carbos",
                    value: macros.formattedCarbs,
                    percentage: macros.carbsPercentage,
                    color: .blue
                )

                MacroLegendItem(
                    name: "Proteina",
                    value: macros.formattedProteins,
                    percentage: macros.proteinsPercentage,
                    color: .red
                )

                MacroLegendItem(
                    name: "Grasa",
                    value: macros.formattedFats,
                    percentage: macros.fatsPercentage,
                    color: .yellow
                )
            }
        }
    }
}

// MARK: - MacroData

private struct MacroData: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

// MARK: - MacroLegendItem

private struct MacroLegendItem: View {
    let name: String
    let value: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text("\(percentage)%")
                .font(.caption)
                .fontWeight(.semibold)

            Text(value)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
