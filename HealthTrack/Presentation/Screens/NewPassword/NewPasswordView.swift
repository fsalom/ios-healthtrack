//
//  NewPasswordView.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 22/7/24.
//

import SwiftUI

struct NewPasswordView: View {
    @State var viewModel: NewPasswordViewModel
    @FocusState var isFocusedNewPasswordTextField: Bool
    @FocusState var isFocusedRepeatPasswordTextField: Bool
    @State var sendButtonState: ButtonState = .normal

    var body: some View {
        VStack(alignment: .leading) {
            header
            fields
            Spacer()
        }
        .onChange(of: viewModel.isLoading) {
            sendButtonState = viewModel.isLoading ? .loading : .normal
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .padding(.horizontal, 16)
        .toolbar {
            setupToolbar()
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Private views
private extension NewPasswordView {
    var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("auth_writeNewPassword")
                .font(.system(size: 16, weight: .semibold))
            Text("auth_newPasswordInformation")
                .font(.system(size: 16, weight: .regular))
                .lineSpacing(8)
        }
        .padding(.bottom, viewModel.userId != nil ? 44 : 32)
        .padding(.top, 24)
    }

    var fields: some View {
        VStack {
            passwordTextField

            repeatedPasswordTextField

            CustomButton(
                buttonState: $sendButtonState,
                type: .primary,
                buttonText: "auth_update"
            ) {
                passwordTextField.validate()
                repeatedPasswordTextField.validate()
                isFocusedNewPasswordTextField = false
                isFocusedRepeatPasswordTextField = false

                if viewModel.areFieldsValids() {
                    viewModel.changePassword()
                }
            }
        }
    }

    @ToolbarContentBuilder
    func setupToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("auth_newPassword")
                .font(.system(size: 20))
                .foregroundStyle(.white)
        }
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Button {
                    // TODO: -  Remove in destination app
                    viewModel.goToMainMenu()
                } label: {
                    toolBarBackButtonImage(systemName: "xmark")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(maxWidth: 16, maxHeight: 16)
                }
            }
        }
    }

    func toolBarBackButtonImage(systemName: String) -> Image {
        Image(systemName: systemName)
    }

    @ViewBuilder
    var passwordTextField: PasswordTextField {
        PasswordTextField(
            text: $viewModel.password,
            isFocused: _isFocusedNewPasswordTextField,
            title: "auth_newPassword",
            placeholder: "auth_newPassword",
            validationResult: $viewModel.passwordValidationResult,
            validations: [.isRequired, .max(15), .password(regex: nil)]
        )
    }

    @ViewBuilder
    var repeatedPasswordTextField: PasswordTextField {
        PasswordTextField(
            text: $viewModel.repeatPassword,
            isFocused: _isFocusedNewPasswordTextField,
            title: "auth_repeatPassword",
            placeholder: "auth_repeatNewPassword",
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
