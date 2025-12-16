//
//  UserRepositoryProtocol.swift
//  Gula
//
//  Created by Axel Pérez Gaspar on 22/8/24.
//

import Foundation

protocol UserRepositoryProtocol {
    func getUser() async throws -> User
    func updateUser(name: String, phone: String) async throws -> User
    func deleteAccount() async throws
    func validatePassword(_ password: String) async throws
    func updatePassword(with password: String) async throws
    func changeEmail(_ email: String) async throws
}
