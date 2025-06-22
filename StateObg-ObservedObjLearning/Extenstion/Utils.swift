//
//  Utils.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 10/06/25.
//

import Foundation

class Utils {
    static let shared = Utils()

    // App Info
    let fontFamily: String = "Poppins"
    let fontSize: CGFloat = 17
    let appName: String = "Grabingo"
    let appVersion: String = "1.0.0"

    // Login & Onboarding
    let userLoginToken: String = "userLoginToken"
    let isSignin: String = "isSignin"
    let isOnboardingDone: String = "isOnboardingDone"
    let hasSeenIntroScreens: String = "hasSeenIntroScreens"
    let hasCompletedProfileSetup: String = "hasCompletedProfileSetup"

    // User Info
    let userID: String = "userID"
    let userEmail: String = "userEmail"
    let userName: String = "userName"
    let userProfileImage: String = "userProfileImage"
    let userPhoneNumber: String = "userPhoneNumber"
    let userLoginType: String = "userLoginType" // email, google, apple, etc.

    // App Settings
    let isDarkModeEnabled: String = "isDarkModeEnabled"
    let selectedLanguage: String = "selectedLanguage"
    let pushNotificationsEnabled: String = "pushNotificationsEnabled"
    let locationPermissionGiven: String = "locationPermissionGiven"

    // Session Info
    let lastLoginDate: String = "lastLoginDate"
    let lastOpenedVersion: String = "lastOpenedVersion"

    // Feature Flags
    let isPremiumUser: String = "isPremiumUser"
    let hasRatedApp: String = "hasRatedApp"
    let isFirstTimeUser: String = "isFirstTimeUser"

    // Location (Optional but useful)
    let lastLatitude: String = "lastLatitude"
    let lastLongitude: String = "lastLongitude"
    
    // Appearance
    let selectedAppTheme: String = "selectedAppTheme" // light/dark/system
}
