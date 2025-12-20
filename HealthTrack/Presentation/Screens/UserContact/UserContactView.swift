//
//  ContactView.swift
//  Gula
//
//  Created by Jorge on 29/8/24.
//

import SwiftUI

struct UserContactView: View {
    @State var viewModel: UserContactViewModel
    @State private var continueButtonState: ButtonState = .normal
    @State private var isFieldEmptyCheckedFromView = false
    @FocusState var isFocusedNameTextField: Bool
    @FocusState var isFocusedPhoneTextField: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("personalData_changePersonalData")
            Text("personalData_changePersonalDataInfo")
            textFields
            Spacer()
            CustomButton(buttonState: $continueButtonState,
                         type: .primary,
                         buttonText: "common_save") {
                didUpdateUserButtonPressed()
            }
                         .padding(.bottom, 10)
        }
        .toolbar {
            setupToolbar()
        }
        .toolbar(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .onAppear {
            viewModel.getUser()
            viewModel.getPrefixes()
        }
    }

    @ToolbarContentBuilder
    private func setupToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("personalData_personalData")
                .font(.system(size: 20))
                .foregroundStyle(.white)
        }
        ToolbarItem(placement: .topBarLeading) {
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

    @ViewBuilder
    private var textFields: some View {
        VStack(spacing: 0) {
            nameTextField
            phoneTextField
        }
        .padding(.top, 20)
    }

    @ViewBuilder
    var nameTextField: StandardTextField {
        StandardTextField(
            text: $viewModel.name,
            isFocused: _isFocusedNameTextField,
            title: "personalData_completeName",
            placeholder: "personalData_completeName",
            validationResult: $viewModel.nameValidationResult,
            validations: [.isRequired]
        )
    }

    @ViewBuilder
    var phoneTextField: PhoneTextField? {
        if let selectedPrefix = viewModel.selectedPrefix {
            PhoneTextField(
                text: $viewModel.phone,
                isFocused: _isFocusedPhoneTextField,
                title: "personalData_phone",
                placeholder: "personalData_phone",
                selectedPrefix: $viewModel.selectedPrefix,
                validationResult: $viewModel.phoneValidationResult,
                onTapPrefix: {
                    viewModel.presentPrefixList()
                },
                validations: [
                    .isRequired,
                    .min(selectedPrefix.minDigits),
                    .max(selectedPrefix.maxDigits),
                    .phone(regex: selectedPrefix.regex)
                ]
            )
        }
    }

    private func didUpdateUserButtonPressed() {
        nameTextField.validate()
        phoneTextField?.validate()
        isFocusedNameTextField = false
        isFocusedPhoneTextField = false
    }
}
