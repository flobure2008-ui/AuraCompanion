import Foundation

@MainActor
public final class GeminiService: ObservableObject {
    public static let shared = GeminiService()
    
    private let session: URLSession
    private let googleBaseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 45
        configuration.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: configuration)
    }
    
    /// Envoie une requête à l'IA avec gestion automatique du streaming SSE et basculement de secours
    public func streamGenerateContent(
        apiKey: String,
        provider: AIProvider = .googleGemini,
        model: GeminiModel,
        customModelName: String = "",
        customEndpoint: String = "",
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
        
        if provider == .openAICompatible {
            return try await sendOpenAICompatible(
                apiKey: apiKey,
                endpoint: customEndpoint.isEmpty ? "https://openrouter.ai/api/v1/chat/completions" : customEndpoint,
                modelName: customModelName.isEmpty ? "google/gemini-2.0-flash-001" : customModelName,
                systemInstruction: systemInstruction,
                history: history,
                userPrompt: userPrompt,
                temperature: temperature,
                onChunk: onChunk
            )
        }
        
        // Liste des modèles à essayer dans l'ordre de priorité en cas de modèle indisponible/obsolète
        let primaryModelString = (model == .custom && !customModelName.isEmpty) ? customModelName : model.rawValue
        var modelsToTry = [primaryModelString]
        if primaryModelString != GeminiModel.gemini15Flash.rawValue {
            modelsToTry.append(GeminiModel.gemini15Flash.rawValue)
        }
        if primaryModelString != GeminiModel.gemini20Flash.rawValue {
            modelsToTry.append(GeminiModel.gemini20Flash.rawValue)
        }
        if primaryModelString != GeminiModel.gemini15Pro.rawValue {
            modelsToTry.append(GeminiModel.gemini15Pro.rawValue)
        }
        
        var lastError: Error?
        
        for candidateModel in modelsToTry {
            do {
                return try await attemptStreamWithFallback(
                    apiKey: apiKey,
                    modelString: candidateModel,
                    systemInstruction: systemInstruction,
                    history: history,
                    userPrompt: userPrompt,
                    imageData: imageData,
                    temperature: temperature,
                    onChunk: onChunk
                )
            } catch {
                lastError = error
                let errorString = error.localizedDescription.lowercased()
                // Si l'erreur indique que le modèle est introuvable ou retiré, on tente le modèle suivant
                if errorString.contains("not found") || errorString.contains("404") || errorString.contains("deprecated") {
                    print("⚠️ Modèle \(candidateModel) indisponible, basculement vers le modèle suivant...")
                    continue
                } else {
                    // Erreur d'authentification ou quota : inutile de tester d'autres modèles
                    throw error
                }
            }
        }
        
        if let err = lastError {
            throw err
        }
        throw GeminiError.emptyResponse
    }
    
    // MARK: - Tentative Streaming avec repli direct generateContent
    private func attemptStreamWithFallback(
        apiKey: String,
        modelString: String,
        systemInstruction: String?,
        history: [ChatMessage],
        userPrompt: String,
        imageData: Data?,
        temperature: Double,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        // Nettoyage et assainissement strict des tours de parole
        let sanitizedContents = sanitizeContentsForGemini(
            history: history,
            currentPrompt: userPrompt,
            currentImageData: imageData
        )
        
        let systemInstr: GeminiSystemInstruction? = systemInstruction != nil ? GeminiSystemInstruction(text: systemInstruction!) : nil
        let config = GeminiGenerationConfig(temperature: temperature)
        let bodyPayload = GeminiRequest(contents: sanitizedContents, systemInstruction: systemInstr, generationConfig: config)
        
        // 1. Essai en streaming SSE
        let sseURLString = "\(googleBaseURL)/\(modelString):streamGenerateContent?alt=sse&key=\(apiKey)"
        if let url = URL(string: sseURLString) {
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONEncoder().encode(bodyPayload)
                
                let (asyncBytes, response) = try await session.bytes(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    var accumulated = ""
                    let decoder = JSONDecoder()
                    
                    for try await line in asyncBytes.lines {
                        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.hasPrefix("data: ") else { continue }
                        let jsonString = String(trimmed.dropFirst(6))
                        guard let jsonData = jsonString.data(using: .utf8) else { continue }
                        
                        if let resp = try? decoder.decode(GeminiResponse.self, from: jsonData),
                           let chunk = resp.textResponse, !chunk.isEmpty {
                            accumulated += chunk
                            onChunk(chunk)
                        }
                    }
                    
                    if !accumulated.isEmpty {
                        return accumulated
                    }
                }
            } catch {
                print("Flux SSE interrompu, passage automatique en mode direct...")
            }
        }
        
        // 2. Repli automatique en requête directe non-streamée (Ultra-robuste)
        return try await generateDirectContent(
            apiKey: apiKey,
            modelString: modelString,
            payload: bodyPayload,
            onChunk: onChunk
        )
    }
    
    // MARK: - Requête Directe sans streaming (generateContent)
    private func generateDirectContent(
        apiKey: String,
        modelString: String,
        payload: GeminiRequest,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        let directURLString = "\(googleBaseURL)/\(modelString):generateContent?key=\(apiKey)"
        guard let url = URL(string: directURLString) else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.badServerResponse(statusCode: 0, message: "Réponse invalide")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorObj = try? JSONDecoder().decode(GeminiResponse.self, from: data),
               let msg = errorObj.error?.message {
                throw GeminiError.badServerResponse(statusCode: httpResponse.statusCode, message: msg)
            }
            let rawBody = String(data: data, encoding: .utf8) ?? "Erreur HTTP \(httpResponse.statusCode)"
            throw GeminiError.badServerResponse(statusCode: httpResponse.statusCode, message: rawBody)
        }
        
        let resp = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = resp.textResponse, !text.isEmpty else {
            throw GeminiError.emptyResponse
        }
        
        onChunk(text)
        return text
    }
    
    // MARK: - Assainissement des tours de conversation pour Gemini
    /// Garantit rigoureusement que la conversation commence par 'user' et alterne 'user' <-> 'model'
    private func sanitizeContentsForGemini(
        history: [ChatMessage],
        currentPrompt: String,
        currentImageData: Data?
    ) -> [GeminiContent] {
        var rawContents: [GeminiContent] = []
        
        let recent = history.suffix(20)
        for msg in recent {
            let text = msg.content.trimmingCharacters(in: .whitespacesAndNewlines)
            let role = msg.sender == .user ? "user" : "model"
            
            var parts: [GeminiPart] = []
            if let img = msg.imageData, msg.sender == .user {
                let base64 = img.base64EncodedString()
                parts.append(GeminiPart(inlineData: GeminiInlineData(mimeType: "image/jpeg", data: base64)))
            }
            if !text.isEmpty {
                parts.append(GeminiPart(text: text))
            }
            if !parts.isEmpty {
                rawContents.append(GeminiContent(role: role, parts: parts))
            }
        }
        
        // Message utilisateur actuel
        var currentParts: [GeminiPart] = []
        if let img = currentImageData {
            let base64 = img.base64EncodedString()
            currentParts.append(GeminiPart(inlineData: GeminiInlineData(mimeType: "image/jpeg", data: base64)))
        }
        let trimmedPrompt = currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedPrompt.isEmpty || currentParts.isEmpty {
            currentParts.append(GeminiPart(text: trimmedPrompt.isEmpty ? "Bonjour !" : trimmedPrompt))
        }
        rawContents.append(GeminiContent(role: "user", parts: currentParts))
        
        // 1. RÈGLE CRUCIALE GEMINI : La conversation DOIT impérativement commencer par 'user'
        while let first = rawContents.first, first.role != "user" {
            rawContents.removeFirst()
        }
        
        // 2. RÈGLE CRUCIALE GEMINI : Alternance stricte entre 'user' et 'model'
        var sanitized: [GeminiContent] = []
        for content in rawContents {
            if let last = sanitized.last, last.role == content.role {
                let combinedParts = last.parts + content.parts
                sanitized[sanitized.count - 1] = GeminiContent(role: last.role, parts: combinedParts)
            } else {
                sanitized.append(content)
            }
        }
        
        if sanitized.isEmpty {
            sanitized.append(GeminiContent(role: "user", text: currentPrompt.isEmpty ? "Bonjour !" : currentPrompt))
        }
        
        return sanitized
    }
    
    // MARK: - Compatibilité OpenAI / OpenRouter / Groq / DeepSeek
    private func sendOpenAICompatible(
        apiKey: String,
        endpoint: String,
        modelName: String,
        systemInstruction: String?,
        history: [ChatMessage],
        userPrompt: String,
        temperature: Double,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        guard let url = URL(string: endpoint) else {
            throw GeminiError.invalidURL
        }
        
        var messages: [OpenAIMessage] = []
        if let system = systemInstruction, !system.isEmpty {
            messages.append(OpenAIMessage(role: "system", content: system))
        }
        
        for msg in history.suffix(15) {
            let role = msg.sender == .user ? "user" : "assistant"
            let text = msg.content.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                messages.append(OpenAIMessage(role: role, content: text))
            }
        }
        
        messages.append(OpenAIMessage(role: "user", content: userPrompt))
        
        let payload = OpenAIChatRequest(model: modelName, messages: messages, temperature: temperature, stream: false)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.badServerResponse(statusCode: 0, message: "Réponse invalide")
        }
        
        if httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "Erreur \(httpResponse.statusCode)"
            throw GeminiError.badServerResponse(statusCode: httpResponse.statusCode, message: body)
        }
        
        let resp = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
        guard let reply = resp.choices?.first?.message?.content, !reply.isEmpty else {
            throw GeminiError.emptyResponse
        }
        
        onChunk(reply)
        return reply
    }
    
    // MARK: - Extraction de Mémoire Robuste
    public func extractMemories(
        apiKey: String,
        message: String
    ) async -> [MemoryItem] {
        guard !apiKey.isEmpty, message.count > 15 else { return [] }
        
        let prompt = """
        Analyse ce message de l'utilisateur : "\(message)"
        Si l'utilisateur partage un fait personnel durable (son prénom, métier, goûts, passions, objectifs, anecdotes), réponds UNIQUEMENT sous forme de JSON strict :
        [
          {"category": "Profil & Faits", "key": "...", "value": "..."},
          {"category": "Goûts & Préférences", "key": "...", "value": "..."}
        ]
        Catégories autorisées : "Profil & Faits", "Goûts & Préférences", "Souvenirs Partagés", "Objectifs & Rêves".
        Si rien d'important n'est partagé, renvoie [].
        """
        
        let payload = GeminiRequest(contents: [GeminiContent(role: "user", text: prompt)])
        
        do {
            let responseText = try await generateDirectContent(
                apiKey: apiKey,
                modelString: "gemini-1.5-flash",
                payload: payload,
                onChunk: { _ in }
            )
            
            let cleanJSON = responseText
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let jsonData = cleanJSON.data(using: .utf8) else { return [] }
            
            struct RawItem: Codable {
                let category: String
                let key: String
                let value: String
            }
            
            let list = try JSONDecoder().decode([RawItem].self, from: jsonData)
            return list.map { raw in
                let cat = MemoryCategory(rawValue: raw.category) ?? .userFact
                return MemoryItem(category: cat, key: raw.key, value: raw.value)
            }
        } catch {
            return []
        }
    }
}
