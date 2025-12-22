//
//  BarcodeScannerBuilder.swift
//  HealthTrack
//

import SwiftUI

enum BarcodeScannerBuilder {
    static func build(
        router: Router = Router(),
        onFoodScanned: @escaping (FoodItemModel) -> Void
    ) -> some View {
        let repository = MealRepository()
        let fetchFoodInfoUseCase = FetchFoodInfoUseCase(repository: repository)

        let viewModel = BarcodeScannerViewModel(
            router: router,
            fetchFoodInfoUseCase: fetchFoodInfoUseCase,
            onFoodScanned: onFoodScanned
        )

        return NavigationStack {
            BarcodeScannerView(viewModel: viewModel)
        }
    }
}
