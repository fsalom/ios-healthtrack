//
//  RecoverPasswordView.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 17/7/24.
//

import SwiftUI

struct RecoverPasswordView: View {
    @State var viewModel: RecoverPasswordViewModel
    @FocusState var isFocusedEmailTextField: Bool
    @State var sendButtonState: ButtonState = .normal

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            header
            VStack {
                emailTextField
                CustomButton(
                    buttonState: $sendButtonState,
                    type: .primary,
                    buttonText: "auth_send"
                ) {
                    emailTextField.validate()
                    isFocusedEmailTextField = false
                    viewModel.recoverPassword()
                }
            }
            Spacer()
        }
        .onChange(of: viewModel.isLoading) {
            sendButtonState = viewModel.isLoading ? .loading : .normal
        }
        .padding(.horizontal, 16)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            setupToolbar()
        }
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Private views
private extension RecoverPasswordView {
    var header: some View {
        Text("auth_recoverPasswordInfo")
            .multilineTextAlignment(.leading)
            .font(.system(size: 14))
            .padding(.top, 24)
    }

    @ToolbarContentBuilder
    func setupToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("auth_recoverPassword")
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
                        .frame(maxWidth: 16, maxHeight: 16)
                        .foregroundColor(.white)
                }
            }
        }
    }

    @ViewBuilder
    var emailTextField: StandardTextField {
        StandardTextField(
            text: $viewModel.email,
            isFocused: _isFocusedEmailTextField,
            title: "auth_email",
            placeholder: "auth_writeEmail",
            validationResult: $viewModel.emailValidationResult,
            validations: [.isRequired, .email(regex: nil)]
        )
    }
}
