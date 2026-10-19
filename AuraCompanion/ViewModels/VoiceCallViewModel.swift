import SwiftUI
import Combine

public enum CallState {
    case idle
    case listening
    case thinking
    case speaking
    
    public var label: String {
        switch self {
        case .idle: return "Prêt à échanger"
        case .listening: return "À votre écoute..."
        case .thinking: return "Réflexion en cours..."
        case .speaking: return "Votre compagnon s'exprime"
        }
    }
}

@MainActor
public final class VoiceCallViewModel: ObservableObject {
    @Published public var state: CallState = .idle
    @Published public var lastUserSpeech: String = ""
    @Published public var lastCompanionSpeech: String = ""
    @Published public var isMuted: Bool = false
    @Published public var continuousDialogue: Bool = true
    @Published public var orbScale: CGFloat = 1.0
    
    public let speechService = SpeechService.shared
    public let playbackService = AudioPlaybackService.shared
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Observer les retranscriptions partielles pour animer l'orbe
        speechService.$transcribedText
            .sink { [weak self] text in
                guard let self = self else { return }
                if !text.isEmpty {
                    self.lastUserSpeech = text
                }
            }
            .store(in: &cancellables)
            
        // Observer le niveau audio
        speechService.$audioLevel
            .sink { [weak self] level in
                guard let self = self, self.state == .listening else { return }
                withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.5)) {
                    self.orbScale = 1.0 + CGFloat(level) * 0.45
                }
            }
            .store(in: &cancellables)
    }
    
    public func startSession(appState: AppState) async {
        let granted = await speechService.requestPermissions()
        guard granted else { return }
        
        // Phrase d'accueil vocale si rien n'a été dit
        state = .speaking
        let greeting = "Je t'écoute ! De quoi souhaites-tu parler ?"
        lastCompanionSpeech = greeting
        
        playbackService.speak(
            text: greeting,
            voiceIdentifier: appState.companionProfile.voiceIdentifier,
            pitch: appState.companionProfile.voicePitch,
            rate: appState.companionProfile.voiceRate
        ) { [weak self] in
            guard let self = self else { return }
            self.startListeningTurn(appState: appState)
        }
    }
    
    public func startListeningTurn(appState: AppState) {
        guard !isMuted else { return }
        playbackService.stop()
        state = .listening
        lastUserSpeech = ""
        
        do {
            try speechService.startListening()
        } catch {
            print("Erreur écoute : \(error)")
            state = .idle
        }
    }
    
    public func finishSpeakingTurn(appState: AppState) async {
        speechService.stopListening()
        let query = speechService.transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            state = .idle
            return
        }
        
        state = .thinking
        lastUserSpeech = query
        
        // Ajouter le message à la session active
        let userMessage = ChatMessage(sender: .user, content: query)
        var session = appState.currentSession
        session.messages.append(userMessage)
        appState.currentSession = session
        
        let systemPrompt = appState.companionProfile.buildSystemPrompt(
            userName: appState.userName,
            memories: appState.memories
        )
        
        do {
            let response = try await GeminiService.shared.streamGenerateContent(
                apiKey: appState.apiKey,
                provider: appState.provider,
                model: appState.selectedModel,
                customModelName: appState.customModelName,
                customEndpoint: appState.customEndpoint,
                systemInstruction: systemPrompt + "\nIMPORTANT: Tu es en mode appel vocal temps réel. Sois concis, direct et très naturel à l'oral, sans puces ni markdown complexe.",
                history: session.messages,
                userPrompt: query,
                temperature: 0.8
            ) { _ in }
            
            lastCompanionSpeech = response
            
            let companionMessage = ChatMessage(
                sender: .companion,
                content: response,
                moodResonance: appState.companionProfile.currentMood
            )
            session.messages.append(companionMessage)
            appState.currentSession = session
            
            state = .speaking
            playbackService.speak(
                text: response,
                voiceIdentifier: appState.companionProfile.voiceIdentifier,
                pitch: appState.companionProfile.voicePitch,
                rate: appState.companionProfile.voiceRate
            ) { [weak self] in
                guard let self = self else { return }
                if self.continuousDialogue {
                    self.startListeningTurn(appState: appState)
                } else {
                    self.state = .idle
                }
            }
            
        } catch {
            lastCompanionSpeech = "Désolé, une anomalie s'est produite."
            state = .idle
        }
    }
    
    public func endCall() {
        speechService.stopListening()
        playbackService.stop()
        state = .idle
        orbScale = 1.0
    }
}
