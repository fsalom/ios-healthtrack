//
//  ToastType.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 6/8/25.
//

import SwiftUI

enum ToastType {
    case email
    case password
    case deleteAccount

    var message: LocalizedStringKey {
        switch self {
        case .email:
            "account_emailProperlyUpdated"
        case .password:
            "account_passwordProperlyUpdated"
        case .deleteAccount:
            "account_deleteAccountSuccess"
        }
    }
}
