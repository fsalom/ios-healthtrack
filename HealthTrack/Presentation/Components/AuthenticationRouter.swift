//
//  AuthenticationRouter.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 4/8/25.
//

import SwiftUI

class AuthenticationRouter: Router {
    func showNotVerifiedAlert(_ error: AuthError, resendAction: @escaping () -> Void) {
        let alertModel = AlertModel(
            title: error.title,
            message: error.title,
            style: .custom(
                buttons:
                    VStack {
                        Button("common_accept") {}
                        Button("auth_resend") {
                            resendAction()
                        }
                    }
            )
        )
        navigator.showAlert(alertModel: alertModel)
    }
}
