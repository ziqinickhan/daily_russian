import SwiftUI

/// Reading practice — text list on left, content on right.
/// Designed to live inside the parent NavigationSplitView detail pane.
struct ReadingView: View {
    @State private var selectedText: ReadingText?

    private let tts = TTSProvider()

    var body: some View {
        HStack(spacing: 0) {
            // Text list
            List(sampleTexts, selection: $selectedText) { text in
                VStack(alignment: .leading, spacing: 4) {
                    Text(text.title)
                        .font(.headline)
                    Text(text.source)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(text.difficulty)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
                .padding(.vertical, 4)
                .tag(text as ReadingText?)
            }
            .frame(width: 200)
            .listStyle(.sidebar)

            Divider()

            // Content
            if let text = selectedText {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(text.body)
                            .font(.body)
                            .lineSpacing(8)
                            .textSelection(.enabled)

                        Divider()

                        Text(text.translation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .toolbar {
                    ToolbarItem {
                        Button {
                            tts.speak(text.body)
                        } label: {
                            Image(systemName: "speaker.wave.2")
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "Select a text",
                    systemImage: "book"
                )
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Reading")
    }
}

// MARK: - Reading Text Model

struct ReadingText: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let source: String
    let difficulty: String
    let body: String
    let translation: String
}

// Sample reading texts
private let sampleTexts: [ReadingText] = [
    ReadingText(
        title: "Знакомство",
        source: "Everyday conversation",
        difficulty: "Beginner",
        body: """
        — Приве́т! Как тебя́ зову́т?
        — Меня́ зову́т А́нна. А тебя́?
        — Меня́ зову́т Макси́м. О́чень прия́тно.
        — Взаи́мно. Отку́да ты?
        — Я из Москвы́. А ты?
        — Я из Санкт-Петербу́рга.
        """,
        translation: """
        "Hello! What's your name?"
        "My name is Anna. And yours?"
        "My name is Maxim. Nice to meet you."
        "Likewise. Where are you from?"
        "I'm from Moscow. And you?"
        "I'm from Saint Petersburg."
        """
    ),
    ReadingText(
        title: "В кафе́",
        source: "Everyday conversation",
        difficulty: "Beginner",
        body: """
        — Что вы бу́дете зака́зывать?
        — Мне, пожа́луйста, ко́фе с молоко́м и круасса́н.
        — Хорошо́. Что-нибу́дь ещё?
        — Нет, спаси́бо. Ско́лько с меня́?
        — 450 рубле́й.
        """,
        translation: """
        "What would you like to order?"
        "I'll have a coffee with milk and a croissant, please."
        "Okay. Anything else?"
        "No, thank you. How much do I owe?"
        "450 rubles."
        """
    )
]
