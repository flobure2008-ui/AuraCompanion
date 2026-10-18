import SwiftUI

public struct OnboardingFlowView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    
    public var body: some View {
        ZStack {
            appState.theme.backgroundGradient.ignoresSafeArea()
            
            VStack {
                // Barre de progression
                HStack(spacing: 8) {
                    ForEach(0..<3) { step in
                        Capsule()
                            .fill(step <= currentStep ? appState.theme.primaryAccent : Color.white.opacity(0.15))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
                
                // Contenu des étapes
                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    companionSetupStep.tag(1)
                    apiKeyStep.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
                
                // Bouton Continuer / Terminer
                Button {
                    if currentStep < 2 {
                        withAnimation { currentStep += 1 }
                        HapticsService.light()
                    } else {
                        appState.hasCompletedOnboarding = true
                        HapticsService.success()
                    }
                } label: {
                    Text(currentStep == 2 ? "Démarrer l'expérience" : "Continuer")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [appState.theme.primaryAccent, appState.theme.secondaryAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: appState.theme.primaryAccent.opacity(0.5), radius: 10, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
    
    // Étape 1 : Bienvenue
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            AmbientOrbView(colors: [.purple, .blue, .pink], state: .idle, scale: 1.1)
                .frame(height: 220)
            
            Text("Rencontrez Aura")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("Votre compagnon d'intelligence artificielle intime, personnalisable et ultra-complet propulsé par l'écosystème Google Gemini.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 28)
            
            VStack(alignment: .leading, spacing: 12) {
                featureBullet(icon: "brain.head.profile", text: "Mémoire à long terme évolutive")
                featureBullet(icon: "waveform.circle.fill", text: "Appel vocal direct avec orbe interactif")
                featureBullet(icon: "slider.horizontal.3", text: "Personnalité, voix et hologramme sur-mesure")
            }
            .padding(.top, 10)
        }
    }
    
    // Étape 2 : Personnalisation initiale
    private var companionSetupStep: some View {
        VStack(spacing: 20) {
            Text("Choisissez votre Compagnon")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
            
            Text("Quel trait de caractère résonne le plus avec vous ? Vous pourrez tout modifier plus tard.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach([CompanionArchetype.compassionate, CompanionArchetype.polymath, CompanionArchetype.witty, CompanionArchetype.zen]) { arch in
                    Button {
                        appState.companionProfile.archetype = arch
                        appState.companionProfile.bio = arch.defaultBio
                        HapticsService.light()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(arch.rawValue)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text(arch.defaultBio)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.65))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            if appState.companionProfile.archetype == arch {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(appState.theme.primaryAccent)
                            }
                        }
                        .padding(14)
                        .glassCard(
                            cornerRadius: 16,
                            strokeColor: appState.companionProfile.archetype == arch ? appState.theme.primaryAccent : Color.white.opacity(0.1)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // Étape 3 : Clé API
    private var apiKeyStep: some View {
        VStack(spacing: 18) {
            Image(systemName: "key.fill")
                .font(.system(size: 46))
                .foregroundColor(appState.theme.primaryAccent)
            
            Text("Clé API Gemini")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
            
            Text("Collez votre clé Google AI Studio pour activer la puissance de Gemini 1.5 & 2.0. Vous pouvez l'obtenir gratuitement en 30 secondes.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            TextField("Collez votre clé API...", text: $appState.apiKey)
                .padding(14)
                .glassCard(cornerRadius: 14)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            Link(destination: URL(string: "https://aistudio.google.com/app/apikey")!) {
                Text("Obtenir ma clé gratuite sur Google AI Studio ↗")
                    .font(.caption.bold())
                    .foregroundColor(appState.theme.primaryAccent)
            }
        }
    }
    
    private func featureBullet(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(appState.theme.primaryAccent)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
    }
}
