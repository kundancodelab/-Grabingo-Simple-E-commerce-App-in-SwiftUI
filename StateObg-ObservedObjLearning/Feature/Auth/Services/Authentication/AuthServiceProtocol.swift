//
//  AuthServiceProtocol.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 14/09/25.
//

import Foundation
import FirebaseAuth
// Services/Authentication/AuthServiceProtocol.swift
protocol AuthServiceProtocol {
    func signOut() throws
}

protocol GoogleAuthServiceProtocol: AuthServiceProtocol {
    func signIn(completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void)
}
protocol AppleAuthServiceProtocol: AuthServiceProtocol {
    func signIn(completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void)
}
// EmailAuthServiceProtocol.swift
protocol EmailAuthServiceProtocol: AuthServiceProtocol {
    func signUp(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void)
    func signIn(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)
}
