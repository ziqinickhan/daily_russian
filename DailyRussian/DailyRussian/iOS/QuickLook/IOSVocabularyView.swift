import SwiftUI
import CoreData

/// iOS-adapted vocabulary browser — list with search, tag filter, detail push.
struct IOSVocabularyView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordEntry.difficulty, ascending: true),
            NSSortDescriptor(keyPath: \WordEntry.word, ascending: true)
        ],
        animation: .default
    )
    private var words: FetchedResults<WordEntry>

    @State private var searchText = ""
    @State private var selectedTag: String? = nil

    private let tts = TTSProvider()

    var filteredWords: [WordEntry] {
        var result = Array(words)
        if !searchText.isEmpty {
            result = result.filter {
                ($0.word ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.translation ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        if let tag = selectedTag, tag != "All" {
            result = result.filter { tagFor($0) == tag }
        }
        return result
    }

    var tags: [(String, Int)] {
        var counts: [String: Int] = [:]
        for w in words { counts[tagFor(w), default: 0] += 1 }
        return [("All", words.count)] + counts.sorted(by: { $0.0 < $1.0 }).map { ($0.0, $0.1) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tag filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.0) { tag, count in
                            Button {
                                selectedTag = (tag == "All") ? nil : tag
                            } label: {
                                HStack(spacing: 3) {
                                    Text(tag).font(.caption)
                                    Text("\(count)").font(.caption2).foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(
                                    (selectedTag == tag || (tag == "All" && selectedTag == nil))
                                    ? Color.accentColor : Color.gray.opacity(0.12)
                                )
                                .foregroundStyle(
                                    (selectedTag == tag || (tag == "All" && selectedTag == nil))
                                    ? .white : .primary
                                )
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                // Word list
                List {
                    ForEach(filteredWords, id: \.id) { word in
                        NavigationLink {
                            WordDetailView(word: word, tts: tts)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(word.word ?? "").font(.headline)
                                    Text(word.translation ?? "").font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if word.isLearned {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.caption)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Words")
            .searchable(text: $searchText, prompt: "Search vocabulary...")
        }
    }

    func tagFor(_ word: WordEntry) -> String {
        guard let pos = word.partOfSpeech else { return "?" }
        if pos.hasPrefix("noun") { return "noun" }
        if pos.hasPrefix("verb") { return "verb" }
        if pos.hasPrefix("adjective") || pos.hasPrefix("adj") { return "adjective" }
        if pos.hasPrefix("adverb") || pos.hasPrefix("adv") { return "adverb" }
        if pos.hasPrefix("preposition") { return "preposition" }
        if pos.hasPrefix("pronoun") { return "pronoun" }
        if pos.hasPrefix("number") { return "number" }
        if pos == "greeting" || pos == "expression" || pos == "phrase" || pos == "particle" { return "expression" }
        return pos
    }
}
