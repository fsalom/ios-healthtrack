//
//  ChangeEmailViewModel.swift
//  Gula
//
//  Created by Jesu Castellano on 5/11/24.
//

import Foundation

@Observable
final class ChangeEmailViewModel {
    private let userUseCase: UserUseCaseProtocol
    private let router: ChangeEmailRouter

    var email: String = ""
    var emailValidationResult: ValidationResult = .success
    var sendButtonState: ButtonState = .normal

    // MARK: - Init
    init(
         userUseCase: UserUseCaseProtocol,
         router: ChangeEmailRouter
    ) {
        self.userUseCase = userUseCase
        self.router = router
    }

    @MainActor
    func changeEmail() {
        Task {
            do {
                if emailValidationResult == .success {
                    try await userUseCase.changeEmail(email)
                    router.goToEmptyView()
                }
            } catch {
                if let error = error as? UserError {
                    handle(error)
                } else {
                    router.showAlert(with: error)
                }
            }
        }
    }

    private func handle(_ error: UserError) {
        switch error {
        case .inputEmailError:
            emailValidationResult = .failure(message: error.message)
        default:
            router.showAlert(with: error)
        }
    }
}

// MARK: - Navigation
extension ChangeEmailViewModel {
    func dismiss() {
        router.dismiss()
    }
}
