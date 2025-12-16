//
//  AuthContainer.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 4/8/25.
//

import Foundation

class AuthContainer {
    static func makeUseCase() -> AuthUseCase {
        let errorHandler = ErrorHandlerManager()
        let network = Config.shared.network
        let dataSource = AuthRemoteDataSource(network: network)
        let repository = AuthRepository(remoteDataSource: dataSource, errorHandler: errorHandler)
        return AuthUseCase(repository: repository)
    }
}
