import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showResetAlert = false
    @State private var showExportShare = false
    @State private var exportedJSON = ""
    
    public var body: some View {
        NavigationStack {
            ZStack {
                appState.theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Section 1: Clé API
                        APIKeyConfigView()
                        
                        // Section 2: Sélection du Modèle
                        modelSelectionSection
                        
                        // Section 3: Thème Visuel
                        themeSelectionSection
                        
                        // Section 4: Profil Utilisateur
                        userProfileSection
                        
                        // Section 5: Sauvegarde & Données
                        dataManagementSection
                        
                        // Section 6: À propos
                        aboutSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showExportShare) {
                ShareSheet(items: [exportedJSON])
            }
            .alert("Réinitialiser les conversations ?", isPresented: $showResetAlert) {
                Button("Supprimer tout", role: .destructive) {
                    appState.sessions = []
                    _ = appState.createNewSession()
                    HapticsService.heavy()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Cette action effacera l'historique complet des discussions. Vos souvenirs enregistrés seront conservés.")
            }
        }
    }
    
    // MARK: - Modèles
    private var modelSelectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Modèle Gemini")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            VStack(spacing: 10) {
                ForEach(GeminiModel.allCases) { model in
                    Button {
                        appState.selectedModel = model
                        HapticsService.light()
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: appState.selectedModel == model ? "largecircle.fill.circle" : "circle")
                                .font(.system(size: 18))
                                .foregroundColor(appState.selectedModel == model ? appState.theme.primaryAccent : .white.opacity(0.3))
                                .padding(.top, 2)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(model.displayName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(model.subtitle)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .glassCard(
                            cornerRadius: 14,
                            strokeColor: appState.selectedModel == model ? appState.theme.primaryAccent : Color.white.opacity(0.1)
                        )
                    }
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
    
    // MARK: - Thèmes
    private var themeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ambiance & Thème Visuel")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AppTheme.allCases) { thm in
                        Button {
                            appState.theme = thm
                            HapticsService.light()
                        } label: {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(thm.backgroundGradient)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(thm.primaryAccent, lineWidth: 2)
                                    )
                                    .overlay(
                                        Circle()
                                            .fill(thm.secondaryAccent)
                                            .frame(width: 14, height: 14)
                                            .offset(x: 10, y: 10)
                                    )
                                
                                Text(thm.rawValue)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(appState.theme == thm ? 1.0 : 0.6))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .glassCard(
                                cornerRadius: 14,
                                strokeColor: appState.theme == thm ? appState.theme.primaryAccent : Color.clear
                            )
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
    
    // MARK: - Profil utilisateur
    private var userProfileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Votre Nom ou Pseudo")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            Text("Le compagnon s'adressera à vous avec ce prénom.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Votre nom", text: $appState.userName)
                .padding(12)
                .glassCard(cornerRadius: 12)
                .foregroundColor(.white)
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
    
    // MARK: - Sauvegarde & Export
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sauvegarde & Confidentialité")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            Button {
                if let json = StorageService.shared.exportAllDataJSON() {
                    exportedJSON = json
                    showExportShare = true
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Exporter les données (JSON complet)")
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption)
                }
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(12)
                .glassCard(cornerRadius: 12)
            }
            
            Button {
                showResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Effacer l'historique des discussions")
                    Spacer()
                }
                .font(.system(size: 14))
                .foregroundColor(.red.opacity(0.85))
                .padding(12)
                .glassCard(cornerRadius: 12, strokeColor: Color.red.opacity(0.2))
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
    
    // MARK: - À propos
    private var aboutSection: some View {
        VStack(spacing: 8) {
            Text("Aura AI Companion")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Version 1.0 • Propulsé par Google Gemini 1.5 & 2.0")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Share Sheet Helper
public struct ShareSheet: UIViewControllerRepresentable {
    public let items: [Any]
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
