//
//  OverlayPresentation.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

protocol OverlayPresentationProtocol {
    // MARK: - Toast
    var toastView: AnyView? { get set }

    // MARK: - Alert
    var alertModel: AlertModel { get }
    var isPresentingAlert: Bool { get set }

    // MARK: - Confirmation Dialog
    var confirmationDialogView: (() -> AnyView)? { get }
    var isPresentingConfirmationDialog: Bool { get set }

    // MARK: - Full Screen Overlay
    var fullOverScreenView: AnyView? { get }
    var isPresentingFullOverScreen: Bool { get set }

    // MARK: - Methods
    func showAlert(alertModel: AlertModel)
    func showToast(from view: any View)
    func presentFullOverScreen(view: any View)
    func dismissToast()
}
