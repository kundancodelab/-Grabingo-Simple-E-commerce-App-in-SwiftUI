
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: Login_SignUpVM
    @State private var isLoading = false
    @State private var loaderMessage = "Signing out..."
    @State private var isNavigateToCardsDetails = false
    @State private var isSignout:Bool = false
    @State private var isDeletingAcc:Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                if let user = viewModel.currentUser {
                    List {
                        Section {
                            HStack(spacing: 16) {
                                if let photoURL = URL(string: user.photoURL), !user.photoURL.isEmpty {
                                    AsyncImage(url: photoURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 70, height: 70)
                                    }
                                } else {
                                    Text(user.name.initials())
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .frame(width: 70, height: 70)
                                        .background(Color(.systemGray))
                                        .clipShape(Circle())
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Text(user.email)
                                        .font(.footnote)
                                }
                            }
                        }
                        
                        Section("Accounts") {
                            NavigationLink {
                                Text("Cards Details View") // Replace with actual view
                            } label: {
                                Label {
                                    Text("Cards Details")
                                        .foregroundStyle(.black)
                                } icon: {
                                    Image(systemName: "creditcard.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                            
                            NavigationLink {
                                UpdateProfileView()
                            } label: {
                                Label {
                                    Text("Update profile ")
                                        .foregroundStyle(.black)
                                } icon: {
                                    Image(systemName: "pencil")
                                        .foregroundStyle(.red)
                                }
                            }
                            // MARK: Signing out  Button Action
                            Button {
                                isSignout = true
                               
                            } label: {
                                Label {
                                    Text("Sign Out")
                                        .foregroundStyle(.black)
                                } icon: {
                                    Image(systemName: "arrow.left.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                            // MARK: Deleting acount Button action
                            Button {
                                isDeletingAcc = true
                                
                            } label: {
                                Label {
                                    Text("Delete Account")
                                        .foregroundStyle(.black)
                                } icon: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                } else {
                    VStack {
                        ProgressView("Please wait...")
                        Text("No user is currently logged in")
                            .padding(.top)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarBackButtonHidden(true)
            .alert("Grabingo", isPresented: $viewModel.isError) {
                Button("OK") {
                    viewModel.errorMessage = ""
                }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Grabingo", isPresented: $isSignout) {
                Button("OK") {
                    isLoading = true
                    loaderMessage = "Signing out..."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        viewModel.signOut()
                        isLoading = false
                    }
                }
                Button("Cancel", role: .cancel) {
                    isSignout = false
                }
            } message: {
                Text(ConfigAlertMessages.shared.signout)
            }

            .alert("Grabingo", isPresented: $isDeletingAcc) {
                Button("Delete", role: .destructive) {
                    isLoading = true
                    loaderMessage = "Deleting account..."
                    if let uid = viewModel.usersession?.uid {
                        viewModel.deleteUserByUID(uid: uid) { success, error in
                            isLoading = false
                            if success {
                                print("Account deleted")
                            } else {
                                print("Delete failed: \(error ?? "Unknown error")")
                            }
                        }
                    } else {
                        viewModel.errorMessage = "No user session found"
                        isLoading = false
                    }
                }
                Button("Cancel", role: .cancel) {
                    isDeletingAcc = false
                }
            } message: {
                Text(ConfigAlertMessages.shared.deleteAccout)
            }
         
            
            if isLoading {
                CustomLoader()
            }
        }
    }
}

// Extension to get initials from name
extension String {
    func initials() -> String {
        components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first?.uppercased() }
            .joined()
    }
}



#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(Login_SignUpVM())
    }
}

