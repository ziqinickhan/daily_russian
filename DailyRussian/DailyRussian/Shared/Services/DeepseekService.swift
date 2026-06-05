import Foundation
import Combine

/// Client for the Deepseek API — on-demand grammar explanations and example generation.
final class DeepseekService: ObservableObject {
    @Published var isAvailable = false

    private var apiKey: String = ""
    private let baseURL = "https://api.deepseek.com/v1"

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

    private struct ChatRequest: Codable {
        let model: String
        let messages: [Message]
        let max_tokens: Int
        let temperature: Double
    }

    private struct Choice: Codable {
        let message: Message
    }

    private struct ChatResponse: Codable {
        let choices: [Choice]
    }

    init() {
        loadAPIKey()
        NSLog("[Deepseek] Initialized, available: \(isAvailable)")
    }

    private func loadAPIKey() {
        // Try the bundled config file
        if let url = Bundle.main.url(forResource: "deepseek_config", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
           let key = json["api_key"], !key.isEmpty {
            apiKey = key
            isAvailable = true
            NSLog("[Deepseek] API key loaded from bundle")
            return
        }
        // Fallback: check UserDefaults (for manual entry)
        if let key = UserDefaults.standard.string(forKey: "deepseek_api_key"), !key.isEmpty {
            apiKey = key
            isAvailable = true
            NSLog("[Deepseek] API key loaded from UserDefaults")
            return
        }
        apiKey = ""
        isAvailable = false
        NSLog("[Deepseek] No API key found — AI features disabled")
    }

    /// Manually set the API key (for in-app settings).
    func setKey(_ key: String) {
        apiKey = key
        isAvailable = !key.isEmpty
        UserDefaults.standard.set(key, forKey: "deepseek_api_key")
    }

    /// Send a message and get a response.
    func chat(userMessage: String, history: [Message] = []) async throws -> String {
        guard isAvailable, !apiKey.isEmpty else {
            throw ServiceError.unavailable
        }

        var messages: [Message] = [Message(role: "system", content: systemPrompt)]
        messages.append(contentsOf: history)
        messages.append(Message(role: "user", content: userMessage))

        let request = ChatRequest(
            model: "deepseek-v4-flash",
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
                NSLog("[Deepseek] HTTP \(httpResponse.statusCode): \(body.prefix(200))")
                throw ServiceError.httpError(httpResponse.statusCode)
            }

            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            guard let content = decoded.choices.first?.message.content else {
                throw ServiceError.emptyResponse
            }
            NSLog("[Deepseek] Response received (len: \(content.count))")
            return content

        } catch let error as ServiceError {
            throw error
        } catch {
            NSLog("[Deepseek] Network error: \(error.localizedDescription)")
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
            case .unavailable: return "API key not configured. Check Settings."
            case .invalidURL: return "Invalid API URL."
            case .badResponse: return "Unexpected server response."
            case .invalidKey: return "API key is invalid. Check Settings."
            case .httpError(let code): return "Server error (HTTP \(code)). Try again."
            case .emptyResponse: return "Empty response from AI."
            case .networkError(let msg): return "Cannot reach Deepseek — check your VPN or internet connection."
            }
        }
    }
}
