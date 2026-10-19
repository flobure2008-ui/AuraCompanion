import Foundation

// MARK: - AI Provider
public enum AIProvider: String, CaseIterable, Identifiable, Codable {
    case googleGemini = "Google Gemini (Officiel)"
    case openAICompatible = "OpenAI / OpenRouter / Groq / DeepSeek"
    
    public var id: String { rawValue }
}

// MARK: - Gemini Supported Models (À jour 2024-2026)
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
            return "Gemini 2.0 Flash (Recommandé & Ultra-rapide)"
        case .gemini15Flash:
            return "Gemini 1.5 Flash (Standard & Très Stable)"
        case .gemini15Pro:
            return "Gemini 1.5 Pro (Raisonnement Approfondi & Complexe)"
        case .gemini15Flash8B:
            return "Gemini 1.5 Flash-8B (Ultra-léger & Instantané)"
        case .custom:
            return "Modèle Personnalisé (Saisie libre)"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .gemini20Flash:
            return "Dernière version officielle de Google avec vitesse et multimodalité optimales."
        case .gemini15Flash:
            return "Modèle équilibré universel pour le chat quotidien et la voix en temps réel."
        case .gemini15Pro:
            return "Excellente analyse pour les réflexions philosophiques et le code."
        case .gemini15Flash8B:
            return "Consomme très peu de quota et répond avec une latence minimale."
        case .custom:
            return "Permet d'utiliser n'importe quel identifiant de modèle récent."
        }
    }
}

// MARK: - API Request Payloads (Google Generative AI)
public struct GeminiRequest: Codable {
    public let contents: [GeminiContent]
    public let systemInstruction: GeminiSystemInstruction?
    public let generationConfig: GeminiGenerationConfig?
    
    enum CodingKeys: String, CodingKey {
        case contents
        case systemInstruction = "system_instruction"
        case generationConfig = "generation_config"
    }
    
    public init(
        contents: [GeminiContent],
        systemInstruction: GeminiSystemInstruction? = nil,
        generationConfig: GeminiGenerationConfig? = nil
    ) {
        self.contents = contents
        self.systemInstruction = systemInstruction
        self.generationConfig = generationConfig
    }
}

public struct GeminiSystemInstruction: Codable {
    public let parts: [GeminiPart]
    
    public init(text: String) {
        self.parts = [GeminiPart(text: text)]
    }
}

public struct GeminiContent: Codable {
    public let role: String
    public let parts: [GeminiPart]
    
    public init(role: String, parts: [GeminiPart]) {
        self.role = role
        self.parts = parts
    }
    
    public init(role: String, text: String) {
        self.role = role
        self.parts = [GeminiPart(text: text)]
    }
}

public struct GeminiPart: Codable {
    public let text: String?
    public let inlineData: GeminiInlineData?
    
    enum CodingKeys: String, CodingKey {
        case text
        case inlineData = "inline_data"
    }
    
    public init(text: String) {
        self.text = text
        self.inlineData = nil
    }
    
    public init(inlineData: GeminiInlineData) {
        self.text = nil
        self.inlineData = inlineData
    }
}

public struct GeminiInlineData: Codable {
    public let mimeType: String
    public let data: String // Base64
    
    enum CodingKeys: String, CodingKey {
        case mimeType = "mime_type"
        case data
    }
    
    public init(mimeType: String, data: String) {
        self.mimeType = mimeType
        self.data = data
    }
}

public struct GeminiGenerationConfig: Codable {
    public var temperature: Double?
    public var topP: Double?
    public var topK: Int?
    public var maxOutputTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case temperature
        case topP
        case topK
        case maxOutputTokens = "max_output_tokens"
    }
    
    public init(temperature: Double? = 0.8, topP: Double? = 0.95, topK: Int? = 40, maxOutputTokens: Int? = 2048) {
        self.temperature = temperature
        self.topP = topP
        self.topK = topK
        self.maxOutputTokens = maxOutputTokens
    }
}

// MARK: - API Response Payloads
public struct GeminiResponse: Codable {
    public let candidates: [GeminiCandidate]?
    public let promptFeedback: GeminiPromptFeedback?
    public let error: GeminiAPIErrorDetail?
    
    public var textResponse: String? {
        candidates?.first?.content?.parts.compactMap { $0.text }.joined()
    }
}

public struct GeminiCandidate: Codable {
    public let content: GeminiContent?
    public let finishReason: String?
}

public struct GeminiPromptFeedback: Codable {
    public let blockReason: String?
}

public struct GeminiAPIErrorDetail: Codable {
    public let code: Int?
    public let message: String?
    public let status: String?
}

// MARK: - OpenAI / OpenRouter Format (Compatibilité Universelle)
public struct OpenAIChatRequest: Codable {
    public let model: String
    public let messages: [OpenAIMessage]
    public let temperature: Double?
    public let stream: Bool?
    
    public init(model: String, messages: [OpenAIMessage], temperature: Double? = 0.8, stream: Bool? = false) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.stream = stream
    }
}

public struct OpenAIMessage: Codable {
    public let role: String
    public let content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct OpenAIChatResponse: Codable {
    public struct Choice: Codable {
        public struct Message: Codable {
            public let content: String?
        }
        public let message: Message?
        public let delta: Message?
    }
    public let choices: [Choice]?
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
            return "Clé API introuvable. Veuillez renseigner votre clé dans les Réglages."
        case .invalidURL:
            return "URL de l'API invalide."
        case .networkError(let error):
            return "Erreur réseau : \(error.localizedDescription)"
        case .badServerResponse(let code, let message):
            if message.contains("API_KEY_INVALID") || code == 400 && message.contains("key") {
                return "Clé API invalide ou expirée. Veuillez vérifier votre clé sur Google AI Studio."
            } else if message.contains("not found") || code == 404 {
                return "Modèle temporairement indisponible ou retiré par Google. Basculement automatique en cours."
            } else if code == 429 {
                return "Quota de requêtes dépassé pour cette clé. Patientez une minute ou utilisez une autre clé."
            }
            return "Erreur API [\(code)]: \(message)"
        case .decodingError(let error):
            return "Erreur de traitement des données : \(error.localizedDescription)"
        case .emptyResponse:
            return "Réponse vide reçue de l'IA."
        }
    }
}
