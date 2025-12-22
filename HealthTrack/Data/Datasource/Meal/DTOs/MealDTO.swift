//
//  MealDTO.swift
//  HealthTrack
//

import Foundation

// MARK: - MealDTO

struct MealDTO: Codable {
    let id: String
    let name: String
    let timestamp: Date
    let items: [FoodItemDTO]

    // MARK: - Methods

    func toDomain() -> MealModel {
        MealModel(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            timestamp: timestamp,
            items: items.map { $0.toDomain() }
        )
    }

    static func fromDomain(_ model: MealModel) -> MealDTO {
        MealDTO(
            id: model.id.uuidString,
            name: model.name,
            timestamp: model.timestamp,
            items: model.items.map { FoodItemDTO.fromDomain($0) }
        )
    }
}

// MARK: - FoodItemDTO

struct FoodItemDTO: Codable {
    let id: String
    let name: String
    let barcode: String?
    let calories: Double
    let carbohydrates: Double
    let proteins: Double
    let fats: Double
    let fiber: Double?
    let sugars: Double?
    let quantity: Double
    let servingSize: Double?
    let imageUrl: String?

    // MARK: - Methods

    func toDomain() -> FoodItemModel {
        FoodItemModel(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            barcode: barcode,
            nutritionPer100g: NutritionInfoModel(
                calories: calories,
                carbohydrates: carbohydrates,
                proteins: proteins,
                fats: fats,
                fiber: fiber,
                sugars: sugars
            ),
            quantity: quantity,
            servingSize: servingSize,
            imageUrl: imageUrl
        )
    }

    static func fromDomain(_ model: FoodItemModel) -> FoodItemDTO {
        FoodItemDTO(
            id: model.id.uuidString,
            name: model.name,
            barcode: model.barcode,
            calories: model.nutritionPer100g.calories,
            carbohydrates: model.nutritionPer100g.carbohydrates,
            proteins: model.nutritionPer100g.proteins,
            fats: model.nutritionPer100g.fats,
            fiber: model.nutritionPer100g.fiber,
            sugars: model.nutritionPer100g.sugars,
            quantity: model.quantity,
            servingSize: model.servingSize,
            imageUrl: model.imageUrl
        )
    }
}
