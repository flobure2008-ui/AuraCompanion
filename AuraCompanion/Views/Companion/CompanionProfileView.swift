import SwiftUI

public struct CompanionProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showEditor = false
    @State private var showVoiceCall = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackgroundView(
                    primaryColor: appState.companionProfile.currentMood.accentColors.first ?? appState.theme.primaryAccent,
                    secondaryColor: appState.theme.secondaryAccent
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Section 1 : Orbe Vivant du Compagnon
                        VStack(spacing: 16) {
                            LivingCompanionOrb(
                                mood: appState.companionProfile.currentMood,
                                size: 140
                            )
                            .padding(.top, 10)
                            
                            VStack(spacing: 4) {
                                Text(appState.companionProfile.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(appState.companionProfile.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            
                            // Sélecteur d'humeur liquide immédiat
                            HStack(spacing: 8) {
                                ForEach(CompanionMood.allCases) { mood in
                                    Button {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                                            appState.companionProfile.currentMood = mood
                                        }
                                        HapticsService.light()
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(mood.emoji)
                                            if appState.companionProfile.currentMood == mood {
                                                Text(mood.rawValue)
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .liquidGlass(
                                            cornerRadius: 16,
                                            glowColor: mood.accentColors.first ?? .purple,
                                            opacity: appState.companionProfile.currentMood == mood ? 0.35 : 0.08
                                        )
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        
                        // Boutons d'action majeurs en Verre Liquide
                        HStack(spacing: 14) {
                            // Appel Vocal
                            Button {
                                HapticsService.medium()
                                showVoiceCall = true
                            } label: {
                                HStack {
                                    Image(systemName: "phone.bubble.fill")
                                    Text("Appel Vocal")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .liquidGlass(cornerRadius: 18, glowColor: Color(hex: "00F0FF"), opacity: 0.2)
                            }
                            .buttonStyle(LiquidButtonStyle())
                            
                            // Personnaliser
                            Button {
                                HapticsService.light()
                                showEditor = true
                            } label: {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                    Text("Personnaliser")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .liquidGlass(cornerRadius: 18, glowColor: appState.theme.primaryAccent, opacity: 0.2)
                            }
                            .buttonStyle(LiquidButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        
                        // Pensée du moment / Bio
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "quote.opening")
                                    .foregroundColor(appState.theme.primaryAccent)
                                Text("Essence & Philosophie")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            Text(appState.companionProfile.bio)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.85))
                                .lineSpacing(4)
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 20, glowColor: appState.theme.primaryAccent, opacity: 0.1)
                        .padding(.horizontal, 20)
                        
                        // Grille des Traits en Verre Liquide
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            traitLiquidCard(title: "Archétype", value: appState.companionProfile.archetype.rawValue.components(separatedBy: " ").first ?? "", icon: "sparkles")
                            traitLiquidCard(title: "Relation", value: appState.companionProfile.relationshipType.rawValue, icon: "heart.fill")
                            traitLiquidCard(title: "Chaleur", value: "\(Int(appState.companionProfile.warmthLevel * 100))%", icon: "sun.max.fill")
                            traitLiquidCard(title: "Humour", value: "\(Int(appState.companionProfile.humorLevel * 100))%", icon: "face.smiling.fill")
                            traitLiquidCard(title: "Empathie", value: "\(Int(appState.companionProfile.empathyLevel * 100))%", icon: "hands.sparkles.fill")
                            traitLiquidCard(title: "Verbosité", value: appState.companionProfile.verbosity.rawValue.components(separatedBy: " ").first ?? "", icon: "text.quote")
                        }
                        .padding(.horizontal, 20)
                        
                        // Moteur d'IA Actif
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Moteur d'intelligence")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Text(appState.provider == .freeBuiltIn ? "Mode Gratuit Immédiat (Actif)" : appState.selectedModel.displayName)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(appState.provider == .freeBuiltIn ? .green : .white)
                            }
                            Spacer()
                            Image(systemName: "cpu.fill")
                                .font(.system(size: 22))
                                .foregroundColor(appState.provider == .freeBuiltIn ? .green : appState.theme.primaryAccent)
                        }
                        .padding(16)
                        .liquidGlass(cornerRadius: 18, glowColor: appState.provider == .freeBuiltIn ? .green : appState.theme.primaryAccent, opacity: 0.1)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Mon Compagnon")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showVoiceCall) {
                VoiceCallView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showEditor) {
                CompanionEditorView(initialProfile: appState.companionProfile)
                    .environmentObject(appState)
            }
        }
    }
    
    private func traitLiquidCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(appState.theme.primaryAccent)
            
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(cornerRadius: 18, glowColor: appState.theme.primaryAccent, opacity: 0.08)
    }
}
