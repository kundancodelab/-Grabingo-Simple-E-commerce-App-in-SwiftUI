//
//  APIManager.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 17/09/25.
//

import Foundation


final class APIManager {
    static let shared = APIManager()
    private init(){}
    
   // var BASE_URL: String { ConfigurationManager.ROOT_URL }
   var BASE_URL = ConfigurationManager.ROOT_URL
     
    
    // MARK: Endpoints
    
    let login = "/login"
    let logout = "/logout"
    let deleteAccount = "/delete-account"
    let forgotPassword = "/forgot-password"
    let register = "/register"
    
    
}
