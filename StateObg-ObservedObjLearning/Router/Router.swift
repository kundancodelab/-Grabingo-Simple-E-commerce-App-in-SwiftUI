//
//  Router.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 21/09/25.
//

import Foundation
import SwiftUI

enum AppRoute : Codable, Hashable {
    case auth(AuthRoute)
    case home(HomeRoute)
    // later: case profile(ProfileRoute), case bids(BidsRoute), etc.
}

enum RootFLow : Codable , Hashable {
    case login
    case dashboard
}

final class Router: ObservableObject {
    
    @Published var navPath = NavigationPath()
    
    @Published var root : RootFLow = .login
    @Published var isAuthenticated : Bool = false
    // Store the previous location before navigating to login
    @Published var previousRoute: AppRoute?
 
    func navigate(to route: AppRoute) {
        // Store the current route before navigating to auth flow
        // Since we can't access the NavigationPath elements directly, 
        // we'll update our approach to store the previous route before appending
        if case .auth = route, previousRoute == nil {
            // When navigating to auth flow and no previous route is stored,
            // we'll store a reference to go back to the main content
            previousRoute = .home(.home) // or some default route
        }
        navPath.append(route)
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
    
    // Navigate back to the previous location
    func navigateToPreviousLocation() {
        if let previousRoute = previousRoute {
            navPath.append(previousRoute)
            // Clear the previous route after navigating back
            self.previousRoute = nil
        } else {
            // If no previous route, go to the main content
            navPath.removeLast(navPath.count)
        }
    }
    
    func setRoot(_ root: RootFLow) {
        self.root = root
        navigateToRoot()
    }
}
