//
//  AccountViewModel.swift
//  Gula
//
//  Created by Maria on 7/11/24.
//

import Foundation
import SwiftUI

class AccountViewModel: ObservableObject {
    // MARK: - Properties
    private let userUseCase: UserUseCaseProtocol
    private let authUseCase: AuthUseCaseProtocol
    private let router: AccountRouter
    @Published var userName: String = ""

    // MARK: - Init
    init(userUseCase: UserUseCaseProtocol,
         authUseCase: AuthUseCaseProtocol,
         router: AccountRouter) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
        self.router = router
    }

    // MARK: - Functions
    @MainActor
    func deleteAccount() {
        Task {
            do {
                try await userUseCase.deleteAccount()
                router.showToast(with: ToastType.deleteAccount.message)
                logout()
            } catch {
                router.showAlert(with: error)
            }
        }
    }

    @MainActor
    func getUser() {
        Task {
            do {
                let user = try await userUseCase.getUser()
                userName = user.fullname
            } catch {
                router.showAlert(with: error)
            }
        }
    }

    @MainActor
    func logout() {
        Task {
            do {
                try await authUseCase.logout()
            } catch {
                router.showAlert(with: error)
            }
        }
    }
}

// MARK: - Navigation
extension AccountViewModel {
    func dismiss() {
        router.dismiss()
    }

    @MainActor
    func showLogoutAlert() {
        router.showLogoutAlert { [weak self] in
            guard let self else { return }
            self.logout()
        }
    }

    @MainActor
    func showDeleteAccountAlert() {
        router.showDeleteAccountAlert { [weak self] in
            guard let self else { return }
            self.deleteAccount()
        }
    }

    func goToAccountScreen(_ screen: AccountScreen) {
        router.goToAccountScreen(screen)
    }
}
