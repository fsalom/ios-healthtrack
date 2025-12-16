//
//  ChangeEmailBuilder.swift
//  Gula
//
//  Created by Jesu Castellano on 5/11/24.
//

import Foundation

class ChangeEmailBuilder {
    func build() -> ChangeEmailView {
        let userUseCase = UserContainer.makeUseCase()
        let router = ChangeEmailRouter()
        let viewModel = ChangeEmailViewModel(userUseCase: userUseCase, router: router)
        return ChangeEmailView(viewModel: viewModel)
    }
}
