//
//  CustomButton.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 4/7/24.
//

import SwiftUI

struct CustomButton: View {
    @Binding var buttonState: ButtonState
    let type: ButtonType
    let height: CGFloat = 48
    let buttonText: LocalizedStringKey
    var backgroundColor: Color?
    var foregroundColor: Color?
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            switch buttonState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
            default:
                Text(buttonText)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .background(
                        (backgroundColor ?? type.background)
                            .opacity(buttonState.opacity)
                    )
                    .foregroundColor(foregroundColor ?? type.foregroundColor.opacity(type == .primary ? 1 : buttonState.opacity))
                    .foregroundStyle(type.foregroundColor.opacity(type == .primary ? 1 : buttonState.opacity))
            }
        }
        .cornerRadius(6)
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(buttonState.opacity), lineWidth: type.borderWidth)
        }
    }
}
