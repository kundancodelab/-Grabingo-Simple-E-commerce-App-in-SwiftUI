//
//  StateObg_ObservedObjLearningApp.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 10/06/25.
//
import UIKit
import FirebaseCore
import SwiftUI
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}
@main
struct StateObg_ObservedObjLearningApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var authVM = Login_SignUpVM()
    // Add init to trigger configuration at the right time
        init() {
            // This ensures ConfigurationManager is accessed after app is fully launched
            DispatchQueue.main.async {
                // Pre-load the base URL safely
                _ = APIManager.shared.BASE_URL
            }
        }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    if authVM.usersession == nil {
                        LoginView()
                        
                        
                    }else {
                        MainTabBarView()
                    }
                }
                
            }.environmentObject(authVM)
        
         
        }
    }
}
