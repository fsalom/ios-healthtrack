//
//  GlucoseImportBuilder.swift
//  HealthTrack
//

import SwiftUI

enum GlucoseImportBuilder {
    static func build() -> some View {
        let router = Router()
        let healthKitManager = HealthKitManager()
        let importUseCase = ImportGlucoseDataUseCase()
        let fetchActivityUseCase = FetchActivityDataUseCase(healthKitManager: healthKitManager)

        let viewModel = GlucoseImportViewModel(
            router: router,
            importUseCase: importUseCase,
            fetchActivityUseCase: fetchActivityUseCase
        )

        return GlucoseImportView(viewModel: viewModel)
    }
}
