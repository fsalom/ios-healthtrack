//
//  AlertStyles.swift
//  Gula
//
//  Created by Adrián Prieto Villena   on 1/12/25.
//

import SwiftUI

enum AlertStyle {
    case info(action: () -> Void)
    case error(acceptAction: () -> Void, cancelAction: () -> Void)
    case settings
    case custom(buttons: any View)

    var buttons: some View {
        HStack {
            switch self {
            case .info(let action):
                Button("common_accept") {
                    action()
                }
            case .error(let acceptAction, let cancelAction):
                Button("common_accept") {
                    acceptAction()
                }
                Button("common_cancel", role: .cancel) {
                    cancelAction()
                }
            case .settings:
                VStack {
                    Button("common_cancel", role: .cancel) {}
                    Button("common_goToSettings") {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings)
                        }
                    }
                }
            case .custom(let buttons):
                AnyView(buttons)
            }
        }
    }
}
