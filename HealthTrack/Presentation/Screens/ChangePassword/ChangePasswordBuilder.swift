//
//  Gula
//
//  ChangePasswordBuilder.swift
//
//  Created by Rudo Apps on 7/5/25
//

import Foundation
import SwiftUI

class ChangePasswordBuilder {
    func build() -> ChangePasswordView {
        let userUseCase = UserContainer.makeUseCase()
        let router = ChangePasswordRouter()
        let viewModel = ChangePasswordViewModel(userUseCase: userUseCase,
                                                router: router)
        let view = ChangePasswordView(viewModel: viewModel)
        return view
    }
}
