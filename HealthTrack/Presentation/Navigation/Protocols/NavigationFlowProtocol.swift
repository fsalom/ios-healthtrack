//
//  NavigationFlow.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

/// Protocol that defines the navigation flow capabilities
/// Handles stack navigation, sheets, tabs, and screen transitions
protocol NavigationFlowProtocol {
    // MARK: - Stack Navigation
    var path: [Page] { get set }
    var root: Page? { get }

    // MARK: - Sheet Navigation
    var sheet: Page? { get set }
    var fullOverSheet: Page? { get set }
    var nestedSheet: Page? { get set }
    var fullOverNestedSheet: Page? { get set }

    // MARK: - Tab Navigation
    var tabIndex: Int { get set }
    var tabBadges: [TabItem: Int] { get set }

    // MARK: - Configuration
    var isEnabledBackGesture: Bool { get set }

    // MARK: - Methods
    func initialize(root view: any View)
    func push(to view: any View)
    func pushAndRemovePrevious(to view: any View)
    func dismiss()
    func dismissSheet()
    func dismissFullOverScreen()
    func dismissAll()
    func replaceRoot(to view: any View)
    func present(view: any View)
    func presentCustomConfirmationDialog(from view: (() -> AnyView)?)
    func changeTab(index: Int)
}
