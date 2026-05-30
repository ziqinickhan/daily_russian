import Foundation
import OSLog

/// Client for the Deepseek API — on-demand grammar explanations and example generation.
/// Uses the chat completions endpoint. Handles VPN/offline gracefully.
actor DeepseekService {
    private let apiKey: String
    private let baseURL = "https://api.deepseek.com/v1"
    private let logger = Logger(subsystem: "com.nickhan.DailyRussian", category: "Deepseek")

    /// The system prompt that steers the model toward Russian teaching.
    private let systemPrompt = """
    You are a knowledgeable Russian language tutor. Your student is an intermediate learner:
    - They know Cyrillic, basic vocabulary, and simple grammar.
    - They struggle with cases, verb aspects, and real-world usage.

    Rules:
    1. Answer in English (unless the student asks in Russian).
    2. Keep explanations concise — 2-3 paragraphs max unless asked for detail.
    3. Always provide 2-3 example sentences in Russian with translations.
    4. Mark stress with an acute accent (e.g., приве́т, говори́ть).
    5. When explaining grammar, mention the relevant case/aspect clearly.
    6. Be encouraging but direct — don't over-praise.
    7. If asked for vocabulary, include part of speech and difficulty level.
    """

    struct Message: Codable {
        let role: String
        let content: String
    }

    struct ChatRequest: Codable {
        let model: String
        let messages: [Message]
        let max_tokens: Int
        let temperature: Double
    }

    struct Choice: Codable {
        let message: Message
    }

    struct ChatResponse: Codable {
        let choices: [Choice]
        let usage: Usage?

        struct Usage: Codable {
            let total_tokens: Int
        }
    }

    struct Conversation {
        var messages: [Message] = []
    }

    init() {
        // Load API key from config file in the app bundle
        if let url = Bundle.main.url(forResource: "deepseek_config", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
           let key = json["api_key"], !key.isEmpty {
            self.apiKey = key
        } else {
            self.apiKey = ""
            logger.warning("Deepseek API key not found — AI features disabled")
        }
    }

    var isAvailable: Bool { !apiKey.isEmpty }

    /// Send a message and get a streaming-like response.
    func chat(userMessage: String, history: [Message] = []) async throws -> String {
        guard isAvailable else {
            throw ServiceError.unavailable
        }

        var messages: [Message] = [
            Message(role: "system", content: systemPrompt)
        ]
        messages.append(contentsOf: history)
        messages.append(Message(role: "user", content: userMessage))

        let request = ChatRequest(
            model: "deepseek-chat",
            messages: messages,
            max_tokens: 800,
            temperature: 0.7
        )

        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw ServiceError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        urlRequest.timeoutInterval = 30

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServiceError.badResponse
            }

            if httpResponse.statusCode == 401 {
                throw ServiceError.invalidKey
            }

            if httpResponse.statusCode != 200 {
                let body = String(data: data, encoding: .utf8) ?? ""
                logger.error("Deepseek API error \(httpResponse.statusCode): \(body)")
                throw ServiceError.httpError(httpResponse.statusCode)
            }

            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            guard let content = decoded.choices.first?.message.content else {
                throw ServiceError.emptyResponse
            }
            return content

        } catch let error as ServiceError {
            throw error
        } catch {
            // Network errors (offline, VPN off, GFW block) → graceful
            logger.error("Deepseek network error: \(error.localizedDescription)")
            throw ServiceError.networkError(error.localizedDescription)
        }
    }
}

// MARK: - Errors

extension DeepseekService {
    enum ServiceError: LocalizedError {
        case unavailable
        case invalidURL
        case badResponse
        case invalidKey
        case httpError(Int)
        case emptyResponse
        case networkError(String)

        var errorDescription: String? {
            switch self {
            case .unavailable: return "AI tutor is not configured."
            case .invalidURL: return "Invalid API URL."
            case .badResponse: return "Unexpected server response."
            case .invalidKey: return "API key is invalid."
            case .httpError(let code): return "Server error (HTTP \(code))."
            case .emptyResponse: return "Empty response from AI."
            case .networkError(let msg): return "Network error: \(msg)"
            }
        }
    }
}
