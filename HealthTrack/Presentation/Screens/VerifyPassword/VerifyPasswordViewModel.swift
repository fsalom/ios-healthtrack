//
//  VerifyPasswordViewModel.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 4/11/24.
//

import Foundation

class VerifyPasswordViewModel: ObservableObject {
    // MARK: - Properties
    @Published var passwordValidationResult: ValidationResult = .success
    @Published var password: String = ""

    private let userUseCase: UserUseCaseProtocol
    private let router: VerifyPasswordRouter

    init(
        userUseCase: UserUseCaseProtocol,
        router: VerifyPasswordRouter
    ) {
        self.userUseCase = userUseCase
        self.router = router
    }

    @MainActor
    func verifyPassword() {
        Task {
            do {
                if passwordValidationResult == .success {
                    try await userUseCase.validatePassword(password)
                    router.goToChangePassword()
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

    private func handle(this error: UserError) {
        switch error {
        case .inputPasswordError:
            passwordValidationResult = .failure(message: error.message)
        default:
            router.showAlert(with: error)
        }
    }
}
