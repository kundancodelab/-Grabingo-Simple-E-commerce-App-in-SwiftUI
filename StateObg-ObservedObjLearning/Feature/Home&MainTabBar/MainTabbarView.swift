//
//  MainTabbarView.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 22/06/25.
//

import SwiftUI

struct MainTabBarView: View {
    
    var body: some View {
        TabView {
            NavigationStack {
                ProductView()
            }
            .tabItem {
                Label("Chats", systemImage: "message")
            }

            NavigationStack {
               // MessagesView()
            }
            .tabItem {
                Label("Commuinties", systemImage: "person.3")
            }

            NavigationStack {
               
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
           
        }
    }
}

#Preview {
    MainTabBarView()
        
}
