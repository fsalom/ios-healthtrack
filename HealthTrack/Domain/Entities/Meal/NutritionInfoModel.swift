//
//  NutritionInfoModel.swift
//  HealthTrack
//

import Foundation

struct NutritionInfoModel: Equatable, Codable {

    // MARK: - Properties

    let calories: Double
    let carbohydrates: Double
    let proteins: Double
    let fats: Double
    let fiber: Double?
    let sugars: Double?

    // MARK: - Computed Properties

    var formattedCalories: String {
        "\(Int(calories)) kcal"
    }

    var formattedCarbs: String {
        "\(Int(carbohydrates))g"
    }

    var formattedProteins: String {
        "\(Int(proteins))g"
    }

    var formattedFats: String {
        "\(Int(fats))g"
    }

    // MARK: - Static

    static let empty = NutritionInfoModel(
        calories: 0,
        carbohydrates: 0,
        proteins: 0,
        fats: 0,
        fiber: nil,
        sugars: nil
    )

    // MARK: - Methods

    /// Returns nutrition values scaled by quantity (in grams)
    /// Values are per 100g, so we multiply by quantity/100
    func scaled(by grams: Double) -> NutritionInfoModel {
        let factor = grams / 100.0
        return NutritionInfoModel(
            calories: calories * factor,
            carbohydrates: carbohydrates * factor,
            proteins: proteins * factor,
            fats: fats * factor,
            fiber: fiber.map { $0 * factor },
            sugars: sugars.map { $0 * factor }
        )
    }

    /// Adds two nutrition info together
    static func + (lhs: NutritionInfoModel, rhs: NutritionInfoModel) -> NutritionInfoModel {
        NutritionInfoModel(
            calories: lhs.calories + rhs.calories,
            carbohydrates: lhs.carbohydrates + rhs.carbohydrates,
            proteins: lhs.proteins + rhs.proteins,
            fats: lhs.fats + rhs.fats,
            fiber: Self.addOptionals(lhs.fiber, rhs.fiber),
            sugars: Self.addOptionals(lhs.sugars, rhs.sugars)
        )
    }

    private static func addOptionals(_ lhs: Double?, _ rhs: Double?) -> Double? {
        switch (lhs, rhs) {
        case let (l?, r?): return l + r
        case let (l?, nil): return l
        case let (nil, r?): return r
        case (nil, nil): return nil
        }
    }
}
