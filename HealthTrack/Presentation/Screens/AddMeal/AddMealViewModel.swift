//
//  AddMealViewModel.swift
//  HealthTrack
//

import Foundation

@Observable
final class AddMealViewModel {

    // MARK: - Properties

    var mealName: String = ""
    var items: [FoodItemModel] = []
    var isLoading = false
    var showingBarcodeScanner = false

    // Time selection (hour and minute separately for 15-min intervals)
    var selectedHour: Int {
        didSet { updateSelectedTime() }
    }
    var selectedMinute: Int {
        didSet { updateSelectedTime() }
    }
    private(set) var selectedTime: Date
    private var selectedDate: Date

    // Manual entry fields
    var manualName = ""
    var manualCalories = ""
    var manualCarbs = ""
    var manualProteins = ""
    var manualFats = ""
    var showingManualEntry = false

    var canSave: Bool {
        !items.isEmpty
    }

    var totalNutrition: NutritionInfoModel {
        items.reduce(.empty) { result, item in
            result + item.actualNutrition
        }
    }

    private let router: Router
    private let saveMealUseCase: SaveMealUseCaseProtocol
    private let onMealSaved: (MealModel) -> Void

    // MARK: - Init

    init(
        router: Router,
        saveMealUseCase: SaveMealUseCaseProtocol,
        initialTime: Date = Date(),
        onMealSaved: @escaping (MealModel) -> Void
    ) {
        self.router = router
        self.saveMealUseCase = saveMealUseCase
        self.onMealSaved = onMealSaved

        // Extract hour and round minute to nearest 15
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: initialTime)
        let minute = calendar.component(.minute, from: initialTime)
        let roundedMinute = (minute / 15) * 15

        self.selectedHour = hour
        self.selectedMinute = roundedMinute
        self.selectedDate = calendar.startOfDay(for: initialTime)
        self.selectedTime = calendar.date(bySettingHour: hour, minute: roundedMinute, second: 0, of: initialTime) ?? initialTime

        // Set default meal name based on time
        self.mealName = Self.suggestedMealName(for: initialTime)
    }

    // MARK: - Private Methods

    private func updateSelectedTime() {
        let calendar = Calendar.current
        if let newTime = calendar.date(bySettingHour: selectedHour, minute: selectedMinute, second: 0, of: selectedDate) {
            selectedTime = newTime
        }
    }

    // MARK: - Public Methods

    func didTapCancel() {
        router.dismissSheet()
    }

    func didTapScanBarcode() {
        showingBarcodeScanner = true
    }

    func didTapAddManual() {
        showingManualEntry = true
    }

    func addScannedFood(_ item: FoodItemModel) {
        items.append(item)
    }

    func addManualFood() {
        guard !manualName.isEmpty else { return }

        let item = FoodItemModel(
            name: manualName,
            nutritionPer100g: NutritionInfoModel(
                calories: Double(manualCalories) ?? 0,
                carbohydrates: Double(manualCarbs) ?? 0,
                proteins: Double(manualProteins) ?? 0,
                fats: Double(manualFats) ?? 0,
                fiber: nil,
                sugars: nil
            ),
            quantity: 100
        )

        items.append(item)
        clearManualEntry()
        showingManualEntry = false
    }

    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }

    func updateItemQuantity(id: UUID, quantity: Double) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].quantity = max(1, quantity)
    }

    func incrementQuantity(id: UUID, by amount: Double = 10) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].quantity += amount
    }

    func decrementQuantity(id: UUID, by amount: Double = 10) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].quantity = max(1, items[index].quantity - amount)
    }

    @MainActor
    func saveMeal() async {
        guard canSave else { return }
        isLoading = true

        let meal = MealModel(
            name: mealName.isEmpty ? "Comida" : mealName,
            timestamp: selectedTime,
            items: items
        )

        do {
            try await saveMealUseCase.execute(meal)
            onMealSaved(meal)
        } catch let error as AppError {
            router.showAlert(with: error)
        } catch {
            router.showAlert(
                title: "Error",
                message: error.localizedDescription
            )
        }

        isLoading = false
    }

    private func clearManualEntry() {
        manualName = ""
        manualCalories = ""
        manualCarbs = ""
        manualProteins = ""
        manualFats = ""
    }

    private static func suggestedMealName(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<11:
            return "Desayuno"
        case 11..<14:
            return "Almuerzo"
        case 14..<18:
            return "Merienda"
        case 18..<22:
            return "Cena"
        default:
            return "Snack"
        }
    }
}
