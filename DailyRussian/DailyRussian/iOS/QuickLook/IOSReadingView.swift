import SwiftUI

/// iOS-adapted reading passages — list with filters, tap to read full text.
struct IOSReadingView: View {
    @State private var selectedTags: Set<String> = []
    @State private var selectedDifficulties: Set<String> = []
    @State private var searchText = ""

    // Reuse the ReadingText model from the macOS ReadingView
    private let tts = TTSProvider()

    var allTags: [String] { Array(Set(texts.map { $0.topic })).sorted() }
    var allDiffs: [String] { ["Beginner", "Intermediate", "Advanced"] }

    var filteredTexts: [ReadingText] {
        texts.filter { text in
            if !searchText.isEmpty {
                guard text.title.localizedCaseInsensitiveContains(searchText) ||
                      text.englishTitle.localizedCaseInsensitiveContains(searchText) ||
                      text.body.localizedCaseInsensitiveContains(searchText)
                else { return false }
            }
            if !selectedTags.isEmpty, !selectedTags.contains(text.topic) { return false }
            if !selectedDifficulties.isEmpty, !selectedDifficulties.contains(text.difficulty) { return false }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Topic filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(allTags, id: \.self) { tag in
                            Button {
                                if selectedTags.contains(tag) { selectedTags.remove(tag) }
                                else { selectedTags.insert(tag) }
                            } label: {
                                Text(tag).font(.caption)
                                    .padding(.horizontal, 10).padding(.vertical, 6)
                                    .background(selectedTags.contains(tag) ? topicColor(tag) : Color.gray.opacity(0.12))
                                    .foregroundStyle(selectedTags.contains(tag) ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 4)

                // Difficulty filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(allDiffs, id: \.self) { diff in
                            Button {
                                if selectedDifficulties.contains(diff) { selectedDifficulties.remove(diff) }
                                else { selectedDifficulties.insert(diff) }
                            } label: {
                                Text(diff).font(.caption2)
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(selectedDifficulties.contains(diff) ? diffColor(diff) : Color.gray.opacity(0.12))
                                    .foregroundStyle(selectedDifficulties.contains(diff) ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 4)

                // Passage list
                List {
                    ForEach(filteredTexts) { text in
                        NavigationLink {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(text.title).font(.title2).fontWeight(.bold)
                                    Text(text.englishTitle).font(.subheadline).foregroundStyle(.secondary)
                                    HStack {
                                        Text(text.topic).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(topicColor(text.topic).opacity(0.12)).clipShape(Capsule())
                                        Text(text.difficulty).font(.caption2).foregroundStyle(.secondary)
                                    }
                                    Divider()
                                    Text(text.body).font(.body).lineSpacing(6)
                                    Divider()
                                    Text("Translation").font(.headline)
                                    Text(text.translation).font(.subheadline).foregroundStyle(.secondary)
                                    if let notes = text.notes {
                                        Text("Notes").font(.headline)
                                        Text(notes).font(.caption).foregroundStyle(.orange)
                                    }
                                }
                                .padding()
                            }
                            .navigationTitle(text.title)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem {
                                    Button { tts.speak(text.body) } label: {
                                        Image(systemName: "speaker.wave.2")
                                    }
                                }
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(text.title).font(.headline)
                                Text(text.englishTitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Reading")
            .searchable(text: $searchText, prompt: "Search passages...")
        }
    }

    func topicColor(_ t: String) -> Color {
        switch t {
        case "Conversation": return .blue; case "Daily Life": return .green
        case "Food & Drink": return .orange; case "Travel": return .teal
        case "Health": return .red; case "Practical": return .purple
        case "Culture & Tech": return .indigo; case "Humour": return .yellow
        default: return .gray
        }
    }

    func diffColor(_ d: String) -> Color {
        switch d { case "Beginner": return .green; case "Intermediate": return .orange; default: return .red }
    }
}
