import Foundation

@Observable
final class UserContactViewModel: ChangeSelectedPrefix {
    private let userUseCase: UserUseCaseProtocol
    private let router: UserContactRouter
    private let prefixesUseCase: PrefixesUseCaseProtocol

    var prefixes = [Prefix]()
    var selectedPrefix: Prefix?
    var phoneValidationResult: ValidationResult = .success
    var nameValidationResult: ValidationResult = .success
    var name: String = ""
    var phone: String = ""

    init(userUseCase: UserUseCaseProtocol,
         router: UserContactRouter,
         prefixesUseCase: PrefixesUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.router = router
        self.prefixesUseCase = prefixesUseCase
    }

    @MainActor
    func getUser() {
        Task {
            do {
                let user = try await userUseCase.getUser()
                name = user.fullname
                phone = user.phone
            } catch {
                if let error = error as? UserError {
                    handle(error)
                } else {
                    router.showAlert(with: error)
                }
            }
        }
    }

    @MainActor
    func getPrefixes() {
        prefixes = prefixesUseCase.getPrefixes()
        selectedPrefix = prefixes.first(where: { $0.code == Locale.current.region?.identifier })
    }

    // MARK: - ChangeSelectedPrefix
    func changeSelectedPrefix(_ prefix: Prefix) {
        self.selectedPrefix = prefix
    }
}

// MARK: - Navigation
extension UserContactViewModel {
    func dismiss() {
        router.dismiss()
    }

    func presentPrefixList() {
        if let selectedPrefix {
            router.presentPrefixList(
                selectedPrefix: selectedPrefix,
                prefixes: prefixes,
                delegate: self
            )
        }
    }
}

// MARK: - Private functions
private extension UserContactViewModel {
    @MainActor
    func updateUser() {
        Task {
            do {
                if phoneValidationResult == .success {
                    _ = try await userUseCase.updateUser(name: name, phone: phone)
                    router.showToast(with: "personalData_savedSuccess")
                    router.dismiss()
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

    func handle(_ error: UserError) {
        switch error {
        case .inputsError(let fields, let messages):
            fields.enumerated().forEach { index, field in
                if field == "fullname" {
                    nameValidationResult = .failure(message: messages[index])
                }
                if field == "phone" {
                    phoneValidationResult = .failure(message: messages[index])
                }
            }
        case .inputFullnameError(let message):
            nameValidationResult = .failure(message: message)
        case .inputPhoneError(let message):
            phoneValidationResult = .failure(message: message)
        default:
            router.showAlert(with: error)
        }
    }
}
