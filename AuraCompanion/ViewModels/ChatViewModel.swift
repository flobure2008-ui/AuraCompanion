import SwiftUI
import PhotosUI

@MainActor
public final class ChatViewModel: ObservableObject {
    @Published public var inputText: String = ""
    @Published public var isGenerating: Bool = false
    @Published public var selectedImageData: Data?
    @Published public var selectedItem: PhotosPickerItem?
    @Published public var errorMessage: String?
    
    public let geminiService = GeminiService.shared
    public let speechService = SpeechService.shared
    public let playbackService = AudioPlaybackService.shared
    
    public init() {}
    
    public func handleSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item = item else {
            selectedImageData = nil
            return
        }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                // Compression de l'image si nécessaire
                if let uiImage = UIImage(data: data),
                   let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                    self.selectedImageData = compressed
                } else {
                    self.selectedImageData = data
                }
            }
        } catch {
            print("Erreur de chargement d'image: \(error)")
        }
    }
    
    public func sendMessage(appState: AppState) async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (!text.isEmpty || selectedImageData != nil), !isGenerating else { return }
        
        guard !appState.apiKey.isEmpty else {
            self.errorMessage = "Veuillez renseigner votre clé API Gemini dans les Réglages."
            HapticsService.heavy()
            return
        }
        
        HapticsService.light()
        
        let promptToSend = text.isEmpty ? "Décris et analyse cette image." : text
        let imageToSend = selectedImageData
        
        // Nettoyage de l'input
        inputText = ""
        selectedImageData = nil
        selectedItem = nil
        errorMessage = nil
        
        // 1. Ajout du message utilisateur
        let userMessage = ChatMessage(
            sender: .user,
            content: promptToSend,
            imageData: imageToSend
        )
        
        var currentSession = appState.currentSession
        currentSession.messages.append(userMessage)
        
        // Si premier message de la conversation, mettre à jour le titre
        if currentSession.messages.count <= 2 {
            currentSession.title = String(promptToSend.prefix(32))
        }
        
        // 2. Préparation du message streaming du compagnon
        let companionMessageId = UUID()
        let initialCompanionMessage = ChatMessage(
            id: companionMessageId,
            sender: .companion,
            content: "",
            isStreaming: true,
            moodResonance: appState.companionProfile.currentMood
        )
        currentSession.messages.append(initialCompanionMessage)
        appState.currentSession = currentSession
        
        isGenerating = true
        
        // Construction du System Prompt
        let systemPrompt = appState.companionProfile.buildSystemPrompt(
            userName: appState.userName,
            memories: appState.memories
        )
        
        do {
            let fullReply = try await geminiService.streamGenerateContent(
                apiKey: appState.apiKey,
                model: appState.selectedModel,
                systemInstruction: systemPrompt,
                history: currentSession.messages.dropLast(), // sans le message de streaming
                userPrompt: promptToSend,
                imageData: imageToSend,
                temperature: 0.85
            ) { [weak self] chunk in
                guard self != nil else { return }
                if let idx = appState.currentSession.messages.firstIndex(where: { $0.id == companionMessageId }) {
                    var updated = appState.currentSession
                    updated.messages[idx].content += chunk
                    appState.currentSession = updated
                }
            }
            
            // Fin du streaming
            if let idx = appState.currentSession.messages.firstIndex(where: { $0.id == companionMessageId }) {
                var updated = appState.currentSession
                updated.messages[idx].isStreaming = false
                updated.messages[idx].content = fullReply
                appState.currentSession = updated
            }
            
            isGenerating = false
            HapticsService.success()
            
            // 3. Tâche de fond : Analyse et extraction automatique des nouveaux souvenirs
            Task.detached(priority: .background) {
                let extracted = await GeminiService.shared.extractMemories(
                    apiKey: appState.apiKey,
                    message: promptToSend
                )
                if !extracted.isEmpty {
                    await MainActor.run {
                        for item in extracted {
                            appState.addMemory(item)
                        }
                        appState.newlyLearnedMemoryAlert = "Nouveau souvenir mémorisé par \(appState.companionProfile.name) !"
                    }
                }
            }
            
        } catch {
            isGenerating = false
            self.errorMessage = error.localizedDescription
            HapticsService.heavy()
            
            // Retirer le message streaming si échec complet
            if let idx = appState.currentSession.messages.firstIndex(where: { $0.id == companionMessageId }),
               appState.currentSession.messages[idx].content.isEmpty {
                var updated = appState.currentSession
                updated.messages.remove(at: idx)
                appState.currentSession = updated
            }
        }
    }
    
    public func toggleVoiceDictation() {
        if speechService.isRecording {
            speechService.stopListening()
            if !speechService.transcribedText.isEmpty {
                if !inputText.isEmpty { inputText += " " }
                inputText += speechService.transcribedText
            }
            HapticsService.medium()
        } else {
            Task {
                let granted = await speechService.requestPermissions()
                if granted {
                    do {
                        try speechService.startListening()
                        HapticsService.light()
                    } catch {
                        self.errorMessage = "Impossible de démarrer le micro : \(error.localizedDescription)"
                    }
                } else {
                    self.errorMessage = "Veuillez autoriser l'accès au micro et à la reconnaissance vocale."
                }
            }
        }
    }
    
    public func readAloud(message: ChatMessage, profile: CompanionProfile) {
        if playbackService.isSpeaking {
            playbackService.stop()
        } else {
            playbackService.speak(
                text: message.content,
                voiceIdentifier: profile.voiceIdentifier,
                pitch: profile.voicePitch,
                rate: profile.voiceRate
            )
        }
    }
}
