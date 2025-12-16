//
//  AccountBuilder.swift
//  Gula
//
//  Created by Maria on 7/11/24.
//

import Foundation

class AccountBuilder {
    func build() -> AccountView {
        let userUseCase = UserContainer.makeUseCase()
        let authUseCase = AuthContainer.makeUseCase()
        let router = AccountRouter()
        let viewModel = AccountViewModel(userUseCase: userUseCase,
                                         authUseCase: authUseCase,
                                         router: router)
        let view = AccountView(viewModel: viewModel)
        return view
    }
}
