//
//  MealModel.swift
//  HealthTrack
//

import Foundation

struct MealModel: Identifiable, Equatable, Codable {

    // MARK: - Properties

    let id: UUID
    var name: String
    var timestamp: Date
    var items: [FoodItemModel]

    // MARK: - Computed Properties

    /// Total nutrition summing all items
    var totalNutrition: NutritionInfoModel {
        items.reduce(.empty) { result, item in
            result + item.actualNutrition
        }
    }

    var formattedTime: String {
        timestamp.formatted(date: .omitted, time: .shortened)
    }

    var formattedDate: String {
        timestamp.formatted(date: .abbreviated, time: .omitted)
    }

    var itemCount: Int {
        items.count
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        name: String,
        timestamp: Date = Date(),
        items: [FoodItemModel] = []
    ) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.items = items
    }

    // MARK: - Methods

    /// Adds a food item to the meal
    mutating func addItem(_ item: FoodItemModel) {
        items.append(item)
    }

    /// Removes a food item by ID
    mutating func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }

    /// Updates quantity of a specific item
    mutating func updateItemQuantity(id: UUID, quantity: Double) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].quantity = quantity
    }

    /// Returns a copy with updated timestamp
    func withTimestamp(_ date: Date) -> MealModel {
        var copy = self
        copy.timestamp = date
        return copy
    }
}
