//
//  DeeplinkManager.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 23/7/24.
//

import SwiftUI

protocol DeepLinkManagerProtocol {
    var id: String? { get set }
    var screen: DeepLinkManager.Destination { get set }
    func manage(this deeplink: URL)
    func navigate(to screen: DeepLinkManager.Destination)
}

class DeepLinkManager: ObservableObject, DeepLinkManagerProtocol {
    static var shared: DeepLinkManager = .init(scheme: Config.scheme)

    enum Destination: String {
        case none = "__none__"
        case newPassword = "newpassword"
        case registerComplete = "register/verify"
        case changeEmailComplete = "change-email/verify"
        case home = "home"
    }

    @Published var screen: Destination = .none
    var id: String?

    private let scheme: String
    private let navigator: NavigatorProtocol

    private init(scheme: String, navigator: NavigatorProtocol = Navigator.shared) {
        self.scheme = scheme
        self.navigator = navigator
    }

    func manage(this deeplink: URL) {
        if deeplink.scheme == self.scheme,
           let host = deeplink.host {

            if let components = URLComponents(url: deeplink, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let id = queryItems.first(where: { $0.name == "suid" })?.value {
                self.id = id
            }

            let path = "\(host)\(deeplink.path)"
            self.screen = Destination(rawValue: path) ?? .none
            navigate(to: self.screen)
        }
    }

    func navigate(to screen: Destination) {
        switch self.screen {
        case .none:
            navigator.replaceRoot(to: GlucoseImportBuilder.build())
        case .newPassword:
            // TODO: Implement NewPasswordBuilder when needed
            navigator.replaceRoot(to: GlucoseImportBuilder.build())
        case .registerComplete:
            // TODO: Implement RegisterCompletedBuilder when needed
            navigator.replaceRoot(to: GlucoseImportBuilder.build())
            showRegisterCompletedToast()
        case .changeEmailComplete:
            navigator.replaceRoot(to: GlucoseImportBuilder.build())
            showChangeEmailCompletedToast()
        case .home:
            navigator.replaceRoot(to: GlucoseImportBuilder.build())
        }
    }

    private func showChangeEmailCompletedToast() {
        let toastView = ToastView(message: "changeEmailCompletedTitle",
                                           isCloseButtonActive: true,
                                           closeAction: {
            self.navigator.dismissToast()
        })
        navigator.showToast(from: toastView)
    }

    private func showRegisterCompletedToast() {
        let toastView =  ToastView(message: "registerCompletedTitle",
                                            isCloseButtonActive: true,
                                            closeAction: {
            self.navigator.dismissToast()
        })
        navigator.showToast(from: toastView)
    }
}
