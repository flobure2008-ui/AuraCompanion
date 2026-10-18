import SwiftUI

public struct CompanionProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showEditor = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                appState.theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hologramme / Avatar Header
                        VStack(spacing: 14) {
                            CompanionAvatarThumbnail(profile: appState.companionProfile, size: 110)
                                .shadow(color: appState.companionProfile.avatarPreset.gradientColors.first!.opacity(0.6), radius: 20)
                            
                            VStack(spacing: 4) {
                                Text(appState.companionProfile.name)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(appState.companionProfile.title)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            // Sélecteur d'humeur dynamique
                            HStack(spacing: 8) {
                                ForEach(CompanionMood.allCases) { mood in
                                    Button {
                                        appState.companionProfile.currentMood = mood
                                        HapticsService.light()
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(mood.emoji)
                                            if appState.companionProfile.currentMood == mood {
                                                Text(mood.rawValue)
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(appState.companionProfile.currentMood == mood ? appState.theme.primaryAccent : Color.white.opacity(0.08))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 16)
                        
                        // Bouton d'édition rapide
                        Button {
                            showEditor = true
                        } label: {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                Text("Personnaliser la personnalité & la voix")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [appState.theme.primaryAccent, appState.theme.secondaryAccent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: appState.theme.primaryAccent.opacity(0.4), radius: 8, y: 3)
                        }
                        .padding(.horizontal, 20)
                        
                        // Bio & Essence
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Bio & Philosophie")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(appState.companionProfile.bio)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.75))
                                .lineSpacing(4)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard(cornerRadius: 18)
                        .padding(.horizontal, 20)
                        
                        // Grille des Traits
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            statCard(title: "Archétype", value: appState.companionProfile.archetype.rawValue.components(separatedBy: " ").first ?? "", icon: "sparkles")
                            statCard(title: "Relation", value: appState.companionProfile.relationshipType.rawValue, icon: "heart.fill")
                            statCard(title: "Chaleur", value: "\(Int(appState.companionProfile.warmthLevel * 100))%", icon: "sun.max.fill")
                            statCard(title: "Humour", value: "\(Int(appState.companionProfile.humorLevel * 100))%", icon: "face.smiling.fill")
                            statCard(title: "Empathie", value: "\(Int(appState.companionProfile.empathyLevel * 100))%", icon: "hands.sparkles.fill")
                            statCard(title: "Verbosité", value: appState.companionProfile.verbosity.rawValue.components(separatedBy: " ").first ?? "", icon: "text.quote")
                        }
                        .padding(.horizontal, 20)
                        
                        // Modèle d'intelligence actif
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Moteur d'intelligence")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Text(appState.selectedModel.displayName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "cpu")
                                .font(.system(size: 20))
                                .foregroundColor(appState.theme.primaryAccent)
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Mon Compagnon")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditor) {
                CompanionEditorView(initialProfile: appState.companionProfile)
                    .environmentObject(appState)
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(appState.theme.primaryAccent)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(14)
        .glassCard(cornerRadius: 16)
    }
}
