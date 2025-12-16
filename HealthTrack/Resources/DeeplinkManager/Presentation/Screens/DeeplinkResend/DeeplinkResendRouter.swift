//
//  DeeplinkResendRouter.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/8/25.
//

import Foundation

class DeeplinkResendRouter: Router {
    func goToMainMenu() {
        navigator.replaceRoot(to: GlucoseImportBuilder.build())
    }
}
