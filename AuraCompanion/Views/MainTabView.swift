import SwiftUI

public struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    public var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingFlowView()
            } else {
                ZStack(alignment: .bottom) {
                    // Contenu de l'onglet sélectionné
                    Group {
                        switch selectedTab {
                        case 0:
                            ChatView()
                        case 1:
                            CompanionProfileView()
                        case 2:
                            MemoryCoreView()
                        case 3:
                            SettingsView()
                        default:
                            ChatView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Barre d'onglets flottante en Verre Liquide
                    liquidFloatingTabBar
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
                .ignoresSafeArea(.keyboard)
            }
        }
    }
    
    // MARK: - Barre d'onglets Flottante
    private var liquidFloatingTabBar: some View {
        HStack(spacing: 0) {
            tabItem(index: 0, title: "Chat", icon: "bubble.left.and.bubble.right.fill")
            tabItem(index: 1, title: "Aura", icon: "sparkles")
            tabItem(index: 2, title: "Mémoire", icon: "brain.head.profile")
            tabItem(index: 3, title: "Réglages", icon: "gearshape.fill")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .liquidGlass(cornerRadius: 32, glowColor: appState.theme.primaryAccent, opacity: 0.14)
    }
    
    private func tabItem(index: Int, title: String, icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = index
            }
            HapticsService.selection()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: selectedTab == index ? .bold : .regular))
                    .foregroundColor(selectedTab == index ? .white : .white.opacity(0.45))
                    .scaleEffect(selectedTab == index ? 1.08 : 1.0)
                
                Text(title)
                    .font(.system(size: 10, weight: selectedTab == index ? .bold : .medium))
                    .foregroundColor(selectedTab == index ? .white : .white.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                Group {
                    if selectedTab == index {
                        Capsule()
                            .fill(appState.theme.primaryAccent.opacity(0.35))
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
