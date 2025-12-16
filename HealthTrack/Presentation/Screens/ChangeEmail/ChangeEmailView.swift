//
//  ChangeEmailView.swift
//  Gula
//
//  Created by Jesu Castellano on 5/11/24.
//

import SwiftUI

struct ChangeEmailView: View {
    @ObservedObject var viewModel: ChangeEmailViewModel
    @State private var isFieldEmptyCheckedFromView = false
    @FocusState var isFocusedEmailField: Bool

    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("auth_updateEmail")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(.system(size: 14))
                    .bold()
                Text("auth_changeEmailInfo")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity,alignment: .leading)
            }
            .padding(.top, 24)
            .padding(.bottom, 40)

            emailTextField

            CustomButton(
                buttonState: $viewModel.sendButtonState,
                type: .primary,
                buttonText: "auth_update"
            ) {
                emailTextField.validate()
                isFocusedEmailField = false
                isFieldEmptyCheckedFromView = viewModel.email.isEmpty
                viewModel.changeEmail()
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            setupToolbar()
        }
    }

    @ToolbarContentBuilder
    private func setupToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("auth_changeEmailToolbarTitle")
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
    private var emailTextField: StandardTextField {
        StandardTextField(
            text: $viewModel.email,
            isFocused: _isFocusedEmailField,
            title: "auth_newEmail",
            placeholder: "auth_writeEmail",
            validationResult: $viewModel.emailValidationResult,
            validations: [
                .isRequired,
                .email(regex: nil)
            ]
        )
    }
}
