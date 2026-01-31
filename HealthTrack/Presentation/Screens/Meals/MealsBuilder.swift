//
//  MealsBuilder.swift
//  HealthTrack
//

import Foundation

enum MealsBuilder {
    static func build(router: Router = Router()) -> MealsView {
        let mealRepository = MealRepository()
        let getMealsUseCase = GetMealsUseCase(repository: mealRepository)
        let viewModel = MealsViewModel(
            router: router,
            getMealsUseCase: getMealsUseCase
        )
        return MealsView(viewModel: viewModel)
    }
}
