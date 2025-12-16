//
//  NavigatorProtocol.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

/// Complete navigation protocol combining flow navigation and overlay presentation
///
/// NavigatorProtocol provides a unified interface for all navigation and overlay operations.
/// It combines two specialized protocols:
/// - `NavigationFlow`: Handles stack-based navigation (push, pop, sheets, tabs)
/// - `OverlayPresentation`: Handles transient UI overlays (alerts, toasts, dialogs)
///
/// This composition allows for flexible implementation and testing while maintaining
/// a clean separation of concerns between navigation flow and overlay presentation.
typealias NavigatorProtocol = NavigationFlowProtocol & OverlayPresentationProtocol
