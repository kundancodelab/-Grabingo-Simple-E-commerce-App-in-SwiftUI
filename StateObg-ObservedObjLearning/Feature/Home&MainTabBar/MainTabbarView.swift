import SwiftUI
struct MainTabBarView: View {
    @State private var activetab = 0
    @EnvironmentObject var router: Router
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var LoginSignUpVM: Login_SignUpVM
    @State var isPresented: Bool = false

    var body: some View {
        TabView(selection: $activetab) {

            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            // Chats Tab
            EmptyView()
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
                .tag(1)

            // Communities Tab
            EmptyView()
                .tabItem {
                    Label("Communities", systemImage: "person.3")
                }
                .tag(2)

            // Settings Tab
            EmptyView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(4)
        }
        // Detect when the selected tab changes
        .onChange(of: activetab) {oldValue,  newValue in
            if newValue == 4 && LoginSignUpVM.currentUser == nil {
                // User tapped Profile but is not logged in
               // router.setRoot(.login)
                router.previousRoute = AppRoute.home(.home)
                isPresented = true
                // Optionally reset the selected tab to Home
               // activetab = 0
            }
        }
        
        .fullScreenCover(isPresented: $isPresented) {
            withAnimation {
                LoginView()
            }
        }
    }
}
