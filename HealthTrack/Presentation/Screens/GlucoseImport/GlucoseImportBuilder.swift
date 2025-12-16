//
//  GlucoseImportBuilder.swift
//  HealthTrack
//

import SwiftUI

enum GlucoseImportBuilder {
    static func build() -> some View {
        let router = Router()
        let viewModel = GlucoseImportViewModel(router: router)
        return GlucoseImportView(viewModel: viewModel)
    }
}
