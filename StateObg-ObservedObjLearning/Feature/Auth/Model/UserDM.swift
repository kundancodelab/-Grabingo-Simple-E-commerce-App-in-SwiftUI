//
//  UserDM.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 22/06/25.
//

import Foundation

import Foundation

struct UserData: Identifiable {
    var id: String // UID
    var name: String
    var email: String
    var UserType:String?
    var countryCode: String
    var photoURL: String
    var country: String
    var language: String
    var tokenId: String? // For Google/Apple
    var createdAt: Any? // For Apple
}


// Action Model
struct UserAM{
    let name: String
    let email:String
    let password: String
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
}
