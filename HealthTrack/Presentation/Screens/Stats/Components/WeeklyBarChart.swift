//
//  WeeklyBarChart.swift
//  HealthTrack
//

import SwiftUI
import Charts

struct WeeklyBarChart<T: Identifiable>: View {

    // MARK: - Properties

    let data: [T]
    let labelKeyPath: KeyPath<T, String>
    let valueKeyPath: KeyPath<T, Double>
    let barColor: Color

    // MARK: - Body

    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Semana", item[keyPath: labelKeyPath]),
                y: .value("Valor", item[keyPath: valueKeyPath])
            )
            .foregroundStyle(barColor.gradient)
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisValueLabel()
                    .font(.caption2)
            }
        }
    }
}

struct StepsLineChart: View {

    // MARK: - Properties

    let data: [ActivityStatsModel.DailySteps]

    // MARK: - Body

    var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("Dia", item.dayLabel),
                y: .value("Pasos", item.steps)
            )
            .foregroundStyle(Color.blue.gradient)
            .symbol(.circle)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Dia", item.dayLabel),
                y: .value("Pasos", item.steps)
            )
            .foregroundStyle(Color.blue.opacity(0.1).gradient)
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisValueLabel()
                    .font(.caption2)
            }
        }
    }
}

struct CaloriesBarChart: View {

    // MARK: - Properties

    let data: [ActivityStatsModel.DailyCalories]
    let color: Color

    // MARK: - Body

    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Dia", item.dayLabel),
                y: .value("Calorias", item.calories)
            )
            .foregroundStyle(color.gradient)
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisValueLabel()
                    .font(.caption2)
            }
        }
    }
}

struct NutritionCaloriesChart: View {

    // MARK: - Properties

    let data: [NutritionStatsModel.DailyCaloriesConsumed]

    // MARK: - Body

    var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("Dia", item.dayLabel),
                y: .value("Calorias", item.calories)
            )
            .foregroundStyle(Color.green.gradient)
            .symbol(.circle)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Dia", item.dayLabel),
                y: .value("Calorias", item.calories)
            )
            .foregroundStyle(Color.green.opacity(0.1).gradient)
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisValueLabel()
                    .font(.caption2)
            }
        }
    }
}
