import Foundation

// MARK: - Gemini Supported Models
public enum GeminiModel: String, CaseIterable, Identifiable, Codable {
    case gemini15Flash = "gemini-1.5-flash"
    case gemini15Pro = "gemini-1.5-pro"
    case gemini20Flash = "gemini-2.0-flash-exp"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .gemini15Flash:
            return "Gemini 1.5 Flash (Ultra-rapide & Efficace)"
        case .gemini15Pro:
            return "Gemini 1.5 Pro (Raisonnement Complexe & Profond)"
        case .gemini20Flash:
            return "Gemini 2.0 Flash (Nouvelle Génération Multimodale)"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .gemini15Flash:
            return "Idéal pour le chat quotidien, vocal fluide et temps de réponse instantanés."
        case .gemini15Pro:
            return "Idéal pour la réflexion philosophique, le codage, l'analyse d'images poussée."
        case .gemini20Flash:
            return "Dernière technologie expérimentale ultra-réactive de Google."
        }
    }
}

// MARK: - API Request Payloads
public struct GeminiRequest: Codable {
    public let contents: [GeminiContent]
    public let systemInstruction: GeminiSystemInstruction?
    public let generationConfig: GeminiGenerationConfig?
    
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
    public let data: String // Base64 encoded string
    
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
            return "Clé API Gemini introuvable. Veuillez renseigner votre clé dans les Réglages."
        case .invalidURL:
            return "URL de l'API Gemini invalide."
        case .networkError(let error):
            return "Erreur réseau : \(error.localizedDescription)"
        case .badServerResponse(let code, let message):
            return "Erreur Gemini [\(code)]: \(message)"
        case .decodingError(let error):
            return "Erreur de décodage des données : \(error.localizedDescription)"
        case .emptyResponse:
            return "Réponse vide reçue de Gemini."
        }
    }
}
