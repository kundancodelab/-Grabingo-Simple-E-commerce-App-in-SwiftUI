//
//  SignUpView.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 21/06/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var username:String = ""
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var confirmPassword:String = ""
    @State private var isNavigateToHome: Bool = false
    @State private var isLoading:Bool =  false
    @State private var isNavigateToForgotPassView: Bool = false
    @State private var isNavigateToLoginView: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var LoginSignUpVM: Login_SignUpVM
    
    var isValidPassword: Bool {
           confirmPassword == password
       }
    var body: some View {
        ZStack {
            Color.primaryTheme
                .ignoresSafeArea(.all)
            
            VStack(alignment:.leading, spacing:20) {
                HStack {
                    Spacer()
                    Text("Grabingo")
                        .font(Font.custom("Snell Roundhand", size: 30))
                        .fontWeight(.heavy)
                    Spacer()
                }.padding(.top, 24)
                Text("Sign up")
                    .font(.system(size: 30,weight: .heavy))
                    .padding(.leading, 12)
                
               // Enter name text field.
                InputView(placeholder: "Enter your name", text: $username)
                    .keyboardType(.alphabet)
                    .textContentType(.username)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal)
                
                
                // Enter email
                InputView(placeholder: "Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal)
                
                // Enter password
                InputView(placeholder: "Enter your password", isSecureField: true, text: $password)
                    .keyboardType(.default)
                    .textContentType(.newPassword)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal)
                
                // confirm password
                ZStack(alignment: .trailing) {
                    InputView(placeholder: "Confirm password", text: $confirmPassword)
                        .keyboardType(.default)
                        .textContentType(.newPassword)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.words)
                        
                    Spacer()
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        Image(systemName: "\(isValidPassword ? "checkmark" : "xmark").circle.fill")
                            .imageScale(.large)
                            .fontWeight(.bold)
                            .foregroundColor(isValidPassword ? Color(.darkGray) : Color(.white))
                            .padding(.trailing,8)
                    }
                }.padding(.horizontal)
                
                //MARK:  Register Button
                Button {
                    LoginSignUpVM.signUpWithEmail(name: username, email: email, password: password)
                } label: {
                    Text("Register")
                        .font(.system(size: 20,weight: .semibold))
                        .foregroundStyle(Color.gray)
                    
                }
                .buttonStyle(CapsuleStyleButton(bgColor: .black, textColor: .white, hasBorder: true))
                .padding(.horizontal)
                .padding(.top, 24)

                
                HStack {
                    Button("Forgot Password") {
                        isNavigateToForgotPassView.toggle()
                    }
                }
                
                Spacer()
                
            }
           
            .navigationDestination(isPresented: $LoginSignUpVM.didRegisterSuccess) {
                MainTabBarView()
                    .navigationBarBackButtonHidden(true)
                
            }
            .navigationDestination(isPresented: $isNavigateToForgotPassView) {
                // we will implement forgot password view.
            }
            .navigationDestination(isPresented: $LoginSignUpVM.didLoginSuccess) {
                LoginView()
            }
            if LoginSignUpVM.isLoading {
                CustomLoader()
            }
                     
        }
    }
}

#Preview {
    SignUpView()
}
