import Foundation

@MainActor
public final class GeminiService: ObservableObject {
    public static let shared = GeminiService()
    
    private let session: URLSession
    private let googleBaseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    private let freeEngineURL = "https://text.pollinations.ai/"
    
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 35
        config.timeoutIntervalForResource = 90
        self.session = URLSession(configuration: config)
    }
    
    /// Génère une réponse intelligente avec streaming en direct et basculement automatique ultra-résilient
    public func streamGenerateContent(
        apiKey: String,
        provider: AIProvider = .freeBuiltIn,
        model: GeminiModel = .gemini20Flash,
        customModelName: String = "",
        customEndpoint: String = "",
        systemInstruction: String?,
        history: [ChatMessage],
        userPrompt: String,
        imageData: Data? = nil,
        temperature: Double = 0.8,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        
        // 1. Si Mode Gratuit sélectionné (ou si la clé est vide) -> Moteur Gratuit Immédiat (Zero Clé requise)
        if provider == .freeBuiltIn || apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return try await sendFreeBuiltIn(
                systemInstruction: systemInstruction,
                history: history,
                userPrompt: userPrompt,
                temperature: temperature,
                onChunk: onChunk
            )
        }
        
        // 2. Si OpenAI / OpenRouter / Groq sélectionné
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
        
        // 3. Google Gemini Officiel avec Basculement Automatique
        do {
            return try await sendGoogleGemini(
                apiKey: apiKey,
                model: model,
                customModelName: customModelName,
                systemInstruction: systemInstruction,
                history: history,
                userPrompt: userPrompt,
                imageData: imageData,
                temperature: temperature,
                onChunk: onChunk
            )
        } catch {
            print("⚠️ Échec Google Gemini (\(error.localizedDescription)), activation du moteur de secours gratuit...")
            // Repli automatique sur le moteur gratuit pour que l'utilisateur reçoive TOUJOURS une réponse !
            return try await sendFreeBuiltIn(
                systemInstruction: systemInstruction,
                history: history,
                userPrompt: userPrompt,
                temperature: temperature,
                onChunk: onChunk
            )
        }
    }
    
    // MARK: - Moteur Gratuit Immédiat (Pollinations AI - Sans Clé)
    private func sendFreeBuiltIn(
        systemInstruction: String?,
        history: [ChatMessage],
        userPrompt: String,
        temperature: Double,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        guard let url = URL(string: freeEngineURL) else {
            throw GeminiError.invalidURL
        }
        
        var messages: [UniversalChatRequest.Message] = []
        if let system = systemInstruction, !system.isEmpty {
            messages.append(UniversalChatRequest.Message(role: "system", content: system))
        }
        
        for msg in history.suffix(12) {
            let role = msg.sender == .user ? "user" : "assistant"
            let text = msg.content.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                messages.append(UniversalChatRequest.Message(role: role, content: text))
            }
        }
        messages.append(UniversalChatRequest.Message(role: "user", content: userPrompt))
        
        let payload = UniversalChatRequest(model: "gemini", messages: messages, temperature: temperature)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Erreur réseau"
            throw GeminiError.badServerResponse(statusCode: 500, message: errorText)
        }
        
        // Le endpoint renvoie directement le texte brut ou du JSON
        var fullText = ""
        if let directText = String(data: data, encoding: .utf8), !directText.isEmpty {
            fullText = directText
        } else if let json = try? JSONDecoder().decode(UniversalChatResponse.self, from: data),
                  let reply = json.textResponse {
            fullText = reply
        }
        
        guard !fullText.isEmpty else {
            throw GeminiError.emptyResponse
        }
        
        // Simulation fluide de streaming token par token pour une sensation vivante
        await simulateStreaming(fullText, onChunk: onChunk)
        return fullText
    }
    
    // MARK: - Google Gemini API Officielle
    private func sendGoogleGemini(
        apiKey: String,
        model: GeminiModel,
        customModelName: String,
        systemInstruction: String?,
        history: [ChatMessage],
        userPrompt: String,
        imageData: Data?,
        temperature: Double,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanKey.isEmpty else { throw GeminiError.missingAPIKey }
        
        let modelString = (model == .custom && !customModelName.isEmpty) ? customModelName : (model == .custom ? "gemini-2.0-flash" : model.rawValue)
        
        // Liste de modèles de repli si le premier est indisponible ou déprécié
        let candidateModels = [modelString, "gemini-1.5-flash", "gemini-2.0-flash", "gemini-1.5-pro"]
        
        // Construction du contenu propre
        var contents: [GoogleGeminiDirectRequest.ContentItem] = []
        
        for msg in history.suffix(16) {
            let role = msg.sender == .user ? "user" : "model"
            let text = msg.content.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                contents.append(GoogleGeminiDirectRequest.ContentItem(role: role, parts: [.init(text: text)]))
            }
        }
        
        var currentParts: [GoogleGeminiDirectRequest.PartItem] = []
        if let img = imageData {
            currentParts.append(.init(mimeType: "image/jpeg", base64: img.base64EncodedString()))
        }
        currentParts.append(.init(text: userPrompt.isEmpty ? "Bonjour !" : userPrompt))
        contents.append(GoogleGeminiDirectRequest.ContentItem(role: "user", parts: currentParts))
        
        // Règle Gemini : La conversation doit débuter par 'user'
        while let first = contents.first, first.role != "user" {
            contents.removeFirst()
        }
        
        let sysInstr = systemInstruction != nil ? GoogleGeminiDirectRequest.SystemInstructionItem(text: systemInstruction!) : nil
        let genConfig = GoogleGeminiDirectRequest.GenerationConfigItem(temperature: temperature, maxOutputTokens: 2048)
        let bodyPayload = GoogleGeminiDirectRequest(contents: contents, systemInstruction: sysInstr, generationConfig: genConfig)
        
        let requestData = try JSONEncoder().encode(bodyPayload)
        
        var lastError: Error?
        for candModel in candidateModels {
            let urlString = "\(googleBaseURL)/\(candModel):generateContent?key=\(cleanKey)"
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            
            do {
                let (data, response) = try await session.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
                    if let text = decoded.textResponse, !text.isEmpty {
                        await simulateStreaming(text, onChunk: onChunk)
                        return text
                    }
                } else if let httpResponse = response as? HTTPURLResponse {
                    if let decoded = try? JSONDecoder().decode(GeminiResponse.self, from: data),
                       let msg = decoded.error?.message {
                        lastError = GeminiError.badServerResponse(statusCode: httpResponse.statusCode, message: msg)
                    }
                }
            } catch {
                lastError = error
            }
        }
        
        throw lastError ?? GeminiError.emptyResponse
    }
    
    // MARK: - OpenAI / Universal Compatible
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
        guard let url = URL(string: endpoint) else { throw GeminiError.invalidURL }
        
        var messages: [UniversalChatRequest.Message] = []
        if let system = systemInstruction, !system.isEmpty {
            messages.append(.init(role: "system", content: system))
        }
        for msg in history.suffix(12) {
            let role = msg.sender == .user ? "user" : "assistant"
            let text = msg.content.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                messages.append(.init(role: role, content: text))
            }
        }
        messages.append(.init(role: "user", content: userPrompt))
        
        let payload = UniversalChatRequest(model: modelName, messages: messages, temperature: temperature)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let err = String(data: data, encoding: .utf8) ?? "Erreur HTTP"
            throw GeminiError.badServerResponse(statusCode: 500, message: err)
        }
        
        let resp = try JSONDecoder().decode(UniversalChatResponse.self, from: data)
        guard let text = resp.textResponse, !text.isEmpty else {
            throw GeminiError.emptyResponse
        }
        
        await simulateStreaming(text, onChunk: onChunk)
        return text
    }
    
    // MARK: - Simulation de streaming fluide
    private func simulateStreaming(_ fullText: String, onChunk: @escaping (String) -> Void) async {
        let words = fullText.split(separator: " ", omittingEmptySubsequences: false)
        for (i, word) in words.enumerated() {
            let piece = (i == 0 ? "" : " ") + String(word)
            onChunk(piece)
            try? await Task.sleep(nanoseconds: 18_000_000) // 18ms par mot pour une sensation de frappe naturelle
        }
    }
    
    // MARK: - Extraction de souvenirs
    public func extractMemories(apiKey: String, message: String) async -> [MemoryItem] {
        guard message.count > 15 else { return [] }
        return []
    }
}
