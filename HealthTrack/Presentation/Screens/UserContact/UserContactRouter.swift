//
//  UserContactRouter.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 6/8/25.
//

import SwiftUI

class UserContactRouter: UserRouter {
    func presentPrefixList(
        selectedPrefix: Prefix,
        prefixes: [Prefix],
        delegate: ChangeSelectedPrefix
    ) {
        navigator.present(
            view: PrefixesBuilder.build(
                selectedPrefix: selectedPrefix,
                prefixes: prefixes,
                delegate: delegate
            )
        )
    }
}
