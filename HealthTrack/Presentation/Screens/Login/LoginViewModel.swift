//
//  LoginViewModel.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 4/7/24.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn

// NOTE: LoginViewModel mantiene ObservableObject debido a que ASAuthorizationControllerDelegate
// requiere herencia de NSObject, lo cual es incompatible con @Observable.
// Considerar extraer la lógica de Apple Sign-In a un helper separado en el futuro.
final class LoginViewModel: NSObject, ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""

    @Published var emailValidationResult: ValidationResult = .success
    @Published var passwordValidationResult: ValidationResult = .success
    @Published var showToast = false
    @Published var allFieldsAreValid = false

    private let authUseCase: AuthUseCaseProtocol
    private let router: LoginRouter

    init(authUseCase: AuthUseCaseProtocol,
         router: LoginRouter) {
        self.authUseCase = authUseCase
        self.router = router
    }

    @MainActor
    func login() {
        Task {
            do {
                if areValidsFields() {
                    try await authUseCase.login(with: email, and: password)
                }
            } catch {
                if let error = error as? AuthError {
                    handle(error)
                } else {
                    router.showAlert(with: error)
                }
            }
        }
    }

    @MainActor
    func resentVerificationLink() {
        Task {
            do {
                if !email.isEmpty {
                    try await authUseCase.recoverPassword(with: email)
                }
            } catch {
                if let error = error as? AuthError {
                    handle(error)
                } else {
                    router.showAlert(with: error)
                }
            }
        }
    }

    private func areValidsFields() -> Bool {
        emailValidationResult == .success &&
        passwordValidationResult == .success
    }

    private func handle(_ error: AuthError) {
        switch error {
        case .inputEmailError:
            emailValidationResult = .failure(message: error.message)
        case .inputPasswordError:
            passwordValidationResult = .failure(message: error.message)
        case .inputsError(let fields, let messages):
            fields.enumerated().forEach { index, field in
                if field == "email" {
                    emailValidationResult = .failure(message: messages[index])
                }
                if field == "password" {
                    passwordValidationResult = .failure(message: messages[index])
                }
            }
        case .notVerified:
            router.showNotVerifiedAlert(error, resendAction: {})
        default:
            router.showAlert(with: error)
        }
    }
}

// MARK: - Apple Login
extension LoginViewModel: ASAuthorizationControllerDelegate {
    func loginWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    @MainActor
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let authorizationCode = appleIDCredential.authorizationCode,
           let code = String(data: authorizationCode, encoding: .utf8) {
            loginWithApple(code: code)
        }
    }

    @MainActor
    private func loginWithApple(code: String) {
        Task {
            do {
                try await authUseCase.loginWithApple(code: code)
            } catch {
                if let error = error as? AuthError {
                    handle(error)
                } else {
                    router.showAlert(with: error)
                }
            }
        }
    }
}

// MARK: - Google Login
extension LoginViewModel {
    @MainActor
    func loginWithGoogle() {
        Task {
            do {
                if let rootViewController = getRootViewController(),
                   let result = try? await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController),
                   let token = result.user.idToken?.tokenString {
                    try await authUseCase.loginWithGoogle(token: token)
                } else {
                    throw AppError.generalError
                }
            } catch {
                if let error = error as? AuthError {
                    handle(error)
                } else {
                    router.showAlert(with: error)
                }
            }
        }
    }

    private func getRootViewController() -> UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
}

// MARK: - Navigation
extension LoginViewModel {
    func dismiss() {
        router.dismiss()
    }

    func goToRegister() {
        router.goToRegister()
    }

    func goToRecoverPassword() {
        router.goToRecoverPassword()
    }
}
