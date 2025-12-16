//
//  AccountView.swift
//  Gula
//
//  Created by Maria on 7/11/24.
//

import SwiftUI

enum AccountScreen: LocalizedStringKey, CaseIterable {
    case user = "account_user"
    case personalData = "account_personalData"
    case direction = "account_directions"
    case payment = "account_paymentMethod"
    case changePassword = "account_changePassword"
    case changeEmail = "account_changeEmail"
}

struct AccountView: View {
    @StateObject var viewModel: AccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(AccountScreen.allCases.indices, id: \.self) { index in
                    if index != 0 {
                        Divider().background(Color.gray)
                    }
                    menuRow(for: index)
                }
                Divider().background(Color.gray)
            }
            Button("alert_deleteAccountTitle") {
                viewModel.showDeleteAccountAlert()
            }
            .foregroundColor(.black)
            .font(.system(size: 18))
            .padding()
            Button("common_logout") {
                viewModel.showLogoutAlert()
            }
            .foregroundColor(.black)
            .font(.system(size: 18))
            .padding()
            Spacer()
        }
        .padding(.top, 16)
        .toolbar {
            setupToolbar()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.getUser()
        }
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
                    .foregroundColor(.white)
            }
        }
        ToolbarItem(placement: .principal) {
            Text("account_title")
                .font(.system(size: 18))
                .foregroundColor(.white)
        }

    }

    @ViewBuilder
    private func menuRow(for index: Int) -> some View {
        let screen = AccountScreen.allCases[index]
        switch screen {
        case .user:
            HStack {
                Text(viewModel.userName)
                    .font(.system(size: 16)).bold()
                    .foregroundColor(.black)
                    .padding(.vertical, 19)
                Spacer()
            }
            .padding(.horizontal)
        default:
            HStack {
                Text(screen.rawValue)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.vertical, 19)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .onTapGesture {
                viewModel.goToAccountScreen(screen)
            }
        }
    }
}
