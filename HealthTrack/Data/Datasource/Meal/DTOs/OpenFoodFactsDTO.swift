//
//  OpenFoodFactsDTO.swift
//  HealthTrack
//

import Foundation

// MARK: - Response

struct OpenFoodFactsResponseDTO: Codable {
    let status: Int
    let product: OpenFoodFactsProductDTO?
}

// MARK: - Product

struct OpenFoodFactsProductDTO: Codable {
    let productName: String?
    let productNameEs: String?
    let brands: String?
    let imageUrl: String?
    let nutriments: NutrimentsDTO?
    let servingSize: String?
    let servingQuantity: Double?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productNameEs = "product_name_es"
        case brands
        case imageUrl = "image_url"
        case nutriments
        case servingSize = "serving_size"
        case servingQuantity = "serving_quantity"
    }

    // MARK: - Computed Properties

    var displayName: String {
        let name = productNameEs ?? productName ?? "Producto desconocido"
        if let brand = brands, !brand.isEmpty {
            return "\(name) - \(brand)"
        }
        return name
    }

    /// Parses serving size to grams (e.g., "30g" -> 30)
    var servingSizeInGrams: Double? {
        if let quantity = servingQuantity, quantity > 0 {
            return quantity
        }
        guard let servingSize = servingSize else { return nil }
        let pattern = #"(\d+(?:\.\d+)?)\s*g"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: servingSize, range: NSRange(servingSize.startIndex..., in: servingSize)),
           let range = Range(match.range(at: 1), in: servingSize) {
            return Double(servingSize[range])
        }
        return nil
    }

    // MARK: - Methods

    func toDomain(barcode: String) -> FoodItemModel {
        FoodItemModel(
            id: UUID(),
            name: displayName,
            barcode: barcode,
            nutritionPer100g: NutritionInfoModel(
                calories: nutriments?.energyKcal ?? 0,
                carbohydrates: nutriments?.carbohydrates ?? 0,
                proteins: nutriments?.proteins ?? 0,
                fats: nutriments?.fat ?? 0,
                fiber: nutriments?.fiber,
                sugars: nutriments?.sugars
            ),
            quantity: servingSizeInGrams ?? 100,
            servingSize: servingSizeInGrams,
            imageUrl: imageUrl
        )
    }
}

// MARK: - Nutriments

struct NutrimentsDTO: Codable {
    let energyKcal: Double?
    let carbohydrates: Double?
    let proteins: Double?
    let fat: Double?
    let fiber: Double?
    let sugars: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal = "energy-kcal_100g"
        case carbohydrates = "carbohydrates_100g"
        case proteins = "proteins_100g"
        case fat = "fat_100g"
        case fiber = "fiber_100g"
        case sugars = "sugars_100g"
    }
}
