import SwiftUI
import FirebaseDatabaseInternal
import FirebaseAuth
import Combine

@MainActor
final class Login_SignUpVM: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoginFailed = false
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var isError: Bool = false
    @Published var usersession: FirebaseAuth.User?
    @Published var currentUser: UserData?
    @Published var isLoading: Bool = false
    @Published var didLoginSuccess: Bool = false
    @Published var didRegisterSuccess: Bool = false
    @Published var didUpdateUserProfileSuccess: Bool = false
    @Published var didGoogleLoginSuccess: Bool = false
    @Published var didAppleLoginSuccess: Bool = false
    @Published var didResetPasswordSuccess: Bool = false
    @Published var didDeleteUserSuccess: Bool = false


    // MARK: - Private Properties
    private let authService: AuthService
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(authService: AuthService = AuthService(),
         userService: UserServiceProtocol = UserService()) {
        self.authService = authService
        self.userService = userService
        checkCurrentUser()
        setupErrorHandling()
    }
    
    // MARK: - Setup
    private func checkCurrentUser() {
        if let user = Auth.auth().currentUser {
            usersession = user
            fetchUserByUID(uid: user.uid)
        }
    }
    
    private func setupErrorHandling() {
        $errorMessage
            .map { !$0.isEmpty }
            .assign(to: &$isError)
    }
    
    // MARK: - Helper Methods
    private func getCountryCode() -> String {
        UserDefaults.standard.string(forKey: "SelectedCountry") == "India" ? "+91" : "+1"
    }
    
    private func getUserDefaultsData() -> (country: String, language: String) {
        let country = UserDefaults.standard.string(forKey: "SelectedCountry") ?? ""
        let language = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "English"
        return (country, language)
    }
    
    // MARK: - Authentication Methods
    func signUpWithEmail(name: String, email: String, password: String, photoURL: String = "") {
        isLoading = true
        let (country, language) = getUserDefaultsData()
        
        authService.email.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    let userData = UserData(
                        id: user.uid,
                        name: name,
                        email: email,
                        UserType: "Email",
                        countryCode: self?.getCountryCode() ?? "+1",
                        photoURL: photoURL,
                        country: country,
                        language: language,
                        tokenId: nil,
                        createdAt: ServerValue.timestamp()
                    )
                    self?.createUserInDatabase(userData: userData)
                    self?.didRegisterSuccess = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print(self?.errorMessage ?? "")
                    self?.didRegisterSuccess = false
                }
            }
        }
    }
    
    func signInWithEmail(email: String, password: String) {
        isLoading = true
        
        authService.email.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.usersession = user
                    UserDefaults.standard.set(user.uid, forKey: "userUID")
                    self?.fetchUserByUID(uid: user.uid)
                    self?.isLoginFailed = false
                    self?.didLoginSuccess = true
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print(self?.errorMessage ?? "")
                    self?.didLoginSuccess = false
                }
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        authService.email.resetPassword(email: email) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.didResetPasswordSuccess = true
                    completion(true, nil)
                case .failure(let error):
                    self?.didResetPasswordSuccess = false
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        
        authService.google.signIn { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.handleAuthResult(result, userType: "Google")
            }
        }
    }
    
    func signInWithApple() {
        isLoading = true
        
        authService.apple.signIn { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.handleAuthResult(result, userType: "Apple")
            }
        }
    }
    
    private func handleAuthResult(_ result: Result<FirebaseAuth.User, Error>, userType: String) {
        switch result {
        case .success(let user):
            usersession = user
            UserDefaults.standard.set(user.uid, forKey: "userUID")
            checkAndCreateUser(user: user, userType: userType)
            isLoginFailed = false
            didLoginSuccess = true
            
        case .failure(let error):
            errorMessage = error.localizedDescription
            print(self.errorMessage)
            didLoginSuccess = false
        }
    }
    
    // MARK: - User Management
    private func checkAndCreateUser(user: FirebaseAuth.User, userType: String) {
        userService.fetchUser(uid: user.uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    self?.currentUser = userData
                    
                case .failure:
                    // User doesn't exist, create new user
                    self?.createNewUserFromAuth(user: user, userType: userType)
                }
            }
        }
    }
    
    private func createNewUserFromAuth(user: FirebaseAuth.User, userType: String) {
        let (country, language) = getUserDefaultsData()
        let userData: UserData
        
        switch userType {
        case "Google":
            userData = UserData(
                id: user.uid,
                name: user.displayName ?? "",
                email: user.email ?? "",
                UserType: userType,
                countryCode: getCountryCode(),
                photoURL: user.photoURL?.absoluteString ?? "",
                country: country,
                language: language,
                tokenId: nil, // Google token is handled separately
                createdAt: ServerValue.timestamp()
            )
            
        case "Apple":
            userData = UserData(
                id: user.uid,
                name: user.displayName ?? "Apple User",
                email: user.email ?? "",
                UserType: userType,
                countryCode: getCountryCode(),
                photoURL: "",
                country: country,
                language: language,
                tokenId: nil,
                createdAt: ServerValue.timestamp()
            )
            
        default:
            return
        }
        
        createUserInDatabase(userData: userData)
    }
    
    private func createUserInDatabase(userData: UserData) {
        userService.createUser(userData: userData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.currentUser = userData
                    self?.successMessage = "Account created successfully!"
                    
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isError = true
                }
            }
        }
    }
    
    func fetchUserByUID(uid: String) {
        userService.fetchUser(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    self?.currentUser = userData
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print(self?.errorMessage ?? "")
                    self?.isError = true
                }
            }
        }
    }
    
    func updateUserProfile(updates: [String: Any]) {
        guard let uid = usersession?.uid else {
            errorMessage = "No user logged in"
            return
        }
        isLoading = true
        userService.updateUser(uid: uid, updates: updates) { [weak self] result in
            self?.isLoading = false 
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Update local user data
                    for (key, value) in updates {
                        switch key {
                        case "name": self?.currentUser?.name = value as? String ?? ""
                        case "email": self?.currentUser?.email = value as? String ?? ""
                        case "photoURL": self?.currentUser?.photoURL = value as? String ?? ""
                        case "country": self?.currentUser?.country = value as? String ?? ""
                        case "language": self?.currentUser?.language = value as? String ?? ""
                        case "countryCode": self?.currentUser?.countryCode = value as? String ?? ""
                        default: break
                        }
                    }
                    self?.successMessage = "Profile updated successfully!"
                    self?.didUpdateUserProfileSuccess = true
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print(self?.errorMessage ?? "")
                    self?.didUpdateUserProfileSuccess = false
                    self?.isError = true
                    
                }
            }
        }
    }
    
    func deleteUserAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let uid = usersession?.uid else {
            completion(false, "No user logged in")
            return
        }
        
        // First delete from database
        userService.deleteUser(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Then delete from Firebase Auth
                    self?.deleteAuthUser(completion: completion)
                    self?.didDeleteUserSuccess = true
                    
                case .failure(let error):
                    self?.didDeleteUserSuccess = false
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteAuthUser(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "No authenticated user found")
            return
        }
        
        user.delete { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    self?.handleSuccessfulDeletion()
                    completion(true, nil)
                }
            }
        }
    }
    
    private func handleSuccessfulDeletion() {
        usersession = nil
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "userUID")
        successMessage = "Account deleted successfully"
        errorMessage = ""
    }
    
    // MARK: - Session Management
    func signOut() {
        do {
            try authService.google.signOut()
            try authService.apple.signOut()
            try authService.email.signOut()
            
            usersession = nil
            currentUser = nil
            UserDefaults.standard.removeObject(forKey: "userUID")
            successMessage = "Signed out successfully"
            errorMessage = ""
            didLoginSuccess = false
            
        } catch {
            errorMessage = error.localizedDescription
            print(self.errorMessage)
            isError = true
        }
    }
    
    func clearMessages() {
        errorMessage = ""
        successMessage = ""
        isError = false
    }
    
    // MARK: - Phone Authentication (if needed)
    func sendOTP(phoneNumber: String, completion: @escaping (Bool, String?, String?) -> Void) {
        guard !phoneNumber.isEmpty else {
            completion(false, nil, "Phone number is empty")
            return
        }
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, nil, error.localizedDescription)
                } else if let verificationID = verificationID {
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    completion(true, verificationID, nil)
                } else {
                    self.isError = true
                    self.errorMessage = "Failed to get verification ID"
                    print(self.errorMessage)
                    completion(false, nil, "Failed to get verification ID")
                }
            }
        }
    }
}

// MARK: - Error Types Extension
extension Login_SignUpVM {
    enum AuthError: LocalizedError {
        case configurationError
        case invalidUserData
        case invalidCredential
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .configurationError: return "Authentication configuration error"
            case .invalidUserData: return "Invalid user data received"
            case .invalidCredential: return "Invalid authentication credential"
            case .unknownError: return "Unknown authentication error"
            }
        }
    }
    
    enum DatabaseError: LocalizedError {
        case userNotFound
        case updateFailed
        case deleteFailed
        
        var errorDescription: String? {
            switch self {
            case .userNotFound: return "User not found in database"
            case .updateFailed: return "Failed to update user data"
            case .deleteFailed: return "Failed to delete user data"
            }
        }
    }
}
