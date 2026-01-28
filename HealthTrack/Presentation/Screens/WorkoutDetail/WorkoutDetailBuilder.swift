//
//  WorkoutDetailBuilder.swift
//  HealthTrack
//

import Foundation

enum WorkoutDetailBuilder {
    static func build(
        workout: WorkoutModel,
        router: Router = Router()
    ) -> WorkoutDetailView {
        let repository = WorkoutDetailRepository()
        let viewModel = WorkoutDetailViewModel(
            workout: workout,
            router: router,
            repository: repository
        )
        return WorkoutDetailView(viewModel: viewModel)
    }
}
