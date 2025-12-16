//
//  VerifyPasswordRouter.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 6/8/25.
//

import SwiftUI

class VerifyPasswordRouter: UserRouter {
    func goToChangePassword() {
        navigator.dismissSheet()
        navigator.push(to: ChangePasswordBuilder().build())
    }
}
