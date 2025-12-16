//
//  ContactBuilder.swift
//  Gula
//
//  Created by Jorge on 29/8/24.
//

import Foundation
import TripleA

class UserContactBuilder {
    func build() -> UserContactView {
        let userUseCase = UserContainer.makeUseCase()
        let router = UserContactRouter()

        let localPrefixDatasource = LocalPrefixesDataSource()
        let prefixesRepository = PrefixesRepository(localDataSource: localPrefixDatasource)
        let prefixesUseCase = PrefixesUseCase(repository: prefixesRepository)

        let viewModel = UserContactViewModel(userUseCase: userUseCase,
                                             router: router,
                                             prefixesUseCase: prefixesUseCase)
        let view = UserContactView(viewModel: viewModel)
        return view
    }
}
