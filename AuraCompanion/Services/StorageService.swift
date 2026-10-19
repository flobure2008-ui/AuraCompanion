import Foundation

public final class StorageService {
    public static let shared = StorageService()
    
    private let defaults = UserDefaults.standard
    
    private let keyApiKey = "aura_gemini_api_key"
    private let keyProvider = "aura_ai_provider"
    private let keySelectedModel = "aura_selected_model"
    private let keyCustomModelName = "aura_custom_model_name"
    private let keyCustomEndpoint = "aura_custom_endpoint"
    private let keyProfile = "aura_companion_profile"
    private let keyMemories = "aura_companion_memories"
    private let keySessions = "aura_chat_sessions"
    private let keyTheme = "aura_app_theme"
    private let keyUserName = "aura_user_name"
    private let keyOnboardingDone = "aura_onboarding_completed"
    
    private init() {}
    
    // MARK: - API Key
    public var apiKey: String {
        get { defaults.string(forKey: keyApiKey) ?? "" }
        set { defaults.set(newValue, forKey: keyApiKey) }
    }
    
    // MARK: - Provider
    public var provider: AIProvider {
        get {
            if let saved = defaults.string(forKey: keyProvider),
               let prov = AIProvider(rawValue: saved) {
                return prov
            }
            return .googleGemini
        }
        set {
            defaults.set(newValue.rawValue, forKey: keyProvider)
        }
    }
    
    // MARK: - Selected Gemini Model
    public var selectedModel: GeminiModel {
        get {
            if let saved = defaults.string(forKey: keySelectedModel),
               let model = GeminiModel(rawValue: saved) {
                return model
            }
            return .gemini20Flash
        }
        set {
            defaults.set(newValue.rawValue, forKey: keySelectedModel)
        }
    }
    
    // MARK: - Custom Model / Endpoint
    public var customModelName: String {
        get { defaults.string(forKey: keyCustomModelName) ?? "gemini-2.0-flash" }
        set { defaults.set(newValue, forKey: keyCustomModelName) }
    }
    
    public var customEndpoint: String {
        get { defaults.string(forKey: keyCustomEndpoint) ?? "" }
        set { defaults.set(newValue, forKey: keyCustomEndpoint) }
    }
    
    // MARK: - User Name
    public var userName: String {
        get { defaults.string(forKey: keyUserName) ?? "Ami" }
        set { defaults.set(newValue, forKey: keyUserName) }
    }
    
    // MARK: - Onboarding
    public var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: keyOnboardingDone) }
        set { defaults.set(newValue, forKey: keyOnboardingDone) }
    }
    
    // MARK: - App Theme
    public var theme: AppTheme {
        get {
            if let saved = defaults.string(forKey: keyTheme),
               let theme = AppTheme(rawValue: saved) {
                return theme
            }
            return .cosmicViolet
        }
        set {
            defaults.set(newValue.rawValue, forKey: keyTheme)
        }
    }
    
    // MARK: - Companion Profile
    public func loadProfile() -> CompanionProfile {
        if let data = defaults.data(forKey: keyProfile),
           let profile = try? JSONDecoder().decode(CompanionProfile.self, from: data) {
            return profile
        }
        return CompanionProfile()
    }
    
    public func saveProfile(_ profile: CompanionProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: keyProfile)
        }
    }
    
    // MARK: - Memories
    public func loadMemories() -> [MemoryItem] {
        if let data = defaults.data(forKey: keyMemories),
           let list = try? JSONDecoder().decode([MemoryItem].self, from: data) {
            return list
        }
        return [
            MemoryItem(category: .userFact, key: "Prénom", value: userName),
            MemoryItem(category: .preference, key: "Style d'interaction", value: "Curieux, philosophique et direct"),
            MemoryItem(category: .lifeGoal, key: "Objectif du moment", value: "Découvrir et personnaliser mon IA")
        ]
    }
    
    public func saveMemories(_ memories: [MemoryItem]) {
        if let data = try? JSONEncoder().encode(memories) {
            defaults.set(data, forKey: keyMemories)
        }
    }
    
    // MARK: - Chat Sessions
    public func loadSessions() -> [ConversationSession] {
        if let data = defaults.data(forKey: keySessions),
           let sessions = try? JSONDecoder().decode([ConversationSession].self, from: data) {
            return sessions
        }
        
        let initialMessage = ChatMessage(
            sender: .companion,
            content: "Bonjour ! ✨ Je suis votre compagnon IA connecté à Gemini. Comment allez-vous aujourd'hui ?",
            moodResonance: .joyful
        )
        let initialSession = ConversationSession(
            title: "Bienvenue dans Aura",
            messages: [initialMessage]
        )
        return [initialSession]
    }
    
    public func saveSessions(_ sessions: [ConversationSession]) {
        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: keySessions)
        }
    }
    
    // MARK: - Export / Import
    public func exportAllDataJSON() -> String? {
        struct BackupPayload: Codable {
            let profile: CompanionProfile
            let memories: [MemoryItem]
            let sessions: [ConversationSession]
            let userName: String
            let exportedAt: Date
        }
        
        let payload = BackupPayload(
            profile: loadProfile(),
            memories: loadMemories(),
            sessions: loadSessions(),
            userName: userName,
            exportedAt: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(payload) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
