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
                    
                    LoginSignUpVM.signInWithEmail(email: email, password: password)
                    
                } label: {
                    Text("Login")
                        .font(.system(size: 20,weight: .semibold))
                        .foregroundStyle(Color.gray)
                    
                }
                .buttonStyle(CapsuleStyleButton(bgColor: .black, textColor: .white, hasBorder: true))
                .padding(.horizontal)
                .padding(.top, 24)
                .alert("Grabingo", isPresented: $LoginSignUpVM.isError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    if LoginSignUpVM.errorMessage.isEmpty {
                        Text(" Registration failed or canceled please try again")
                    }else {
                        Text("\(LoginSignUpVM.errorMessage)")
                    }
                    
                }
                
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
                        
                        LoginSignUpVM.signInWithGoogle()
                        
                    } label: {
                        Text("Continue with Google")
                            .frame(height: 40)
                        
                    }.frame(maxWidth: .infinity)
                        .alert("Grabingo", isPresented: $LoginSignUpVM.isError) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            if LoginSignUpVM.errorMessage.isEmpty {
                                Text(" sign - in google failed or canceled please try again")
                            }else {
                                Text("\(LoginSignUpVM.errorMessage)")
                            }
                            
                        }
                    
                    //MARK:  Apple Login
                    Button {
                        
                        LoginSignUpVM.signInWithApple()
                    } label: {
                        Text("Continue with Apple")
                            .frame(height: 40)
                        
                    }.frame(maxWidth: .infinity)
                        .alert("Grabingo", isPresented: $LoginSignUpVM.isError) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            if LoginSignUpVM.errorMessage.isEmpty {
                                Text(" sign -in with Apple  failed or canceled please try again")
                            }else {
                                Text("\(LoginSignUpVM.errorMessage)")
                            }
                            
                        }
                    
                }
                Spacer()
                
            }
            .navigationDestination(isPresented: $isSignUpTap) {
                SignUpView()
                //  .environmentObject(authViewModel)
                    .environmentObject(LoginSignUpVM)
                
            }
            .navigationDestination(isPresented: $LoginSignUpVM.didLoginSuccess) {
                MainTabBarView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $LoginSignUpVM.didRegisterSuccess) {
                MainTabBarView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $LoginSignUpVM.didAppleLoginSuccess) {
                MainTabBarView()
                    .navigationBarBackButtonHidden(true)
            }
          
          
           
            
            if LoginSignUpVM.isLoading {
                CustomLoader()
            }
        }
    }
    
}
#Preview {
    LoginView()
}

