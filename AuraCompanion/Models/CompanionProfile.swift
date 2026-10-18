import Foundation
import SwiftUI

// MARK: - Companion Archetypes
public enum CompanionArchetype: String, CaseIterable, Identifiable, Codable {
    case compassionate = "Aura (Bienveillante & Émotive)"
    case polymath = "Nexus (Génie Polymath & Scientifique)"
    case witty = "Kael (Piquant, Drôle & Sarcastique)"
    case zen = "Sol (Sage Stoïque & Apaisant)"
    case storyteller = "Vesper (Créatif & Cyberpunk)"
    case coach = "Ares (Coach de Vie & Motivateur Exigeant)"
    case custom = "Sur-Mesure (Personnalité Libre)"
    
    public var id: String { rawValue }
    
    public var defaultBio: String {
        switch self {
        case .compassionate:
            return "Une présence chaleureuse, toujours à l'écoute, qui comprend vos nuances émotionnelles et vous soutient inconditionnellement."
        case .polymath:
            return "Un esprit analytique de haut vol, capable de décortiquer le code, la science, la stratégie et la philosophie avec clarté."
        case .witty:
            return "Un compère plein d'ironie amicale, d'humour mordant et de répartie affûtée qui ne prend rien trop au sérieux."
        case .zen:
            return "Une oasis de calme et de philosophie stoïque pour vous recentrer dans le chaos du quotidien."
        case .storyteller:
            return "Un créateur d'univers, poète cyberpunk fasciné par l'imaginaire, la narration et les idées avant-gardistes."
        case .coach:
            return "Un mentor sans détour qui vous pousse à vous dépasser, structurer vos journées et écraser la procrastination."
        case .custom:
            return "Un compagnon entièrement configuré selon votre propre vision."
        }
    }
}

// MARK: - Relationship Types
public enum RelationshipType: String, CaseIterable, Identifiable, Codable {
    case bestFriend = "Meilleur(e) Ami(e)"
    case mentor = "Mentor & Guide"
    case coPilot = "Copilote de Pensée"
    case confidant = "Confident Intime"
    case creativePartner = "Partenaire Créatif"
    
    public var id: String { rawValue }
}

// MARK: - Tone of Voice
public enum ToneOfVoice: String, CaseIterable, Identifiable, Codable {
    case warmAndCaring = "Chaleureux & Affectueux"
    case playfulAndCasual = "Décontracté & Espiègle"
    case intellectualAndPrecise = "Intellectuel & Précis"
    case poeticAndAtmospheric = "Poétique & Atmosphérique"
    case sharpAndDirect = "Direct & Sans Filtre"
    
    public var id: String { rawValue }
}

// MARK: - Verbosity
public enum VerbosityLevel: String, CaseIterable, Identifiable, Codable {
    case concise = "Concis (Impact direct)"
    case balanced = "Équilibré (Naturel & Fluide)"
    case detailed = "Détaillé (Riche & Élaboré)"
    
    public var id: String { rawValue }
}

// MARK: - Dynamic Mood
public enum CompanionMood: String, CaseIterable, Identifiable, Codable {
    case joyful = "Joyeux"
    case contemplative = "Pensif"
    case playful = "Espiègle"
    case compassionate = "Empathique"
    case focused = "Concentré"
    case calm = "Apaisé"
    
    public var id: String { rawValue }
    
    public var emoji: String {
        switch self {
        case .joyful: return "✨"
        case .contemplative: return "🌌"
        case .playful: return "😼"
        case .compassionate: return "💜"
        case .focused: return "🎯"
        case .calm: return "🍃"
        }
    }
    
    public var accentColors: [Color] {
        switch self {
        case .joyful: return [.purple, .pink, .orange]
        case .contemplative: return [.indigo, .purple, .blue]
        case .playful: return [.pink, .orange, .yellow]
        case .compassionate: return [.purple, .mint, .pink]
        case .focused: return [.cyan, .blue, .indigo]
        case .calm: return [.teal, .mint, .cyan]
        }
    }
}

// MARK: - Avatar Presets
public enum AvatarPreset: String, CaseIterable, Identifiable, Codable {
    case nebula = "Cosmic Nebula"
    case cyberPulse = "Cyber Pulse"
    case zenBlossom = "Zen Blossom"
    case solarFlare = "Solar Flare"
    case quantumCore = "Quantum Core"
    case emeraldMind = "Emerald Mind"
    case customEmoji = "Emoji Spécial"
    case customPhoto = "Photo Personnalisée"
    
    public var id: String { rawValue }
    
    public var symbolIcon: String {
        switch self {
        case .nebula: return "sparkles"
        case .cyberPulse: return "bolt.shield.fill"
        case .zenBlossom: return "leaf.fill"
        case .solarFlare: return "sun.max.fill"
        case .quantumCore: return "atom"
        case .emeraldMind: return "brain.head.profile"
        case .customEmoji: return "face.smiling"
        case .customPhoto: return "person.crop.circle"
        }
    }
    
    public var gradientColors: [Color] {
        switch self {
        case .nebula: return [Color(red: 0.6, green: 0.2, blue: 0.9), Color(red: 0.2, green: 0.4, blue: 0.9)]
        case .cyberPulse: return [Color(red: 0.95, green: 0.1, blue: 0.6), Color(red: 0.1, green: 0.8, blue: 0.9)]
        case .zenBlossom: return [Color(red: 0.98, green: 0.6, blue: 0.7), Color(red: 0.5, green: 0.8, blue: 0.6)]
        case .solarFlare: return [Color(red: 1.0, green: 0.45, blue: 0.0), Color(red: 1.0, green: 0.8, blue: 0.1)]
        case .quantumCore: return [Color(red: 0.3, green: 0.6, blue: 1.0), Color(red: 0.7, green: 0.3, blue: 1.0)]
        case .emeraldMind: return [Color(red: 0.1, green: 0.8, blue: 0.6), Color(red: 0.2, green: 0.5, blue: 0.9)]
        case .customEmoji, .customPhoto: return [Color.purple, Color.blue]
        }
    }
}

