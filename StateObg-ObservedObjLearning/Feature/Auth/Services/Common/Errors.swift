//
//  Errors.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 14/09/25.
//

import Foundation
// Services/Common/Errors.swift
enum AuthError: Error {
    case configurationError
    case invalidUserData
    case invalidCredential
    case unknownError
}

enum DatabaseError: Error {
    case userNotFound
    case updateFailed
    case deleteFailed
}
