//
//  Gula
//
//  ChangePasswordViewModel.swift
//
//  Created by Rudo Apps on 7/5/25
//

import Foundation
import SwiftUI

@Observable
final class ChangePasswordViewModel {
    // MARK: Properties
    var passwordValidationResult: ValidationResult = .success
    var repeatedPasswordValidationResult: ValidationResult = .success
    var hasInitCall = false
    var password: String = ""
    var repeatPassword: String = ""

    private let userUseCase: UserUseCaseProtocol
    private let router: ChangePasswordRouter

    // MARK: Init
    init(
        userUseCase: UserUseCaseProtocol,
        router: ChangePasswordRouter
    ) {
        self.userUseCase = userUseCase
        self.router = router
    }

    // MARK: Functions
    @MainActor
    func changePassword() {
        Task {
            do {
                hasInitCall = true
                defer { hasInitCall = false }
                if areValidsFields() {
                    try await userUseCase.updatePassword(with: password)
                    router.showToast(with: ToastType.password.message)
                }
            } catch {
                if let error = error as? UserError {
                    handle(this: error)
                } else {
                    router.showAlert(with: error)
                }
            }
        }
    }
}

// MARK: - Navigation
extension ChangePasswordViewModel {
    func dismiss() {
        router.dismiss()
    }
}

// MARK: - Private functions
private extension ChangePasswordViewModel {
    func areValidsFields() -> Bool {
        [passwordValidationResult, repeatedPasswordValidationResult].allSatisfy {$0 == .success}
    }
    func handle(this error: UserError) {
        switch error {
        case .inputsError(let fields, let messages):
            fields.enumerated().forEach { index, field in
                if field == "password" {
                    passwordValidationResult = .failure(message: messages[index])
                }
            }
        default:
            router.showAlert(with: error)
        }
    }
}
