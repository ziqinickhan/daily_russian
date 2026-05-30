import SwiftUI

/// AI-powered grammar help (Deepseek API). On-demand only — user must explicitly ask.
struct AIChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var isAvailable = false  // Set to true when API key configured

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if messages.isEmpty {
                        ContentUnavailableView(
                            "Ask me about Russian!",
                            systemImage: "bubble.left.and.text.bubble.right",
                            description: Text("Type a question about grammar, cases, or usage.")
                        )
                        .padding(.top, 40)
                    }

                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding()
            }

            Divider()

            // Input bar
            HStack(spacing: 8) {
                TextField("Ask about Russian grammar...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(!isAvailable || isLoading)
                    .onSubmit { sendMessage() }

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(inputText.isEmpty || isLoading || !isAvailable)
            }
            .padding()
        }
        .navigationTitle("AI Tutor")
        .toolbar {
            if !isAvailable {
                ToolbarItem {
                    Label("API not configured", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    private func sendMessage() {
        let question = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: question)
        messages.append(userMessage)
        inputText = ""

        // Placeholder — will be replaced with Deepseek API call
        Task {
            isLoading = true
            defer { isLoading = false }

            let response = ChatMessage(
                role: .assistant,
                content: "This is a placeholder. The Deepseek API will be integrated here. Your question was: \"\(question)\""
            )
            messages.append(response)
        }
    }
}

// MARK: - Chat Types

struct ChatMessage: Identifiable {
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

            Text(message.content)
                .padding(12)
                .background(message.role == .user ? Color.blue : Color(.controlBackgroundColor))
                .foregroundStyle(message.role == .user ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: 300, alignment: message.role == .user ? .trailing : .leading)

            if message.role == .assistant { Spacer() }
        }
    }
}
