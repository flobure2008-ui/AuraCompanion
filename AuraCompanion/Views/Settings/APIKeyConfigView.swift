import SwiftUI

public struct APIKeyConfigView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputKey: String = ""
    @State private var inputEndpoint: String = ""
    @State private var isSecured: Bool = true
    @State private var isTesting: Bool = false
    @State private var testSuccess: Bool?
    @State private var testMessage: String?
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Connexion & Clé API")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            // Sélecteur de fournisseur
            VStack(alignment: .leading, spacing: 6) {
                Text("Fournisseur d'IA").font(.caption).foregroundColor(.white.opacity(0.6))
                Picker("Fournisseur", selection: $appState.provider) {
                    ForEach(AIProvider.allCases) { prov in
                        Text(prov.rawValue).tag(prov)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Si OpenAI / OpenRouter compatible : champ URL endpoint
            if appState.provider == .openAICompatible {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Endpoint d'API").font(.caption).foregroundColor(.white.opacity(0.6))
                    TextField("https://openrouter.ai/api/v1/chat/completions", text: $inputEndpoint)
                        .padding(12)
                        .glassCard(cornerRadius: 12)
                        .foregroundColor(.white)
                }
            }
            
            // Clé API
            VStack(alignment: .leading, spacing: 6) {
                Text(appState.provider == .googleGemini ? "Clé API Google Gemini" : "Clé API (OpenRouter / Groq / OpenAI)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                HStack {
                    if isSecured {
                        SecureField("Collez votre clé API ici...", text: $inputKey)
                            .foregroundColor(.white)
                    } else {
                        TextField("Collez votre clé API ici...", text: $inputKey)
                            .foregroundColor(.white)
                    }
                    
                    Button {
                        isSecured.toggle()
                    } label: {
                        Image(systemName: isSecured ? "eye.slash" : "eye")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(12)
                .glassCard(cornerRadius: 12)
            }
            
            // Boutons d'action : Tester / Enregistrer
            HStack(spacing: 12) {
                Button {
                    testAPIConnection()
                } label: {
                    HStack(spacing: 6) {
                        if isTesting {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.shield.fill")
                        }
                        Text(isTesting ? "Test en cours..." : "Tester la clé")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .glassCard(cornerRadius: 10)
                }
                .disabled(inputKey.isEmpty || isTesting)
                
                Button {
                    appState.apiKey = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)
                    appState.customEndpoint = inputEndpoint.trimmingCharacters(in: .whitespacesAndNewlines)
                    HapticsService.success()
                } label: {
                    Text("Enregistrer")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(appState.theme.primaryAccent)
                        .cornerRadius(10)
                }
                .disabled(inputKey.isEmpty)
                
                Spacer()
                
                if appState.provider == .googleGemini {
                    Link(destination: URL(string: "https://aistudio.google.com/app/apikey")!) {
                        HStack(spacing: 4) {
                            Text("Clé gratuite")
                            Image(systemName: "arrow.up.forward.square")
                        }
                        .font(.caption.bold())
                        .foregroundColor(appState.theme.primaryAccent)
                    }
                }
            }
            
            // Résultat du test
            if let success = testSuccess {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(success ? .green : .orange)
                        .padding(.top, 2)
                    
                    Text(testMessage ?? (success ? "Connexion établie avec succès !" : "Erreur de connexion"))
                        .font(.caption.weight(.medium))
                        .foregroundColor(success ? .green : .white.opacity(0.9))
                }
                .padding(10)
                .glassCard(cornerRadius: 10, strokeColor: success ? Color.green.opacity(0.3) : Color.orange.opacity(0.3))
                .padding(.top, 4)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
        .onAppear {
            inputKey = appState.apiKey
            inputEndpoint = appState.customEndpoint
        }
    }
    
    private func testAPIConnection() {
        isTesting = true
        testSuccess = nil
        testMessage = nil
        
        let keyToTest = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let endpointToTest = inputEndpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            do {
                let response = try await GeminiService.shared.streamGenerateContent(
                    apiKey: keyToTest,
                    provider: appState.provider,
                    model: .gemini20Flash,
                    customModelName: appState.customModelName,
                    customEndpoint: endpointToTest,
                    systemInstruction: nil,
                    history: [],
                    userPrompt: "Réponds exactement 'OK_AURA'.",
                    temperature: 0.1
                ) { _ in }
                
                await MainActor.run {
                    self.isTesting = false
                    self.testSuccess = true
                    self.testMessage = "Succès ! Connecté avec réponse reçue : \"\(response.trimmingCharacters(in: .whitespacesAndNewlines))\""
                    appState.apiKey = keyToTest
                    appState.customEndpoint = endpointToTest
                    HapticsService.success()
                }
            } catch {
                await MainActor.run {
                    self.isTesting = false
                    self.testSuccess = false
                    self.testMessage = error.localizedDescription
                    HapticsService.heavy()
                }
            }
        }
    }
}
