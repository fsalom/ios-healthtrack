//
//  VerifyPasswordView.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 4/11/24.
//

import SwiftUI

struct VerifyPasswordView: View {
    @State var viewModel: VerifyPasswordViewModel
    @State var buttonState: ButtonState = .normal
    @FocusState var isFocusedPasswordTextField: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                header
                passwordTextField
                CustomButton(
                    buttonState: $buttonState,
                    type: .primary,
                    buttonText: "common_continue",
                    action: {
                        passwordTextField.validate()
                        isFocusedPasswordTextField = false
                        viewModel.verifyPassword()
                    }
                )
            }
            .padding(.horizontal, 16)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .presentationDetents([.height(204)])

        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("auth_updatePassword")
                .font(.system(size: 14, weight: .medium))
                .padding(.top, 16)
            Text("auth_updatePasswordMessage")
                .font(.system(size: 14, weight: .regular))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var passwordTextField: PasswordTextField {
        PasswordTextField(
            text: $viewModel.password,
            isFocused: _isFocusedPasswordTextField,
            title: "auth_actualPassword",
            placeholder: "auth_actualPassword",
            validationResult: $viewModel.passwordValidationResult,
            validations: [
                .isRequired,
                .max(15),
                .password(regex: nil)
            ]
        )
    }
}
