//
//  Gula
//
//  DeeplinkResendViewModel.swift
//
//  Created by Rudo Apps on 9/5/25
//

import Foundation

final class DeeplinkResendViewModel: ObservableObject {
    private let useCase: DeeplinkManagerUseCaseProtocol
    private let router: DeeplinkResendRouter
    let config: DeeplinkResendConfig

    init(useCase: DeeplinkManagerUseCaseProtocol,
         config: DeeplinkResendConfig,
         router: DeeplinkResendRouter) {
        self.useCase = useCase
        self.config = config
        self.router = router
    }

    @MainActor
    func resendLinkVerification() {
        Task {
            do {
                try await useCase.resendLinkVerification(email: config.email)
                router.showToast(with: "auth_changeEmailSent")
            } catch {
                router.showAlert(with: error)
            }
        }
    }
}

// MARK: - Navigation
extension DeeplinkResendViewModel {
    func dismiss() {
        router.dismiss()
    }

    // TODO: -  Remove in destination app
    func goToMainMenu() {
        router.goToMainMenu()
    }
}
