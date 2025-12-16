//
//  NewPasswordRouter.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 6/8/25.
//

import SwiftUI

class NewPasswordRouter: AuthenticationRouter {
    func goToMainMenu() {
        navigator.replaceRoot(to: GlucoseImportBuilder.build())
    }

    func showUpdatedPasswordAlert() {
        let alertModel = AlertModel(
            title: "auth_passwordUpdated",
            message: "auth_passwordUpdatedInfo",
            style: .info(action: {
                self.goToMainMenu()
            }
                        )
        )
        navigator.showAlert(alertModel: alertModel)
    }
}
