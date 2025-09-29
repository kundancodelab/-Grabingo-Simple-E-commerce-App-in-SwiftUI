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
    @ObservedObject  var router  = Router()
   
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navPath) {
                Group {
                    if authVM.currentUser == nil {
                        LoginView()
                    }else {
                        MainTabBarView()
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .auth(let authRoute):
                        AuthRouterView(authRoute: authRoute)
                            .environmentObject(router)
                    case .home(let homeRoute):
                        HomeRouterView(homeRoute: homeRoute)
                            .environmentObject(router)
                    }
                }
            }
            .environmentObject(authVM)
            .environmentObject(router)
            .environmentObject(authViewModel)
        }
    }
}
