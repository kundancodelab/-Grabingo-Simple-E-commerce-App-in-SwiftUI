    //
    //  AuthRoute.swift
    //  StateObg-ObservedObjLearning
    //
    //  Created by User on 29/09/25.
    //

    import Foundation
    import SwiftUI
    enum AuthRoute:Codable , Hashable {
        case login
        case signup
        case forgotPassword
        case verifyOTP
      
        
    }

    extension Router {
        @ViewBuilder
        func authflow(authRoute:AuthRoute) -> some View {
            switch authRoute {
            case .login:
                LoginView()
            case .signup:
                SignUpView()
            case .forgotPassword:
                Text("Forgot password")
            case .verifyOTP:
                Text("Verify OTP")
         
            }
        }
    }
