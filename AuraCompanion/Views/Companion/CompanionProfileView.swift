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
                    VStack(spacing: 20) {
                        // Carte Héros Compagnon
                        heroCompanionCard
                        
                        // Sélecteur d'humeur interactif
                        moodSelectorSection
                        
                        // Boutons d'actions majeurs
                        actionButtonsSection
                        
                        // Grille des Traits de personnalité
                        personalityMetricsSection
                        
                        // Philosophie & Bio
                        bioSection
                        
                        // Moteur d'IA Actif
                        engineStatusSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Mon Compagnon")
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
    
    // MARK: - Carte Héros
    private var heroCompanionCard: some View {
        VStack(spacing: 14) {
            LivingCompanionOrb(
                mood: appState.companionProfile.currentMood,
                size: 130
            )
            .padding(.top, 4)
            
            VStack(spacing: 4) {
                Text(appState.companionProfile.name)
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text(appState.companionProfile.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
    
    // MARK: - Sélecteur d'humeur
    private var moodSelectorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Humeur Actuelle")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CompanionMood.allCases) { mood in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                appState.companionProfile.currentMood = mood
                            }
                            HapticsService.light()
                        } label: {
                            HStack(spacing: 5) {
                                Text(mood.emoji)
                                Text(mood.rawValue)
                                    .font(.system(size: 13, weight: appState.companionProfile.currentMood == mood ? .bold : .medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundColor(appState.companionProfile.currentMood == mood ? .white : .secondary)
                            .background(
                                Group {
                                    if appState.companionProfile.currentMood == mood {
                                        Capsule().fill(appState.theme.primaryAccent)
                                    } else {
                                        Capsule().fill(.ultraThinMaterial)
                                    }
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Boutons d'action
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Button {
                HapticsService.medium()
                showVoiceCall = true
            } label: {
                Label("Appel Vocal", systemImage: "phone.bubble.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "00F0FF"), Color(hex: "9D5CFF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                HapticsService.light()
                showEditor = true
            } label: {
                Label("Personnaliser", systemImage: "slider.horizontal.3")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Métriques de personnalité
    private var personalityMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Traits & Paramètres")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                metricRow(title: "Chaleur", value: "\(Int(appState.companionProfile.warmthLevel * 100))%", icon: "heart.fill", color: .pink)
                metricRow(title: "Humour", value: "\(Int(appState.companionProfile.humorLevel * 100))%", icon: "face.smiling.fill", color: .yellow)
                metricRow(title: "Empathie", value: "\(Int(appState.companionProfile.empathyLevel * 100))%", icon: "hands.sparkles.fill", color: .purple)
                metricRow(title: "Verbosité", value: appState.companionProfile.verbosity.rawValue.components(separatedBy: " ").first ?? "", icon: "text.quote", color: .cyan)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func metricRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 15))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Bio
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("À propos")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(appState.companionProfile.bio)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Moteur IA
    private var engineStatusSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Moteur IA Actif")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(appState.provider == .freeBuiltIn ? "Mode Gratuit Immédiat (Sans Clé)" : appState.selectedModel.displayName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(appState.provider == .freeBuiltIn ? .green : .primary)
            }
            Spacer()
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(appState.provider == .freeBuiltIn ? .green : appState.theme.primaryAccent)
                .font(.system(size: 20))
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
