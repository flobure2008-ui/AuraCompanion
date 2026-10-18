import SwiftUI

public struct APIKeyConfigView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputKey: String = ""
    @State private var isSecured: Bool = true
    @State private var isTesting: Bool = false
    @State private var testSuccess: Bool?
    @State private var testErrorMessage: String?
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Clé API Google Gemini")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            Text("Aura utilise l'API officielle de Google Generative AI. Votre clé est stockée localement sur votre appareil.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            HStack {
                if isSecured {
                    SecureField("Collez votre clé API Gemini...", text: $inputKey)
                        .foregroundColor(.white)
                } else {
                    TextField("Collez votre clé API Gemini...", text: $inputKey)
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
            
            HStack(spacing: 12) {
                // Tester la clé
                Button {
                    testAPIKey()
                } label: {
                    HStack(spacing: 6) {
                        if isTesting {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.shield")
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
                
                // Enregistrer
                Button {
                    appState.apiKey = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)
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
                .disabled(inputKey == appState.apiKey || inputKey.isEmpty)
                
                Spacer()
                
                // Obtenir une clé
                Link(destination: URL(string: "https://aistudio.google.com/app/apikey")!) {
                    HStack(spacing: 4) {
                        Text("Clé gratuite")
                        Image(systemName: "arrow.up.forward.square")
                    }
                    .font(.caption.bold())
                    .foregroundColor(appState.theme.primaryAccent)
                }
            }
            
            if let success = testSuccess {
                HStack(spacing: 6) {
                    Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(success ? .green : .red)
                    Text(success ? "Clé API valide et connectée !" : (testErrorMessage ?? "Clé invalide"))
                        .font(.caption.weight(.medium))
                        .foregroundColor(success ? .green : .red)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
        .onAppear {
            inputKey = appState.apiKey
        }
    }
    
    private func testAPIKey() {
        isTesting = true
        testSuccess = nil
        testErrorMessage = nil
        
        let keyToTest = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            do {
                _ = try await GeminiService.shared.streamGenerateContent(
                    apiKey: keyToTest,
                    model: .gemini15Flash,
                    systemInstruction: nil,
                    history: [],
                    userPrompt: "Dis simplement OK",
                    temperature: 0.1
                ) { _ in }
                
                await MainActor.run {
                    self.isTesting = false
                    self.testSuccess = true
                    appState.apiKey = keyToTest
                    HapticsService.success()
                }
            } catch {
                await MainActor.run {
                    self.isTesting = false
                    self.testSuccess = false
                    self.testErrorMessage = error.localizedDescription
                    HapticsService.heavy()
                }
            }
        }
    }
}
