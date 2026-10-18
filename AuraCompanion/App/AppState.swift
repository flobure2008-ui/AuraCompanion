import SwiftUI

@MainActor
public final class AppState: ObservableObject {
    @Published public var apiKey: String {
        didSet { storage.apiKey = apiKey }
    }
    
    @Published public var selectedModel: GeminiModel {
        didSet { storage.selectedModel = selectedModel }
    }
    
    @Published public var companionProfile: CompanionProfile {
        didSet { storage.saveProfile(companionProfile) }
    }
    
    @Published public var memories: [MemoryItem] {
        didSet { storage.saveMemories(memories) }
    }
    
    @Published public var sessions: [ConversationSession] {
        didSet { storage.saveSessions(sessions) }
    }
    
    @Published public var currentSessionId: UUID
    
    @Published public var theme: AppTheme {
        didSet { storage.theme = theme }
    }
    
    @Published public var userName: String {
        didSet { storage.userName = userName }
    }
    
    @Published public var hasCompletedOnboarding: Bool {
        didSet { storage.hasCompletedOnboarding = hasCompletedOnboarding }
    }
    
    @Published public var newlyLearnedMemoryAlert: String?
    
    private let storage = StorageService.shared
    
    public init() {
        self.apiKey = storage.apiKey
        self.selectedModel = storage.selectedModel
        self.companionProfile = storage.loadProfile()
        self.memories = storage.loadMemories()
        let loadedSessions = storage.loadSessions()
        self.sessions = loadedSessions
        self.currentSessionId = loadedSessions.first?.id ?? UUID()
        self.theme = storage.theme
        self.userName = storage.userName
        self.hasCompletedOnboarding = storage.hasCompletedOnboarding
    }
    
    public var currentSession: ConversationSession {
        get {
            sessions.first(where: { $0.id == currentSessionId }) ?? sessions.first ?? createNewSession()
        }
        set {
            if let index = sessions.firstIndex(where: { $0.id == newValue.id }) {
                sessions[index] = newValue
            }
        }
    }
    
    public func createNewSession() -> ConversationSession {
        let newSession = ConversationSession(
            title: "Discussion avec \(companionProfile.name)",
            messages: [
                ChatMessage(
                    sender: .companion,
                    content: "Me revoilà ! De quoi aimeriez-vous parler ou sur quoi souhaitez-vous avancer aujourd'hui ?",
                    moodResonance: companionProfile.currentMood
                )
            ]
        )
        sessions.insert(newSession, at: 0)
        currentSessionId = newSession.id
        return newSession
    }
    
    public func deleteSession(_ session: ConversationSession) {
        sessions.removeAll(where: { $0.id == session.id })
        if sessions.isEmpty {
            _ = createNewSession()
        } else if currentSessionId == session.id {
            currentSessionId = sessions.first!.id
        }
    }
    
    public func addMemory(_ item: MemoryItem) {
        memories.insert(item, at: 0)
    }
    
    public func removeMemory(at offsets: IndexSet) {
        memories.remove(atOffsets: offsets)
    }
    
    public func toggleMemoryActive(_ id: UUID) {
        if let idx = memories.firstIndex(where: { $0.id == id }) {
            memories[idx].isActive.toggle()
        }
    }
}
