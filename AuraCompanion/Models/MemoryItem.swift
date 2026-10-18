import Foundation

public enum MemoryCategory: String, CaseIterable, Identifiable, Codable {
    case userFact = "Profil & Faits"
    case preference = "Goûts & Préférences"
    case relationshipLore = "Souvenirs Partagés"
    case lifeGoal = "Objectifs & Rêves"
    case secretOrKey = "Notes Privées"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .userFact: return "person.crop.circle.badge.checkmark"
        case .preference: return "heart.fill"
        case .relationshipLore: return "sparkles"
        case .lifeGoal: return "flag.fill"
        case .secretOrKey: return "lock.shield.fill"
        }
    }
}

public struct MemoryItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var category: MemoryCategory
    public var key: String
    public var value: String
    public var confidence: Double
    public var createdAt: Date
    public var isActive: Bool
    
    public init(
        id: UUID = UUID(),
        category: MemoryCategory = .userFact,
        key: String,
        value: String,
        confidence: Double = 1.0,
        createdAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.category = category
        self.key = key
        self.value = value
        self.confidence = confidence
        self.createdAt = createdAt
        self.isActive = isActive
    }
}

extension Array where Element == MemoryItem {
    /// Formatte les souvenirs actifs en bloc de contexte à injecter dans le prompt système
    public func formattedForSystemPrompt() -> String {
        let activeItems = self.filter { $0.isActive }
        guard !activeItems.isEmpty else { return "Aucun souvenir particulier enregistré pour le moment." }
        
        var promptLines: [String] = []
        let grouped = Dictionary(grouping: activeItems, by: { $0.category })
        
        for (category, items) in grouped {
            promptLines.append("### \(category.rawValue):")
            for item in items {
                promptLines.append("- \(item.key): \(item.value)")
            }
        }
        
        return promptLines.joined(separator: "\n")
    }
}
