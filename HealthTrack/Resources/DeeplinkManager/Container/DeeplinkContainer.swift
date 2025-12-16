//
//  DeeplinkContainer.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/8/25.
//

import Foundation

class DeeplinkContainer {
    static func makeUseCase() -> DeeplinkManagerUseCase {
        let dataSource = DeeplinkManagerDatasource(network: Config.shared.network)
        let errorHandler = ErrorHandlerManager()
        let repository = DeeplinkManagerRepository(dataSource: dataSource,
                                                   errorHandler: errorHandler)
        return DeeplinkManagerUseCase(repository: repository)
    }
}
