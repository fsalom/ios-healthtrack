//
//  FoodItemModel.swift
//  HealthTrack
//

import Foundation

struct FoodItemModel: Identifiable, Equatable, Codable {

    // MARK: - Properties

    let id: UUID
    let name: String
    let barcode: String?
    let nutritionPer100g: NutritionInfoModel
    var quantity: Double // grams consumed
    let servingSize: Double? // grams per standard serving
    let imageUrl: String?

    // MARK: - Computed Properties

    /// Actual nutrition based on quantity consumed
    var actualNutrition: NutritionInfoModel {
        nutritionPer100g.scaled(by: quantity)
    }

    var formattedQuantity: String {
        "\(Int(quantity))g"
    }

    /// Number of servings if serving size is available
    var servings: Double? {
        guard let servingSize = servingSize, servingSize > 0 else { return nil }
        return quantity / servingSize
    }

    var formattedServings: String? {
        guard let servings = servings else { return nil }
        if servings == floor(servings) {
            return "\(Int(servings)) porcion\(Int(servings) == 1 ? "" : "es")"
        }
        return String(format: "%.1f porciones", servings)
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        name: String,
        barcode: String? = nil,
        nutritionPer100g: NutritionInfoModel,
        quantity: Double = 100,
        servingSize: Double? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.barcode = barcode
        self.nutritionPer100g = nutritionPer100g
        self.quantity = quantity
        self.servingSize = servingSize
        self.imageUrl = imageUrl
    }

    // MARK: - Methods

    /// Returns a copy with updated quantity
    func withQuantity(_ grams: Double) -> FoodItemModel {
        var copy = self
        copy.quantity = grams
        return copy
    }

    /// Returns a copy with quantity set by number of servings
    func withServings(_ count: Double) -> FoodItemModel? {
        guard let servingSize = servingSize else { return nil }
        var copy = self
        copy.quantity = servingSize * count
        return copy
    }
}
