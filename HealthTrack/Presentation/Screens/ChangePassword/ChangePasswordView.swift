//
//  Gula
//
//  ChangePasswordView.swift
//
//  Created by Rudo Apps on 7/5/25
//

import SwiftUI

struct ChangePasswordView: View {
    @State var viewModel: ChangePasswordViewModel
    @State private var sendButtonState: ButtonState = .normal
    @FocusState var isFocusedNewPasswordTextField: Bool
    @FocusState var isFocusedRepeatPasswordTextField: Bool

    var body: some View {
        VStack(alignment: .leading) {
            header
            fields
            Spacer()
        }
        .onChange(of: viewModel.hasInitCall) {
            sendButtonState = viewModel.hasInitCall ? .loading : .normal
        }
        .padding(.horizontal, 16)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            setupToolbar()
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

}

// MARK: - Private views
private extension ChangePasswordView {
    @ToolbarContentBuilder
    func setupToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("auth_password")
                .font(.system(size: 20))
                .foregroundStyle(.white)
        }
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(maxWidth: 16, maxHeight: 16)
                }
            }
        }
    }

    @ViewBuilder
    var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("auth_updateWriteNewPassword")
                .font(.system(size: 16, weight: .semibold))
            Text("auth_newPasswordInformation")
                .font(.system(size: 16, weight: .regular))
                .lineSpacing(8)
        }
        .padding(.bottom, 32)
        .padding(.top, 24)
    }

    @ViewBuilder
    var fields: some View {
        VStack {
            passwordTextField
            repeatPasswordTextField
            CustomButton(
                buttonState: $sendButtonState,
                type: .primary,
                buttonText: "auth_update"
            ) {
                passwordTextField.validate()
                repeatPasswordTextField.validate()
                isFocusedNewPasswordTextField = false
                isFocusedRepeatPasswordTextField = false
                viewModel.changePassword()
            }
        }
    }

    @ViewBuilder
    var passwordTextField: PasswordTextField {
        PasswordTextField(
            text: $viewModel.password,
            isFocused: _isFocusedNewPasswordTextField,
            title: "auth_newPassword",
            placeholder: "auth_newPassword",
            validationResult: $viewModel.passwordValidationResult,
            validations: [
                .isRequired,
                .max(15),
                .password(regex: nil)
            ]
        )
    }

    @ViewBuilder
    var repeatPasswordTextField: PasswordTextField {
        PasswordTextField(
            text: $viewModel.repeatPassword,
            isFocused: _isFocusedRepeatPasswordTextField,
            validationResult: $viewModel.repeatedPasswordValidationResult,
            validations: [
                .isRequired,
                .max(15),
                .password(regex: nil),
                .matchTexts(matchText: viewModel.password)
            ]
        )
    }
}
