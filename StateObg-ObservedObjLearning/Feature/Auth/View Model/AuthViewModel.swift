//
//  AuthViewModel.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 22/06/25.
//

import Foundation
import FirebaseAuth // Auth
import FirebaseFirestore // Storage
import FirebaseDatabase  // real time storage

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User? // firebase ka user
    @Published var currentUser: User? // apna vala user
    @Published var isError: Bool = false
    private let auth = Auth.auth()
    private let database = Database.database().reference()
    
    init() {
        Task {
            await loadCurrentUser()
        }
    }
    
    func loadCurrentUser() async {
        if let user = auth.currentUser {
            userSession = user
            await fetchUser(by: user.uid)
        }else {
           // userSession = nil
          //  currentUser = nil
        }
    }
    
    func login(email: String, password: String) async {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            userSession = authResult.user
            await fetchUser(by: authResult.user.uid)
        }catch {
            isError = true
        }
    }
    
    func createUser(email: String, fullName: String, password: String) async {
        do {
            // auth mai user ki entry kar rahe ho
            let authResult = try await auth.createUser(withEmail: email, password: password)
            // database user ki extra details store kar rahe ho
            await storeUserInRealtimeDatabase(uid: authResult.user.uid, email: email, fullName: fullName)
            //  Add this line to fetch user after storing
            await fetchUser(by: authResult.user.uid)
            
            // Set user session (if needed again)
            userSession = authResult.user
            
        }catch {
            isError = true
        }
    }
    
    func storeUserInRealtimeDatabase(uid: String, email: String, fullName: String) async {
        let user = User(uid: uid, email: email, fullName: fullName)
        do {
            if let userType = UserDefaults.standard.value(forKey: Utils.shared.userLoginType) {
                try await database.child(userType as! String).child(uid).setValue(user.toDictionary())
            }
        
        } catch {
            isError = true
        }
    }
 
    func fetchUser(by uid: String) async {
        do {
            if let userType = UserDefaults.standard.value(forKey: Utils.shared.userLoginType) {
                let snapshot = try await database.child(userType as! String).child(uid).getData()
                if let data = snapshot.value as? [String: Any] {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    currentUser = user
                }
            }
          
        } catch {
            isError = true
        }
    }

    func signOut() {
        do {
            userSession = nil
            currentUser = nil
          
            UserDefaults.standard.set(false, forKey: "isSignIn")
            try auth.signOut()
        }catch {
            isError = true
        }
    }
    
    func deleteAccount() async {
        do {
            UserDefaults.standard.removeObject(forKey: "isSignIn")
            userSession = nil
            currentUser = nil
          
            deleteUser(by: auth.currentUser?.uid ?? "") // firestore database mai sai
            try await auth.currentUser?.delete() // auth mai sai remove hoga
        }catch {
            isError = true
        }
    }
    private func deleteUser(by uid: String) {
        if let userType = UserDefaults.standard.value(forKey: Utils.shared.userLoginType) {
            database.child(userType as! String).child(uid).removeValue()
        }
     
    }

   
    func resetPassword(by email: String) async {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        }catch {
            isError = true
        }
    }
}
