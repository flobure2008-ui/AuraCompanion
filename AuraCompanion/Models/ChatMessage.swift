import Foundation

public enum MessageSender: String, Codable {
    case user
    case companion
    case system
}

public struct ChatMessage: Identifiable, Codable, Equatable {
    public let id: UUID
    public let sender: MessageSender
    public var content: String
    public let timestamp: Date
    public var imageData: Data?
    public var isStreaming: Bool
    public var isFavorite: Bool
    public var moodResonance: CompanionMood?
    
    public init(
        id: UUID = UUID(),
        sender: MessageSender,
        content: String,
        timestamp: Date = Date(),
        imageData: Data? = nil,
        isStreaming: Bool = false,
        isFavorite: Bool = false,
        moodResonance: CompanionMood? = nil
    ) {
        self.id = id
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
        self.imageData = imageData
        self.isStreaming = isStreaming
        self.isFavorite = isFavorite
        self.moodResonance = moodResonance
    }
}

public struct ConversationSession: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var createdAt: Date
    public var updatedAt: Date
    public var messages: [ChatMessage]
    
    public init(
        id: UUID = UUID(),
        title: String = "Nouvelle conversation",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        messages: [ChatMessage] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messages = messages
    }
    
    public var previewSnippet: String {
        messages.last?.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Aucun message pour le moment"
    }
}
