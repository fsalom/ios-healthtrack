//
//  AddMealBuilder.swift
//  HealthTrack
//

import SwiftUI

enum AddMealBuilder {
    static func build(
        router: Router = Router(),
        initialTime: Date = Date(),
        onMealSaved: @escaping (MealModel) -> Void
    ) -> some View {
        let repository = MealRepository()
        let saveMealUseCase = SaveMealUseCase(repository: repository)

        let viewModel = AddMealViewModel(
            router: router,
            saveMealUseCase: saveMealUseCase,
            initialTime: initialTime,
            onMealSaved: onMealSaved
        )

        return AddMealView(viewModel: viewModel)
    }
}
