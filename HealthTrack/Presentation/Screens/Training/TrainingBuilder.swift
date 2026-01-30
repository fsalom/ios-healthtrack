//
//  TrainingBuilder.swift
//  HealthTrack
//

import Foundation

enum TrainingBuilder {
    static func build(router: Router = Router()) -> TrainingView {
        let healthKitManager = HealthKitManager()
        let viewModel = TrainingViewModel(
            router: router,
            healthKitManager: healthKitManager
        )
        return TrainingView(viewModel: viewModel)
    }
}
