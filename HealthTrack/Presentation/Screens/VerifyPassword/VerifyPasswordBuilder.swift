//
//  VerifyPasswordBuilder.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 4/11/24.
//

import Foundation
import SwiftUI

class VerifyPasswordBuilder {
    func build() -> VerifyPasswordView {
        let userUseCase = UserContainer.makeUseCase()
        let router = VerifyPasswordRouter()
        let viewModel = VerifyPasswordViewModel(userUseCase: userUseCase, router: router)
        let view = VerifyPasswordView(viewModel: viewModel)
        return view
    }
}