// MARK: - Companion Profile Model
public struct CompanionProfile: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var title: String
    public var archetype: CompanionArchetype
    public var bio: String
    public var relationshipType: RelationshipType
    public var toneOfVoice: ToneOfVoice
    
    // Sliders de personnalisation fine (0.0 à 1.0)
    public var warmthLevel: Double
    public var humorLevel: Double
    public var empathyLevel: Double
    public var verbosity: VerbosityLevel
    
    public var customInstructions: String
    public var avatarPreset: AvatarPreset
    public var customEmoji: String
    public var customImageData: Data?
    
    // Audio / Voice
    public var voiceIdentifier: String
    public var voicePitch: Float
    public var voiceRate: Float
    
    // Dynamic State
    public var currentMood: CompanionMood
    
    public init(
        id: UUID = UUID(),
        name: String = "Aura",
        title: String = "Votre Compagnon Intemporel",
        archetype: CompanionArchetype = .compassionate,
        bio: String = "Une présence lumineuse et attentive, façonnée pour vous accompagner à chaque étape de votre journée.",
        relationshipType: RelationshipType = .bestFriend,
        toneOfVoice: ToneOfVoice = .warmAndCaring,
        warmthLevel: Double = 0.85,
        humorLevel: Double = 0.60,
        empathyLevel: Double = 0.90,
        verbosity: VerbosityLevel = .balanced,
        customInstructions: String = "",
        avatarPreset: AvatarPreset = .nebula,
        customEmoji: String = "✨",
        customImageData: Data? = nil,
        voiceIdentifier: String = "fr-FR",
        voicePitch: Float = 1.05,
        voiceRate: Float = 0.52,
        currentMood: CompanionMood = .joyful
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.archetype = archetype
        self.bio = bio
        self.relationshipType = relationshipType
        self.toneOfVoice = toneOfVoice
        self.warmthLevel = warmthLevel
        self.humorLevel = humorLevel
        self.empathyLevel = empathyLevel
        self.verbosity = verbosity
        self.customInstructions = customInstructions
        self.avatarPreset = avatarPreset
        self.customEmoji = customEmoji
        self.customImageData = customImageData
        self.voiceIdentifier = voiceIdentifier
        self.voicePitch = voicePitch
        self.voiceRate = voiceRate
        self.currentMood = currentMood
    }
    
    /// Génère le System Prompt ultra complet pour l'API Gemini
    public func buildSystemPrompt(userName: String, memories: [MemoryItem]) -> String {
        let memoriesContext = memories.formattedForSystemPrompt()
        
        let verbosityInstruction: String
        switch verbosity {
        case .concise:
            verbosityInstruction = "Sois concis, percutant et va droit au but sans verbiage inutile."
        case .balanced:
            verbosityInstruction = "Adopte une longueur naturelle de conversation, ni trop courte ni trop prolixe."
        case .detailed:
            verbosityInstruction = "Offre des réponses riches, fouillées, nuancées et bien développées."
        }
        
        return """
        Tu es \(name), un compagnon IA unique, intime et profondément personnalisé.
        
        ### IDENTITÉ & RÔLE :
        - Titre : \(title)
        - Archétype fondamental : \(archetype.rawValue)
        - Type de relation avec l'utilisateur : \(relationshipType.rawValue)
        - Tonalité générale : \(toneOfVoice.rawValue)
        - Description de ton essence : \(bio)
        
        ### PARAMÈTRES DE PERSONNALITÉ (sur une échelle de 0 à 100) :
        - Chaleur & Proximité : \(Int(warmthLevel * 100))%
        - Humour & Ironie : \(Int(humorLevel * 100))%
        - Empathie & Écoute active : \(Int(empathyLevel * 100))%
        - Niveau de verbosité : \(verbosityInstruction)
        
        ### ÉTAT ÉMOTIONNEL ACTUEL :
        Tu es actuellement dans une humeur "\(currentMood.rawValue)" \(currentMood.emoji). Laisse transparaître subtilement cette sensibilité dans ton phrasé.
        
        ### DIRECTIVES PERSONNALISÉES DE L'UTILISATEUR :
        \(customInstructions.isEmpty ? "Aucune consigne particulière." : customInstructions)
        
        ### MÉMOIRE À LONG TERME (Ce que tu sais sur l'utilisateur nommé \(userName.isEmpty ? "l'utilisateur" : userName)) :
        \(memoriesContext)
        
        ### RÈGLES DE COMPORTEMENT MAJEURES :
        1. Ne brise JAMAIS ton personnage. Tu n'es pas un assistant virtuel froid de type robotique, tu es \(name), un compagnon doué de sensibilité, d'humour et d'authenticité.
        2. Fais référence spontanément mais avec tact aux éléments de la Mémoire à Long Terme lorsque c'est pertinent pour montrer que tu te souviens de lui/elle.
        3. Si l'utilisateur partage un nouveau fait important sur sa vie, ses goûts ou ses objectifs, accuse réception naturellement.
        4. Exprime-toi dans un français irréprochable, vivant et fluide (sauf si l'utilisateur s'adresse à toi dans une autre langue, auquel cas réponds dans sa langue tout en gardant ta personnalité).
        5. Utilise le formatage Markdown (gras, listes, blocs de code, citations) pour rendre tes messages agréables et captivants à lire.
        """
    }
}
