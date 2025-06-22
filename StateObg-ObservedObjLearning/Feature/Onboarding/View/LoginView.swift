//
//  LoginView.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 22/06/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var isSignUpTap: Bool = false
    @State private var isLoading:Bool = false
    @State private var isNavigateHome:Bool = false
  //  @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var LoginSignUpVM: Login_SignUpVM
    @State private var isGoogleError : Bool = false
    @State private var isAppleError : Bool = false
    
    
   
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
                Text("Login ")
                    .font(.system(size: 30,weight: .heavy))
                    .padding(.leading, 12)
                
              
                
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
                
              
                //MARK:  Login Button
                Button {
                    // call register api.
                    isLoading = true
                    LoginSignUpVM.signInWithEmail(email: email, password: password) { success, userData in
                        isLoading = false
                        if success {
                            isNavigateHome = true
                        }else {
                            isError = true
                            print(LoginSignUpVM.errorMessage)
                        }
                    }
                                       
                } label: {
                    Text("Login")
                        .font(.system(size: 20,weight: .semibold))
                        .foregroundStyle(Color.gray)
                    
                }
                .buttonStyle(CapsuleStyleButton(bgColor: .black, textColor: .white, hasBorder: true))
                .padding(.horizontal)
                .padding(.top, 24)
                
               // Sign up Button.
                HStack {
                    Spacer()
                    Button {
                         isSignUpTap.toggle()
                    } label: {
                        Text("New here ? Pleease  Sign Up")
                            .fontWeight(.semibold)
                    }

                }.padding(.top,4)
                    .padding(.trailing, 20)
                // Socail logins
                VStack(alignment:.center, spacing: 16){
                        //MARK: google login
                        Button {
                            isLoading = true
                            LoginSignUpVM.signInWithGoogle { success, error in
                                isLoading = false
                                if success {
                                    isNavigateHome = true
                                } else {
                                    print("error")
                                    isLoading = false
                                    isGoogleError = true
                                }
                            }
                        } label: {
                            Text("Continue with Google")
                                .frame(height: 40)
                            
                        }.frame(maxWidth: .infinity)
                        
                        //MARK:  Apple Login
                        Button {
                            isLoading = true
                            LoginSignUpVM.signInWithApple { success, error in
                                isLoading = false
                                if success {
                                    isNavigateHome = true
                                } else {
                                    print("Apple login failed: \(LoginSignUpVM.errorMessage)")
                                   
                                    isAppleError = true
                                   
                                }
                            }
                        } label: {
                            Text("Continue with Apple")
                                .frame(height: 40)
                            
                        }.frame(maxWidth: .infinity)

                }
                Spacer()
                
            }
            .navigationDestination(isPresented: $isSignUpTap) {
                SignUpView()
                  //  .environmentObject(authViewModel)
                    .environmentObject(LoginSignUpVM)
                
            }
            .navigationDestination(isPresented: $isNavigateHome) {
                MainTabBarView()
                    .navigationBarBackButtonHidden(true)
            }
            .alert("Grabingo", isPresented: $isGoogleError) {
                Button("OK", role: .cancel) { }
            } message: {
                if LoginSignUpVM.errorMessage.isEmpty {
                    Text(" sign failed or canceled please try again")
                }else {
                    Text("\(LoginSignUpVM.errorMessage)")
                }
               
            }
            .alert("Grabingo", isPresented: $isAppleError) {
                Button("OK", role: .cancel) { }
            } message: {
                if LoginSignUpVM.errorMessage.isEmpty {
                    Text(" sign failed or canceled please try again")
                }else {
                    Text("\(LoginSignUpVM.errorMessage)")
                }
               
            }

            if isLoading {
                CustomLoader()
            }
        }
    }
}

#Preview {
    LoginView()
}

