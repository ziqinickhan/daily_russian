import SwiftUI
import CoreData

/// Interactive vocabulary browser.
/// - Click any word → meaning + pronunciation in one click
/// - Filter by tag (noun, verb, adjective, etc.)
/// - Shows case declensions when available
struct VocabularyView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordEntry.difficulty, ascending: true),
            NSSortDescriptor(keyPath: \WordEntry.word, ascending: true)
        ],
        animation: .default
    )
    private var words: FetchedResults<WordEntry>

    @State private var selectedWord: WordEntry?
    @State private var searchText = ""
    @State private var selectedTag: String? = nil

    private let tts = TTSProvider()

    // MARK: - Tags derived from partOfSpeech

    var tags: [String] {
        var set = Set<String>()
        for w in words {
            let tag = tagFor(w)
            if !tag.isEmpty { set.insert(tag) }
        }
        return ["All"] + Array(set).sorted()
    }

    func tagFor(_ word: WordEntry) -> String {
        guard let pos = word.partOfSpeech else { return "" }
        // Extract broad category from partOfSpeech
        if pos.hasPrefix("noun") { return "noun" }
        if pos.hasPrefix("verb") { return "verb" }
        if pos.hasPrefix("adjective") || pos.hasPrefix("adj") { return "adjective" }
        if pos.hasPrefix("adverb") || pos.hasPrefix("adv") { return "adverb" }
        if pos.hasPrefix("preposition") || pos.hasPrefix("prep") { return "preposition" }
        if pos.hasPrefix("pronoun") || pos.hasPrefix("pron") { return "pronoun" }
        if pos.hasPrefix("number") { return "number" }
        if pos == "greeting" || pos == "expression" || pos == "phrase" || pos == "particle" { return "expression" }
        return pos
    }

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

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            // Tag sidebar
            tagSidebar

            Divider()

            // Word list
            wordList

            Divider()

            // Detail panel
            detailPanel
        }
        .navigationTitle("Vocabulary")
    }

    // MARK: - Tag Sidebar

    private var tagSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Search...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(8)

            Divider()

            List(tags, id: \.self, selection: $selectedTag) { tag in
                HStack {
                    Text(tag)
                        .font(.callout)
                    Spacer()
                    if tag == "All" {
                        Text("\(words.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(words.filter { tagFor($0) == tag }.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
                .tag(tag as String?)
            }
            .listStyle(.sidebar)
        }
        .frame(width: 150)
    }

    // MARK: - Word List

    private var wordList: some View {
        Group {
            if filteredWords.isEmpty {
                ContentUnavailableView(
                    "No words",
                    systemImage: "magnifyingglass",
                    description: Text(searchText.isEmpty ? "Seed data may not have loaded." : "Try a different search.")
                )
            } else {
                List(filteredWords, selection: $selectedWord) { word in
                    wordRow(word)
                        .tag(word as WordEntry?)
                }
                .listStyle(.inset)
            }
        }
        .frame(width: 250)
    }

    private func wordRow(_ word: WordEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(word.word ?? "")
                    .font(.headline)
                Text(word.translation ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if word.isLearned {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }

            if let nextReview = word.nextReview, nextReview <= Date() {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }

            Button {
                tts.speak(word.word ?? "")
            } label: {
                Image(systemName: "speaker.wave.2")
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 1)
    }

    // MARK: - Detail Panel

    @ViewBuilder
    private var detailPanel: some View {
        if let word = selectedWord {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Word + pronunciation
                    HStack {
                        Text(word.word ?? "")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Button {
                            tts.speak(word.word ?? "")
                        } label: {
                            Image(systemName: "speaker.wave.2.circle.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }

                    // Translation — always visible
                    Text(word.translation ?? "")
                        .font(.title3)
                        .foregroundStyle(.primary)

                    // Part of speech
                    if let pos = word.partOfSpeech {
                        HStack(spacing: 8) {
                            Text(tagFor(word))
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.blue.opacity(0.1), in: Capsule())
                            Text(pos)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Note
                    if let note = word.note {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                            Text(note)
                                .font(.caption)
                        }
                        .foregroundStyle(.orange)
                    }

                    // Case forms
                    if let caseJSON = word.caseForms,
                       let data = caseJSON.data(using: .utf8),
                       let cases = try? JSONDecoder().decode([String: String].self, from: data),
                       !cases.isEmpty {
                        Divider()
                        Text("Case Forms")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(caseKeys.sorted(), id: \.self) { key in
                                if let form = cases[key] {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(caseLabel(key))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(form)
                                            .font(.callout)
                                            .fontWeight(.medium)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }

                    // Spaced repetition stats
                    if word.reviewCount > 0 {
                        Divider()
                        Text("Review Stats")
                            .font(.headline)
                        HStack(spacing: 16) {
                            Label("Reviews: \(word.reviewCount)", systemImage: "arrow.triangle.merge")
                            Label("Ease: \(String(format: "%.1f", word.easeFactor))", systemImage: "gauge.with.dots.needle.bottom.0percent")
                            Label("Interval: \(String(format: "%.1f", word.reviewInterval))d", systemImage: "clock")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            ContentUnavailableView(
                "Select a word",
                systemImage: "character.book.closed",
                description: Text("Click any word to see its meaning and case forms.")
            )
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Case Helpers

private let caseKeys = ["nom", "gen", "dat", "acc", "ins", "prep", "pl_nom", "pl_gen", "pl_dat"]

private func caseLabel(_ key: String) -> String {
    switch key {
    case "nom": return "Nominative"
    case "gen": return "Genitive"
    case "dat": return "Dative"
    case "acc": return "Accusative"
    case "ins": return "Instrumental"
    case "prep": return "Prepositional"
    case "pl_nom": return "Pl. Nom"
    case "pl_gen": return "Pl. Gen"
    case "pl_dat": return "Pl. Dat"
    default: return key
    }
}
