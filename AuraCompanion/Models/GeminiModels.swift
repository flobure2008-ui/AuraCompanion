import Foundation

// MARK: - AI Provider
public enum AIProvider: String, CaseIterable, Identifiable, Codable {
    case freeBuiltIn = "Mode Gratuit Immédiat (Sans Clé requise)"
    case googleGemini = "Google Gemini Officiel (Avec votre Clé)"
    case openAICompatible = "OpenAI / OpenRouter / Groq / DeepSeek"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .freeBuiltIn:
            return "Fonctionne instantanément sans aucune configuration ni clé API requise."
        case .googleGemini:
            return "Utilise votre clé API Google AI Studio pour Gemini 1.5 & 2.0."
        case .openAICompatible:
            return "Utilise n'importe quel endpoint tiers compatible (OpenRouter, Groq, Ollama, etc.)."
        }
    }
}

// MARK: - Gemini Supported Models
public enum GeminiModel: String, CaseIterable, Identifiable, Codable {
    case gemini20Flash = "gemini-2.0-flash"
    case gemini15Flash = "gemini-1.5-flash"
    case gemini15Pro = "gemini-1.5-pro"
    case gemini15Flash8B = "gemini-1.5-flash-8b"
    case custom = "custom"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .gemini20Flash:
            return "Gemini 2.0 Flash (Recommandé • Ultra-Rapide)"
        case .gemini15Flash:
            return "Gemini 1.5 Flash (Standard Universel)"
        case .gemini15Pro:
            return "Gemini 1.5 Pro (Raisonnement Élaboré)"
        case .gemini15Flash8B:
            return "Gemini 1.5 Flash-8B (Économe & Fluide)"
        case .custom:
            return "Modèle Personnalisé"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .gemini20Flash:
            return "Dernière technologie Google avec vitesse et précision maximales."
        case .gemini15Flash:
            return "Le modèle le plus stable et universel pour le chat au quotidien."
        case .gemini15Pro:
            return "Idéal pour l'empathie poussée, la poésie et la logique complexe."
        case .gemini15Flash8B:
            return "Réponses instantanées avec latence minimale."
        case .custom:
            return "Entrez manuellement le modèle de votre choix."
        }
    }
}

// MARK: - Simple Clean Google Generative AI Request
public struct GoogleGeminiDirectRequest: Codable {
    public struct ContentItem: Codable {
        public let role: String?
        public let parts: [PartItem]
        
        public init(role: String? = nil, parts: [PartItem]) {
            self.role = role
            self.parts = parts
        }
    }
    
    public struct PartItem: Codable {
        public let text: String?
        public let inlineData: InlineDataItem?
        
        enum CodingKeys: String, CodingKey {
            case text
            case inlineData = "inline_data"
        }
        
        public init(text: String) {
            self.text = text
            self.inlineData = nil
        }
        
        public init(mimeType: String, base64: String) {
            self.text = nil
            self.inlineData = InlineDataItem(mimeType: mimeType, data: base64)
        }
    }
    
    public struct InlineDataItem: Codable {
        public let mimeType: String
        public let data: String
        
        enum CodingKeys: String, CodingKey {
            case mimeType = "mime_type"
            case data
        }
    }
    
    public struct SystemInstructionItem: Codable {
        public let parts: [PartItem]
        public init(text: String) {
            self.parts = [PartItem(text: text)]
        }
    }
    
    public struct GenerationConfigItem: Codable {
        public let temperature: Double
        public let maxOutputTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case temperature
            case maxOutputTokens = "max_output_tokens"
        }
    }
    
    public let contents: [ContentItem]
    public let systemInstruction: SystemInstructionItem?
    public let generationConfig: GenerationConfigItem?
    
    enum CodingKeys: String, CodingKey {
        case contents
        case systemInstruction = "system_instruction"
        case generationConfig = "generation_config"
    }
}

// MARK: - API Response Payloads
public struct GeminiResponse: Codable {
    public struct Candidate: Codable {
        public struct Content: Codable {
            public struct Part: Codable {
                public let text: String?
            }
            public let parts: [Part]?
        }
        public let content: Content?
    }
    public struct APIError: Codable {
        public let code: Int?
        public let message: String?
    }
    
    public let candidates: [Candidate]?
    public let error: APIError?
    
    public var textResponse: String? {
        candidates?.first?.content?.parts?.compactMap { $0.text }.joined()
    }
}

// MARK: - OpenAI / Universal Chat Payload
public struct UniversalChatRequest: Codable {
    public struct Message: Codable {
        public let role: String
        public let content: String
    }
    public let model: String
    public let messages: [Message]
    public let temperature: Double?
}

public struct UniversalChatResponse: Codable {
    public struct Choice: Codable {
        public struct Message: Codable {
            public let content: String?
        }
        public let message: Message?
    }
    public let choices: [Choice]?
    
    public var textResponse: String? {
        choices?.first?.message?.content
    }
}

// MARK: - Gemini Error
public enum GeminiError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case networkError(Error)
    case badServerResponse(statusCode: Int, message: String)
    case decodingError(Error)
    case emptyResponse
    
    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Aucune clé API configurée. Vous pouvez utiliser le Mode Gratuit Immédiat dans les Réglages."
        case .invalidURL:
            return "URL de l'API invalide."
        case .networkError(let error):
            return "Erreur de connexion : \(error.localizedDescription)"
        case .badServerResponse(let code, let message):
            if message.contains("API_KEY_INVALID") {
                return "Clé Google Gemini invalide. Activez le Mode Gratuit dans les Réglages pour continuer sans clé."
            }
            return "Réponse de l'API [\(code)]: \(message)"
        case .decodingError(let error):
            return "Erreur de format : \(error.localizedDescription)"
        case .emptyResponse:
            return "L'IA a renvoyé une réponse vide."
        }
    }
}
