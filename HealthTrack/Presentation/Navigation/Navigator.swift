//
//  Navigator.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

@Observable
class Navigator: NavigatorProtocol {

    // MARK: - Properties
    private(set) var root: Page?
    var path = [Page]()
    var sheet: Page?
    var fullOverSheet: Page?
    var nestedSheet: Page?
    var fullOverNestedSheet: Page?
    var toastView: AnyView?
    var tabIndex: Int = 0
    var tabBadges: [TabItem: Int] = [:]
    var fullOverScreenView: AnyView?
    var confirmationDialogView: (() -> AnyView)?
    var isEnabledBackGesture = true
    var alertModel: AlertModel = AlertModel()
    var isPresentingAlert = false
    var isPresentingConfirmationDialog = false {
        didSet {
            if isPresentingConfirmationDialog == false {
                confirmationDialogView = nil
            }
        }
    }
    var isPresentingFullOverScreen = false {
        didSet {
            if isPresentingFullOverScreen == false {
                fullOverScreenView = nil
                fullOverSheet = nil
                fullOverNestedSheet = nil
            }
        }
    }

    // MARK: - Init
    static var shared = Navigator()

    private init() {
        TabItem.allCases.forEach { tabBadges[$0] = 0 }
    }

    // MARK: - Methods
    func initialize(root view: any View) {
        root = Page(from: view)
    }
}

// MARK: - NavigationFlow
extension Navigator {
    func push(to view: any View) {
        path.append(Page(from: view))
    }

    func pushAndRemovePrevious(to view: any View) {
        path.append(Page(from: view))
        path.remove(at: path.count - 2)
    }

    func dismiss() {
        path.removeLast()
    }

    func dismissSheet() {
        if isPresentingFullOverScreen {
            if fullOverNestedSheet != nil {
                fullOverNestedSheet = nil
            } else {
                fullOverSheet = nil
            }
        } else {
            if nestedSheet != nil {
                nestedSheet = nil
            } else {
                sheet = nil
            }
        }
    }

    func dismissFullOverScreen() {
        isPresentingFullOverScreen = false
    }

    func dismissAll() {
        path.removeAll()
    }

    func replaceRoot(to view: any View) {
        root = Page(from: view)
        path.removeAll()
        sheet = nil
        nestedSheet = nil
        fullOverSheet = nil
        fullOverNestedSheet = nil
    }

    func present(view: any View) {
        if isPresentingFullOverScreen {
            if fullOverSheet != nil {
                fullOverNestedSheet = Page(from: view)
            } else {
                fullOverSheet = Page(from: view)
            }
        } else {
            if sheet != nil {
                nestedSheet = Page(from: view)
            } else {
                sheet = Page(from: view)
            }
        }
    }

    func presentCustomConfirmationDialog(from view: (() -> AnyView)?) {
        confirmationDialogView = view
        isPresentingConfirmationDialog = true
    }

    func changeTab(index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tabIndex = index
        }
    }
}

// MARK: - OverlayPresentation
extension Navigator {
    func showToast(from view: any View) {
        if toastView != nil {
            dismissToast()
        }
        toastView = AnyView(view)
    }

    func dismissToast() {
        toastView = nil
    }

    func showAlert(alertModel: AlertModel) {
        self.alertModel = alertModel
        isPresentingAlert = true
    }

    func presentFullOverScreen(view: any View) {
        fullOverScreenView = AnyView(view)
        isPresentingFullOverScreen =  true
    }
}
