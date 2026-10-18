import SwiftUI

@main
struct AuraCompanionApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Apparence moderne transparente pour la barre d'onglets
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(white: 0.05, alpha: 0.85)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}
