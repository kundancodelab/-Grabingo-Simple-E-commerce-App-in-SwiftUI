//
//  AuthService.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 14/09/25.
//

import Foundation
// Services/Authentication/AuthService.swift
final class AuthService {
    let google: GoogleAuthServiceProtocol
    let apple: AppleAuthServiceProtocol
    let email: EmailAuthServiceProtocol
    
    init(google: GoogleAuthServiceProtocol = GoogleAuthService(),
         apple: AppleAuthServiceProtocol = AppleAuthService_Simple(),
         email: EmailAuthServiceProtocol = EmailAuthService()) {
        self.google = google
        self.apple = apple
        self.email = email
    }
}
