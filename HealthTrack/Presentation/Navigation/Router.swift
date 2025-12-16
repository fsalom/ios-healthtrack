//
//  Router.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 31/7/25.
//

import SwiftUI

class Router {
    var navigator: NavigatorProtocol

    init(navigator: NavigatorProtocol = Navigator.shared) {
        self.navigator = navigator
    }

    // MARK: - Alerts
    func showAlert(title: String = "", message: String = "", action: @escaping () -> Void = {}) {
        let model = AlertModel(title: title, message: message, style: .info(action: action))
        navigator.showAlert(alertModel: model)
    }

    func showAlert(with error: Error, action: @escaping () -> Void = {}) {
        guard let error = error as? any DetailErrorProtocol else { return }
        let model = AlertModel(title: error.title, message: error.message, style: .error(acceptAction: action, cancelAction: {}))
        navigator.showAlert(alertModel: model)
    }

    // MARK: - Toast
    func showToast(with message: LocalizedStringKey, closeAction: @escaping () -> Void = {}) {
        let toastView = ToastView(
            message: message,
            isCloseButtonActive: true, closeAction: { [weak self] in
                guard let self else { return }
                self.navigator.dismissToast()
                closeAction()
            }
        )

        navigator.showToast(from: toastView)
    }

    // MARK: - Navigation actions
    func dismiss() {
        navigator.dismiss()
    }

    func dismissSheet() {
        navigator.dismissSheet()
    }

    func dismissFullOverScreen() {
        navigator.dismissFullOverScreen()
    }
}
