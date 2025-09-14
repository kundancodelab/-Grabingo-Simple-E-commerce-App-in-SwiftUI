//
//  GoogleAuthService.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 14/09/25.
//
// Services/Authentication/GoogleAuthService.swift
import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

final class GoogleAuthService: GoogleAuthServiceProtocol {
    private let auth = Auth.auth()
    
    func signIn(completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID,
              let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            completion(.failure(AuthError.configurationError))
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthError.invalidUserData))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else if let user = authResult?.user {
                    completion(.success(user))
                } else {
                    completion(.failure(AuthError.unknownError))
                }
            }
        }
    }
    
    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try auth.signOut()
    }
}
