//
//  AuthRouterView.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 29/09/25.
//

import Foundation
import SwiftUI

struct AuthRouterView: View {
    let authRoute: AuthRoute

    @ViewBuilder
    var body: some View {
        switch authRoute {
        case .login:
            LoginView()
        case .signup:
            SignUpView()
        case .forgotPassword:
            Text("Forgot Password")
        case .verifyOTP:
            Text("Verify OTP")
        }
    }
}
