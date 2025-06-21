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
                    // call register api.
                } label: {
                    Text("Register")
                        .font(.system(size: 20,weight: .semibold))
                        .foregroundStyle(Color.gray)
                    
                }
                .buttonStyle(CapsuleStyleButton(bgColor: .black, textColor: .white, hasBorder: true))
                .padding(.horizontal)
                .padding(.top, 24)

                
                // Socail logins
                
                VStack(alignment:.center, spacing: 16){
                        //MARK: google login
                        Button {
                         
                        } label: {
                            Text("Continue with Google")
                               
                                .frame(height: 40)
                            
                        }.frame(maxWidth: .infinity)
                        
                        //MARK:  Apple Login
                        Button {
                            
                        } label: {
                            Text("Continue with Apple")
                                .frame(height: 40)
                            
                        }.frame(maxWidth: .infinity)

                }
                Spacer()
                
            }
        }
    }
}

#Preview {
    SignUpView()
}
