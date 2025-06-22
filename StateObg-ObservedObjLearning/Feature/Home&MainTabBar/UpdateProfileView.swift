//
//  UpdateProfileView.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 22/06/25.
//

import SwiftUI

struct UpdateProfileView: View {
    @EnvironmentObject var LoginSignUpVM : Login_SignUpVM
    @State private var showSuccessToast = false
    @State private var isloading:Bool = false
 //   @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State var username : String = ""
    @State var email   : String = ""
    @State var password : String = ""
    var body: some View {
        ZStack {
            Color.primaryTheme.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading,spacing: 20) {
                HStack {
                    Spacer()
                    ZStack {
                        
                        
                        Button {
                            
                        } label: {
                            if let photoURL = URL(string: LoginSignUpVM.currentUser?.photoURL ?? ""), ((LoginSignUpVM.currentUser?.photoURL.isEmpty) == nil) {
                                AsyncImage(url: photoURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 70, height: 70)
                                }
                            } else {
                                Text((LoginSignUpVM.currentUser?.name.initials())!)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .frame(width: 120, height: 120)
                                    .background(Color(.systemGray))
                                    .clipShape(Circle())
                            }
                            
                            
                        }
                        
                        Image(systemName: "camera.fill")
                            .padding(.top, 115)
                            .padding(.leading, 24)
                            .foregroundStyle(Color.white)
                    }
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
                
                // user name field
                InputView(placeholder: LoginSignUpVM.currentUser?.name ?? "", text: $username)
                    .keyboardType(.default)
                    .textContentType(.username)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal)
                InputView(placeholder: LoginSignUpVM.currentUser?.email ?? "", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal)
                
                HStack {
                    // MARK: Update user details api
                
                    Button {
                        isloading = true
                        let updatedData: [String: Any] = [
                            "name": username,
                            "email": email
                        ]

                        LoginSignUpVM.updateUserByUID(uid: LoginSignUpVM.currentUser?.id ?? "", updates: updatedData) { success, error in
                            isloading = false
                            if success {
                                withAnimation {
                                    showSuccessToast = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showSuccessToast = false
                                    }
                                    dismiss()
                                }
                                
                            } else {
                                print(" Update failed:", error ?? "Unknown error")
                            }
                        }
                    } label: {
                        Text("Update Profile")
                            .frame(maxWidth: .infinity)
                    } .buttonStyle(CapsuleStyleButton(bgColor: .black, textColor: .white, hasBorder: true))
                        .padding(.horizontal)
                        .padding(.top, 24)
                       
                }
                Spacer()
            }
            if isloading {
                ProgressView()
                    .frame(width: 80, height: 80)
            }
            if showSuccessToast {
                TopToastView(message: "Profile Updated Successfully")
            }
        }
    }
}

#Preview {
    UpdateProfileView()
}
