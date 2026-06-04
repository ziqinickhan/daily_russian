import SwiftUI

/// AI-powered grammar help via Deepseek API. On-demand only.
struct AIChatView: View {
    @StateObject private var ai = DeepseekService()
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 0) {
            // Messages area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if messages.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.text.bubble.right")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                                Text("Ask me about Russian!")
                                    .font(.title3)
                                Text("Grammar, cases, verb aspects, usage — I'll explain with examples.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)

                                VStack(alignment: .leading, spacing: 6) {
                                    SuggestionChip("What's the difference between идти and ходить?") {
                                        sendMessage($0)
                                    }
                                    SuggestionChip("Explain when to use genitive case") {
                                        sendMessage($0)
                                    }
                                    SuggestionChip("Give me example sentences with verbs of motion") {
                                        sendMessage($0)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 32)
                        }

                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }

                        if isLoading {
                            HStack {
                                ProgressView()
                                    .padding()
                                Text("Thinking...")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let error = errorText {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            // Input bar
            HStack(spacing: 8) {
                TextField("Ask about Russian grammar...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isLoading)
                    .onSubmit { sendMessage(inputText) }

                Button {
                    sendMessage(inputText)
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("AI Tutor")
    }

    private func sendMessage(_ text: String) {
        let question = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: question)
        messages.append(userMessage)
        inputText = ""
        errorText = nil

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let history = messages.dropLast().suffix(6).map {
                    DeepseekService.Message(role: $0.role == .user ? "user" : "assistant", content: $0.content)
                }
                let response = try await ai.chat(userMessage: question, history: history)
                let assistantMessage = ChatMessage(role: .assistant, content: response)
                messages.append(assistantMessage)
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
}

// MARK: - Suggestion Chips

struct SuggestionChip: View {
    let text: String
    let action: (String) -> Void

    init(_ text: String, action: @escaping (String) -> Void) {
        self.text = text
        self.action = action
    }

    var body: some View {
        Button {
            action(text)
        } label: {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.quaternary, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chat Types

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let role: Role
    let content: String

    enum Role {
        case user, assistant
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer() }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.role == .user ? Color.accentColor : Color(.controlBackgroundColor))
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .textSelection(.enabled)
            }
            .frame(maxWidth: 500, alignment: message.role == .user ? .trailing : .leading)

            if message.role == .assistant { Spacer() }
        }
    }
}
