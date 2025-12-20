//
//  RegisterView.swift
//  Gula
//
//  Created by María on 31/7/24.
//
import SwiftUI

struct RegisterView: View {
    @State var viewModel: RegisterViewModel
    @State private var sendButtonState: ButtonState = .normal
    @FocusState var isFocusedFullNameTextField: Bool
    @FocusState var isFocusedPasswordTextField: Bool
    @FocusState var isFocusedEmailTextField: Bool
    @FocusState var isFocusedRepeatPasswordTextField: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Spacer()
                registerButtonView
                loginLinkView
            }
            .zIndex(1)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .padding(.horizontal, 16)

            ScrollView {
                Image(systemName: "photo.fill")
                    .resizable()
                    .frame(width: 83, height: 83)
                    .foregroundColor(Color.gray)
                    .clipShape(Circle())
                    .padding(.vertical, 32)
                fields
                    .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)

        }
        .onChange(of: viewModel.isLoading) {
            sendButtonState = viewModel.isLoading ? .loading : .normal
        }
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbar {
            setupToolbar()
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
    }

    @ToolbarContentBuilder
    private func setupToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(maxWidth: 16, maxHeight: 16)
                    .foregroundColor(.black)
            }
        }
        ToolbarItem(placement: .principal) {
            Text("auth_registerTitle")
                .font(.system(size: 18))
        }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 8) {
            nameTextField
            emailTextField
            passwordTextField
            repeatedPasswordTextField
        }
        .padding(.top, 24)
    }

    @ViewBuilder
    private var nameTextField: StandardTextField {
        StandardTextField(
            text: $viewModel.fullName,
            isFocused: _isFocusedFullNameTextField,
            title: "auth_fullName",
            placeholder: "auth_fullName",
            validationResult: $viewModel.nameValidationResult,
            validations: [.isRequired]
        )
    }

    @ViewBuilder
    private var emailTextField: StandardTextField {
        StandardTextField(
            text: $viewModel.email,
            isFocused: _isFocusedEmailTextField,
            title: "auth_email",
            placeholder: "auth_email",
            validationResult: $viewModel.emailValidationResult,
            validations: [.isRequired, .email(regex: nil)]
        )
    }

    @ViewBuilder
    private var passwordTextField: PasswordTextField {
        PasswordTextField(
            text: $viewModel.password,
            isFocused: _isFocusedPasswordTextField,
            title: "auth_password",
            subtitle: Text("register_passwordConditions"),
            placeholder: "auth_password",
            validationResult: $viewModel.passwordValidationResult,
            validations: [.isRequired, .password(regex: nil)]
        )
    }

    @ViewBuilder
    private var repeatedPasswordTextField: PasswordTextField {
        PasswordTextField(
            text: $viewModel.repeatedPassword,
            isFocused: _isFocusedRepeatPasswordTextField,
            title: "auth_repeatPassword",
            placeholder: "auth_repeatPassword",
            validationResult: $viewModel.repeatedPasswordValidationResult,
            validations: [
                .isRequired,
                .password(regex: nil),
                .matchTexts(matchText: viewModel.password)
            ]
        )
    }

    private var registerButtonView: some View {
        CustomButton(
            buttonState: $sendButtonState,
            type: .primary,
            buttonText: "auth_createAccount") {
                validateTextFields()
                viewModel.createAccountIfAreValidFields()
                removeFocusFields()
            }
    }

    private var loginLinkView: some View {
        HStack(alignment: .center) {
            Text("auth_haveAccount")
                .font(.system(size: 14))
                .foregroundColor(.black)
            Button(action: {
                viewModel.dismiss()
            }, label: {
                Text("auth_loginLowercased")
                    .underline()
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            })
        }
    }

    private func removeFocusFields() {
        isFocusedEmailTextField = false
        isFocusedPasswordTextField = false
        isFocusedFullNameTextField = false
        isFocusedRepeatPasswordTextField = false
    }

    private func validateTextFields() {
        nameTextField.validate()
        emailTextField.validate()
        passwordTextField.validate()
        repeatedPasswordTextField.validate()
    }
}
