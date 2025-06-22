
import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import GoogleSignIn
import AuthenticationServices
import Foundation

class Login_SignUpVM: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published var isLoginFailed = false
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var isError : Bool = false
    @Published var usersession: FirebaseAuth.User?  // Firebase user
    @Published var currentUser: UserData? // User details
    private let auth = Auth.auth()
    private var appleSignInCompletion: ((Bool, [String: Any]?) -> Void)?

    override init() {
        super.init()
        if let user = auth.currentUser {
            usersession = user 
            fetchUserByUID(uid: user.uid) { userData, error in
                if let userData = userData {
                    self.currentUser = userData
                } else if let error = error {
                    self.errorMessage = error
                    self.isError = true
                }
            }
            
        }
     
    }

    // MARK: - Helper Functions
    private func getCountryCode() -> String {
        UserDefaults.standard.string(forKey: "SelectedCountry") == "India" ? "+91" : "+1"
    }

    private func sanitizeUserID(_ userID: String) -> String {
        let invalidCharacters: Set<Character> = [".", "#", "$", "[", "]"]
        return String(userID.filter { !invalidCharacters.contains($0) })
    }

    // MARK: - Email Authentication
    func signUpWithEmail(name: String, email: String, password: String, photoURL: String = "", completion: @escaping (Bool, String?) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(false, "Email or password is empty")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self, let user = result?.user else {
                completion(false, error?.localizedDescription ?? "Sign-up failed")
                return
            }

            let userData = UserData(
                id: user.uid,
                name: name,
                email: email,
                countryCode: self.getCountryCode(),
                photoURL: photoURL,
                country: UserDefaults.standard.string(forKey: "SelectedCountry") ?? "",
                language: UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "English",
                tokenId: nil,
                createdAt: nil
            )

            let userDict: [String: Any] = [
                "uid": user.uid,
                "name": name,
                "email": email,
                "countryCode": self.getCountryCode(),
                "photoURL": photoURL,
                "country": UserDefaults.standard.string(forKey: "SelectedCountry") ?? "",
                "language": UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "English"
            ]

            Database.database().reference().child("EmailUsers").child(user.uid).setValue(userDict) { error, _ in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    self.currentUser = userData
                    self.successMessage = "Account created!"
                    completion(true, nil)
                }
            }
        }
    }

    func signInWithEmail(email: String, password: String, completion: @escaping (Bool, UserData?) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(false, nil)
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self, let user = result?.user else {
                self?.isLoginFailed = true
                completion(false, nil)
                return
            }

            UserDefaults.standard.set(email, forKey: "Email_email")
            self.fetchUserByUID(uid: user.uid) { userData, error in
                if let userData = userData {
                    self.isLoginFailed = false
                    self.currentUser = userData
                    completion(true, userData)
                } else {
                    self.isLoginFailed = true
                    completion(false, nil)
                    self.errorMessage = error ?? "User data not found"
                }
            }
        }
    }

    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        guard !email.isEmpty else {
            completion(false, "Email is empty")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }

    // MARK: - Google Authentication
    func signInWithGoogle(completion: @escaping (Bool, String?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID,
              let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            self.isError = true
            self.errorMessage = "Google Sign-In setup failed. Client ID or scene missing."
            completion(false, "Google Sign-In setup failed. Client ID or scene missing.")
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else {
                completion(false, "Something went wrong. Try again later.")
                self?.isError = true
                self?.errorMessage = "Something went wrong. Try again later."
                return
            }

            if let error = error {
                self.isError = true
                self.errorMessage = "Google Sign-In error: \(error.localizedDescription)"
                completion(false, "Google Sign-In error: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user else {
                self.isError = true
                self.errorMessage = "Google user data not found."
                completion(false, "Google user data not found.")
                return
            }

            let idToken = user.idToken?.tokenString ?? ""
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.isError = true
                    self.errorMessage =  "Firebase Sign-In failed: \(error.localizedDescription)"
                    completion(false, "Firebase Sign-In failed: \(error.localizedDescription)")
                    return
                }

                guard let firebaseUser = authResult?.user else {
                    self.isError = true
                    self.errorMessage =  "Firebase user not found."
                    completion(false, "Firebase user not found.")
                    return
                }

                let userData = UserData(
                    id: firebaseUser.uid,
                    name: firebaseUser.displayName ?? "",
                    email: firebaseUser.email ?? "",
                    countryCode: self.getCountryCode(),
                    photoURL: firebaseUser.photoURL?.absoluteString ?? "",
                    country: UserDefaults.standard.string(forKey: "SelectedCountry") ?? "",
                    language: UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "",
                    tokenId: idToken,
                    createdAt: nil
                )

                let userDict: [String: Any] = [
                    "uid": firebaseUser.uid,
                    "email": firebaseUser.email ?? "",
                    "name": firebaseUser.displayName ?? "",
                    "photoURL": firebaseUser.photoURL?.absoluteString ?? "",
                    "countryCode": self.getCountryCode(),
                    "country": UserDefaults.standard.string(forKey: "SelectedCountry") ?? "",
                    "language": UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "",
                    "tokenid": idToken
                ]

                let usersRef = Database.database().reference().child("GoogleUsers")
                usersRef.queryOrdered(byChild: "tokenid").queryEqual(toValue: idToken).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        UserDefaults.standard.set(idToken, forKey: "GoogleToken")
                        self.currentUser = userData
                        completion(true, nil)
                    } else {
                        usersRef.child(firebaseUser.uid).setValue(userDict) { error, _ in
                            if let error = error {
                                self.isError = true
                                self.errorMessage =  "Failed to save user data: \(error.localizedDescription)"
                                completion(false, "Failed to save user data: \(error.localizedDescription)")
                            } else {
                                UserDefaults.standard.set(idToken, forKey: "GoogleToken")
                                self.currentUser = userData
                                completion(true, nil)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Apple Authentication
    func signInWithApple(completion: @escaping (Bool, String?) -> Void) {
        appleSignInCompletion = { success, data in
            if success {
                self.errorMessage = ""
                self.isError = false
                completion(true, nil)
            } else {
                let error = data?["error"] as? String ?? "Apple Sign-In failed"
                self.errorMessage = error
                self.isError = true
                completion(false, error)
            }
        }

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            appleSignInCompletion?(false, ["error": "Invalid Apple credential"])
            return
        }

        let userID = credential.user
        let email = credential.email ?? ""
        let name = [credential.fullName?.givenName, credential.fullName?.familyName].compactMap { $0 }.joined(separator: " ")
        let sanitizedUserID = sanitizeUserID(userID)

        let userDataDict: [String: Any] = [
            "userId": userID,
            "email": email,
            "name": name,
            "photoURL": "",
            "countryCode": getCountryCode(),
            "country": UserDefaults.standard.string(forKey: "SelectedCountry") ?? "",
            "language": UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "",
            "createdAt": ServerValue.timestamp()
        ]

        let usersRef = Database.database().reference().child("AppleUsers")
        usersRef.queryOrdered(byChild: "userId").queryEqual(toValue: userID).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }

            if snapshot.exists(), let existingData = snapshot.value as? [String: Any] {
                UserDefaults.standard.set(userID, forKey: "AppleUserId")
                self.currentUser = UserData(
                    id: existingData["userId"] as? String ?? "",
                    name: existingData["name"] as? String ?? "",
                    email: existingData["email"] as? String ?? "",
                    countryCode: existingData["countryCode"] as? String ?? "",
                    photoURL: existingData["photoURL"] as? String ?? "",
                    country: existingData["country"] as? String ?? "",
                    language: existingData["language"] as? String ?? "",
                    tokenId: nil,
                    createdAt: existingData["createdAt"]
                )
                self.appleSignInCompletion?(true, nil)
            } else {
                usersRef.child(sanitizedUserID).setValue(userDataDict) { error, _ in
                    if let error = error {
                        self.appleSignInCompletion?(false, ["error": error.localizedDescription])
                    } else {
                        UserDefaults.standard.set(userID, forKey: "AppleUserId")
                        self.currentUser = UserData(
                            id: userID,
                            name: name,
                            email: email,
                            countryCode: self.getCountryCode(),
                            photoURL: "",
                            country: UserDefaults.standard.string(forKey: "SelectedCountry") ?? "",
                            language: UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "",
                            tokenId: nil,
                            createdAt: nil
                        )
                        self.appleSignInCompletion?(true, nil)
                    }
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        var errorMessage: String = "Apple login error"

        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled: errorMessage = "Apple login was canceled by user"
            case .failed: errorMessage = "Apple login failed due to system error"
            case .invalidResponse: errorMessage = "Apple login returned an invalid response"
            case .notHandled: errorMessage = "Apple login was not handled"
            case .unknown:
                errorMessage = "Unknown Apple login error: \(error.localizedDescription)"
            @unknown default:
                errorMessage = "Unhandled Apple login error"
            }
        } else {
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
        }

        self.errorMessage = errorMessage
        appleSignInCompletion?(false, ["error": errorMessage])
    }



    // MARK: - Phone Authentication
    func sendOTP(phoneNumber: String, completion: @escaping (Bool, String?, String?) -> Void) {
        guard !phoneNumber.isEmpty else {
            completion(false, nil, "Phone number is empty")
            return
        }

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                completion(false, nil, error.localizedDescription)
            } else if let verificationID = verificationID {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                completion(true, verificationID, nil)
            } else {
                completion(false, nil, "Failed to get verification ID")
            }
        }
    }

    // MARK: - User Management
    func fetchUserByUID(uid: String, completion: @escaping (UserData?, String?) -> Void) {
        let ref = Database.database().reference()
        let paths = ["EmailUsers", "GoogleUsers", "AppleUsers"]

        var checkedPaths = 0
        var foundUserData: UserData?

        for path in paths {
            ref.child(path).child(uid).observeSingleEvent(of: .value) { snapshot in
                checkedPaths += 1

                if let data = snapshot.value as? [String: Any] {
                    let userData = UserData(
                        id: data["uid"] as? String ?? data["userId"] as? String ?? uid,
                        name: data["name"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        countryCode: data["countryCode"] as? String ?? "",
                        photoURL: data["photoURL"] as? String ?? "",
                        country: data["country"] as? String ?? "",
                        language: data["language"] as? String ?? "",
                        tokenId: data["tokenid"] as? String,
                        createdAt: data["createdAt"]
                    )
                    foundUserData = userData
                    completion(userData, nil)
                    return
                }

                if checkedPaths == paths.count && foundUserData == nil {
                    completion(nil, "User not found in any database")
                }
            }
        }
    }
    // MARK: - Update User Profile
    func updateUserByUID(uid: String, updates: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        let ref = Database.database().reference()
        let paths = ["EmailUsers", "GoogleUsers", "AppleUsers"]

        var updated = false
        var checkedPaths = 0

        for path in paths {
            let userRef = ref.child(path).child(uid)
            userRef.observeSingleEvent(of: .value) { snapshot in
                checkedPaths += 1

                if snapshot.exists() {
                    userRef.updateChildValues(updates) { error, _ in
                        if let error = error {
                            completion(false, error.localizedDescription)
                        } else {
                            // Also update local currentUser
                            if self.currentUser?.id == uid {
                                for (key, value) in updates {
                                    switch key {
                                    case "name": self.currentUser?.name = value as? String ?? self.currentUser?.name ?? ""
                                    case "email": self.currentUser?.email = value as? String ?? self.currentUser?.email ?? ""
                                    case "photoURL": self.currentUser?.photoURL = value as? String ?? self.currentUser?.photoURL ?? ""
                                    case "country": self.currentUser?.country = value as? String ?? self.currentUser?.country ?? ""
                                    case "language": self.currentUser?.language = value as? String ?? self.currentUser?.language ?? ""
                                    case "countryCode": self.currentUser?.countryCode = value as? String ?? self.currentUser?.countryCode ?? ""
                                    default: break
                                    }
                                }
                            }

                            self.successMessage = "Profile updated successfully"
                            self.errorMessage = ""
                            completion(true, nil)
                        }
                    }
                    return
                }

                if checkedPaths == paths.count && !updated {
                    completion(false, "User not found in any path")
                }
            }
        }
    }

    func deleteUserByUID(uid: String, completion: @escaping (Bool, String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser, currentUser.uid == uid else {
            completion(false, "Unauthorized to delete this user")
            return
        }

        let ref = Database.database().reference()
        let paths = ["EmailUsers", "GoogleUsers", "AppleUsers"]

        var deletedFromDatabase = false
        var checkedPaths = 0

        // Delete from database
        for path in paths {
            ref.child(path).child(uid).removeValue { error, _ in
                checkedPaths += 1
                if error == nil {
                    deletedFromDatabase = true
                }

                if checkedPaths == paths.count {
                    // Delete from Firebase Authentication
                    currentUser.delete { error in
                        if let error = error {
                            completion(false, error.localizedDescription)
                        } else if deletedFromDatabase {
                            self.usersession = nil
                            self.currentUser = nil
                            self.errorMessage = ""
                            self.successMessage = "User deleted successfully"
                            completion(true, nil)
                        } else {
                            completion(false, "Failed to delete user data from database")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            usersession = nil
            currentUser = nil
            errorMessage = ""
            successMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

