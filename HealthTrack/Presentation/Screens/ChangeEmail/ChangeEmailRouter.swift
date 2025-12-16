//
//  ChangeEmailRouter.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 6/8/25.
//

import SwiftUI

class ChangeEmailRouter: UserRouter {
    // TODO: -  Remove in destination app
    func goToEmptyView() {
        navigator.push(to: EmptyView())
    }
}
