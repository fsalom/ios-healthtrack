//
//  RecoverPasswordRouter.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 6/8/25.
//

import Foundation

class RecoverPasswordRouter: AuthenticationRouter {
    func goToResendLinkView(with email: String) {
        navigator.push(to:
                        DeeplinkResendBuilder().build(with: .init(
                            title: "auth_emailSent",
                            message: "auth_emailSentInfo, \(email)",
                            email: email,
                            messageType: .recoverPassword)
                        )
        )
    }
}
