import Foundation

@MainActor
public final class GeminiService: ObservableObject {
    public static let shared = GeminiService()
    
    private let session: URLSession
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }
    
    /// Envoie une requête à Gemini en streaming SSE (Server-Sent Events)
    public func streamGenerateContent(
        apiKey: String,
        model: GeminiModel,
        systemInstruction: String?,
        history: [ChatMessage],
        userPrompt: String,
        imageData: Data? = nil,
        temperature: Double = 0.8,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        let urlString = "\(baseURL)/\(model.rawValue):streamGenerateContent?alt=sse&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construction des contenus
        var contents: [GeminiContent] = []
        
        // Inclure l'historique récent (limité aux 20 derniers messages pour respecter la fenêtre de contexte optimale)
        let recentHistory = history.suffix(20)
        for msg in recentHistory {
            let role = msg.sender == .user ? "user" : "model"
            if let img = msg.imageData, msg.sender == .user {
                let base64 = img.base64EncodedString()
                let inline = GeminiInlineData(mimeType: "image/jpeg", data: base64)
                let parts: [GeminiPart] = [
                    GeminiPart(inlineData: inline),
                    GeminiPart(text: msg.content)
                ]
                contents.append(GeminiContent(role: role, parts: parts))
            } else {
                contents.append(GeminiContent(role: role, text: msg.content))
            }
        }
        
        // Nouveau message utilisateur actuel
        var currentParts: [GeminiPart] = []
        if let currentImg = imageData {
            let base64 = currentImg.base64EncodedString()
            let inline = GeminiInlineData(mimeType: "image/jpeg", data: base64)
            currentParts.append(GeminiPart(inlineData: inline))
        }
        currentParts.append(GeminiPart(text: userPrompt))
        contents.append(GeminiContent(role: "user", parts: currentParts))
        
        let systemInstr: GeminiSystemInstruction? = systemInstruction != nil ? GeminiSystemInstruction(text: systemInstruction!) : nil
        let config = GeminiGenerationConfig(temperature: temperature)
        let bodyPayload = GeminiRequest(contents: contents, systemInstruction: systemInstr, generationConfig: config)
        
        request.httpBody = try JSONEncoder().encode(bodyPayload)
        
        // Streaming via URLSession.bytes
        let (asyncBytes, response) = try await session.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.badServerResponse(statusCode: 0, message: "Réponse invalide du serveur")
        }
        
        if httpResponse.statusCode != 200 {
            var errorBody = ""
            for try await line in asyncBytes.lines {
                errorBody += line
            }
            throw GeminiError.badServerResponse(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        var accumulatedFullText = ""
        let decoder = JSONDecoder()
        
        for try await line in asyncBytes.lines {
            // Dans le format SSE, chaque événement commence par "data: "
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.hasPrefix("data: ") else { continue }
            
            let jsonString = String(trimmed.dropFirst(6))
            guard let jsonData = jsonString.data(using: .utf8) else { continue }
            
            if let geminiResp = try? decoder.decode(GeminiResponse.self, from: jsonData),
               let chunkText = geminiResp.textResponse, !chunkText.isEmpty {
                accumulatedFullText += chunkText
                onChunk(chunkText)
            }
        }
        
        if accumulatedFullText.isEmpty {
            throw GeminiError.emptyResponse
        }
        
        return accumulatedFullText
    }
    
    /// Analyse un message pour détecter les faits et souvenirs clés à mémoriser
    public func extractMemories(
        apiKey: String,
        message: String
    ) async -> [MemoryItem] {
        guard !apiKey.isEmpty, message.count > 15 else { return [] }
        
        let extractionPrompt = """
        Analyse ce message de l'utilisateur : "\(message)"
        Y a-t-il des informations personnelles durables, goûts, objectifs, prénoms de proches ou secrets révélés ?
        Si oui, réponds UNIQUEMENT sous forme de JSON strict avec cette structure :
        [
          {"category": "Profil & Faits", "key": "...", "value": "..."},
          {"category": "Goûts & Préférences", "key": "...", "value": "..."}
        ]
        Catégories possibles : "Profil & Faits", "Goûts & Préférences", "Souvenirs Partagés", "Objectifs & Rêves".
        Si rien de personnel n'est révélé, renvoie simplement []. Aucun autre texte ou explication.
        """
        
        do {
            let urlString = "\(baseURL)/gemini-1.5-flash:generateContent?key=\(apiKey)"
            guard let url = URL(string: urlString) else { return [] }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let payload = GeminiRequest(contents: [GeminiContent(role: "user", text: extractionPrompt)])
            request.httpBody = try JSONEncoder().encode(payload)
            
            let (data, _) = try await session.data(for: request)
            let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            guard let jsonText = response.textResponse?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return []
            }
            
            // Nettoyage markdown éventuel
            let cleanJSON = jsonText
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let cleanData = cleanJSON.data(using: .utf8) else { return [] }
            
            struct RawMemory: Codable {
                let category: String
                let key: String
                let value: String
            }
            
            let rawList = try JSONDecoder().decode([RawMemory].self, from: cleanData)
            return rawList.map { raw in
                let cat = MemoryCategory(rawValue: raw.category) ?? .userFact
                return MemoryItem(category: cat, key: raw.key, value: raw.value)
            }
        } catch {
            return []
        }
    }
}
