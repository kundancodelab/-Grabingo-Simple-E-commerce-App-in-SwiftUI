//
//  ConfigAlertMessages.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 21/06/25.
//

import Foundation

class ConfigAlertMessages {
    static let shared = ConfigAlertMessages()

    let title = "Grabingo"

    // General messages
    let configMissingMessage = "Please enter your configuration settings."
    let allFieldsRequired = "All fields are required. Please fill in all the details."

    // Field-specific messages
    let enterUsername = "Please enter your username."
    let enterEmail = "Please enter your email address."
    let enterValidEmail = "Please enter a valid email address."
    let enterPassword = "Please enter your password."
    let enterConfirmPassword = "Please confirm your password."

    // Password-related messages
    let passwordMismatch = "Password and confirm password do not match."
    let passwordTooShort = "Password must be at least 6 characters long."

    // Login/Signup flow
    let invalidCredentials = "Invalid username or password."
    let userNotFound = "No user found with the provided details."
    let userAlreadyExists = "An account with this email already exists."
    let signout = "Are you sure you want to sign out?"
    let deleteAccout = "Are you sure you want to delete your account?"

    // Network
    let noInternetConnection = "No internet connection. Please check your network settings."
    let requestTimeout = "Request timed out. Please try again later."

    // Success
    let registrationSuccess = "Registration successful!"
    let loginSuccess = "Login successful!"
}
