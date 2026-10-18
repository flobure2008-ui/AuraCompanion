import SwiftUI

public struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    public var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingFlowView()
            } else {
                TabView(selection: $selectedTab) {
                    ChatView()
                        .tabItem {
                            Label("Discussion", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .tag(0)
                    
                    CompanionProfileView()
                        .tabItem {
                            Label("Compagnon", systemImage: "sparkles")
                        }
                        .tag(1)
                    
                    MemoryCoreView()
                        .tabItem {
                            Label("Mémoire", systemImage: "brain.head.profile")
                        }
                        .tag(2)
                    
                    SettingsView()
                        .tabItem {
                            Label("Réglages", systemImage: "gearshape.fill")
                        }
                        .tag(3)
                }
                .tint(appState.theme.primaryAccent)
            }
        }
    }
}
