//
//  UserServiceProtocol.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 14/09/25.
//

import Foundation
// Services/User/UserServiceProtocol.swift
protocol UserServiceProtocol {
    func createUser(userData: UserData, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchUser(uid: String, completion: @escaping (Result<UserData, Error>) -> Void)
    func updateUser(uid: String, updates: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
    func deleteUser(uid: String, completion: @escaping (Result<Void, Error>) -> Void)
}

// Services/User/UserService.swift
import FirebaseDatabase

final class UserService: UserServiceProtocol {
    private let databaseRef = Database.database().reference().child("UserList")
    
    func createUser(userData: UserData, completion: @escaping (Result<Void, Error>) -> Void) {
        let userDict: [String: Any] = [
            "uid": userData.id,
            "name": userData.name,
            "email": userData.email,
            "UserType": userData.UserType ?? "",
            "countryCode": userData.countryCode,
            "photoURL": userData.photoURL,
            "country": userData.country,
            "language": userData.language,
            "tokenId": userData.tokenId ?? "",
            "createdAt": ServerValue.timestamp()
        ]
        
        databaseRef.child(userData.id).setValue(userDict) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchUser(uid: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        databaseRef.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.userNotFound))
                return
            }
            
            let userData = UserData(
                id: data["uid"] as? String ?? uid,
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                UserType: data["UserType"] as? String,
                countryCode: data["countryCode"] as? String ?? "",
                photoURL: data["photoURL"] as? String ?? "",
                country: data["country"] as? String ?? "",
                language: data["language"] as? String ?? "",
                tokenId: data["tokenId"] as? String,
                createdAt: data["createdAt"]
            )
            
            completion(.success(userData))
        }
    }
    
    func updateUser(uid: String, updates: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        databaseRef.child(uid).updateChildValues(updates) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteUser(uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        databaseRef.child(uid).removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
