import SwiftUI

/// iOS-adapted news — list with topic filter, tap to read full story.
struct IOSNewsView: View {
    @State private var selectedTags: Set<String> = []
    @State private var searchText = ""

    private let tts = TTSProvider()

    var allTopics: [String] { Array(Set(stories.map { $0.topic })).sorted() }

    var filteredStories: [NewsStory] {
        stories.filter { story in
            if !searchText.isEmpty {
                guard story.headline.localizedCaseInsensitiveContains(searchText) ||
                      story.englishHeadline.localizedCaseInsensitiveContains(searchText)
                else { return false }
            }
            if !selectedTags.isEmpty, !selectedTags.contains(story.topic) { return false }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Topic filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(allTopics, id: \.self) { topic in
                            Button {
                                if selectedTags.contains(topic) { selectedTags.remove(topic) }
                                else { selectedTags.insert(topic) }
                            } label: {
                                Text(topic).font(.caption)
                                    .padding(.horizontal, 10).padding(.vertical, 6)
                                    .background(selectedTags.contains(topic) ? newsColor(topic) : Color.gray.opacity(0.12))
                                    .foregroundStyle(selectedTags.contains(topic) ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                // Story list
                List {
                    ForEach(filteredStories) { story in
                        NavigationLink {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(story.headline).font(.title2).fontWeight(.bold)
                                    Text(story.englishHeadline).font(.subheadline).foregroundStyle(.secondary)
                                    Text(story.topic).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(newsColor(story.topic).opacity(0.12)).clipShape(Capsule())
                                    Divider()
                                    Text(story.body).font(.body).lineSpacing(6)
                                    Divider()
                                    Text("Key Vocabulary").font(.headline)
                                    ForEach(story.vocabulary, id: \.word) { item in
                                        HStack {
                                            Text(item.word).font(.caption).fontWeight(.medium)
                                            Text("—").foregroundStyle(.secondary)
                                            Text(item.translation).font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                    Divider()
                                    Text("Translation").font(.headline)
                                    Text(story.translation).font(.subheadline).foregroundStyle(.secondary)
                                }
                                .padding()
                            }
                            .navigationTitle(story.headline)
                            #if os(iOS)
                            .navigationBarTitleDisplayMode(.inline)
                            #endif
                            .toolbar {
                                ToolbarItem {
                                    Button { tts.speak(story.body) } label: {
                                        Image(systemName: "speaker.wave.2")
                                    }
                                }
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(story.headline).font(.headline).lineLimit(2)
                                Text(story.englishHeadline).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("News")
            .searchable(text: $searchText, prompt: "Search stories...")
        }
    }

    func newsColor(_ t: String) -> Color {
        switch t {
        case "Culture": return .purple; case "Sports": return .green
        case "Weather": return .cyan; case "City Life": return .teal
        case "Tech": return .blue; case "Science": return .indigo
        default: return .gray
        }
    }
}
