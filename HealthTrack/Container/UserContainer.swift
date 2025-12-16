//
//  UserContainer.swift
//  Gula
//
//  Created by Daniel Belmonte Valero on 14/11/25.
//

class UserContainer {
    static func makeUseCase() -> UserUseCase {
        let errorHandler = ErrorHandlerManager()
        let network = Config.shared.network

        let userDataSource = UserRemoteDatasource(network: network)
        let userRepository = UserRepository(dataSource: userDataSource, errorHandler: errorHandler)
        return UserUseCase(repository: userRepository)
    }
}
