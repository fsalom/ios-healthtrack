//
//  AccountRouter.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 6/8/25.
//

import SwiftUI

class AccountRouter: UserRouter {
    func showLogoutAlert(logoutAction: @escaping () -> Void) {
        let alertModel = AlertModel(
            title: "account_alert_logoutAccountTitle",
            message: "common_logoutAccountMessage",
            style: .custom(
                buttons:
                    alertButtons {
                        logoutAction()
                    }
            )
        )

        navigator.showAlert(alertModel: alertModel)
    }

    func showDeleteAccountAlert(deleteAccount: @escaping () -> Void) {
        let alertModel = AlertModel(
            title: "account_alert_deleteAccountTitle",
            message: "alert_deleteAccountMessage",
            style: .custom(
                buttons:
                    alertButtons {
                        deleteAccount()
                    }
            )
        )

        navigator.showAlert(alertModel: alertModel)
    }

    private func alertButtons(action: @escaping () -> Void) -> some View {
        HStack {
            Button("common_cancel", role: .cancel) {}
            Button("common_logout", role: .destructive) {
                action()
            }
        }
    }

    func goToAccountScreen(_ screen: AccountScreen) {
        switch screen {
        case .user:
            /// Replace EmptyView to correct view in destination app
            navigator.push(to: EmptyView())
        case .personalData:
            navigator.push(to: UserContactBuilder().build())
        case .direction:
            /// Replace EmptyView to correct view in destination app
            navigator.push(to: EmptyView())
        case .payment:
            /// Replace EmptyView to correct view in destination app
            navigator.push(to: EmptyView())
        case .changePassword:
            navigator.present(view: VerifyPasswordBuilder().build())
        case .changeEmail:
            navigator.push(to: ChangeEmailBuilder().build())
        }
    }
}
