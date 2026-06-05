import SwiftUI
import CoreData

/// Interactive vocabulary browser.
/// - Click any word → meaning + pronunciation in one click
/// - Filter by tag (noun, verb, adjective, etc.)
/// - Shows case declensions when available
struct VocabularyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var navigation: AppNavigation

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordEntry.difficulty, ascending: true),
            NSSortDescriptor(keyPath: \WordEntry.word, ascending: true)
        ],
        animation: .default
    )
    private var words: FetchedResults<WordEntry>

    @State private var selectedWordID: UUID?
    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @FocusState private var isSearchFocused: Bool

    private let tts = TTSProvider()

    // MARK: - Tags

    var tags: [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for w in words {
            let t = tagFor(w)
            if !t.isEmpty { counts[t, default: 0] += 1 }
        }
        return [("All", words.count)] + counts.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) }
    }

    func tagFor(_ word: WordEntry) -> String {
        guard let pos = word.partOfSpeech else { return "" }
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

    // Resolve selected word from UUID (avoids NSManagedObject selection conflicts)
    var selectedWord: WordEntry? {
        guard let id = selectedWordID else { return nil }
        return words.first { $0.id == id }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Search + tag filter bar
            HStack(spacing: 8) {
                TextField("Search...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .focused($isSearchFocused)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.name) { tag in
                            TagPill(
                                name: tag.name,
                                count: tag.count,
                                isSelected: selectedTag == tag.name || (tag.name == "All" && selectedTag == nil)
                            )
                            .onTapGesture {
                                selectedTag = (tag.name == "All") ? nil : tag.name
                                selectedWordID = nil
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }

                Spacer()
                Text("\(filteredWords.count) words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(.bar)

            Divider()

            // Main area: word list + detail
            if filteredWords.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No words found")
                        .font(.headline)
                    if words.isEmpty {
                        Button("Load Vocabulary") {
                            PersistenceController.shared.reseed()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HSplitView {
                    // Word list
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredWords, id: \.id) { word in
                                WordRow(
                                    word: word,
                                    isSelected: selectedWordID == word.id,
                                    tts: tts
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedWordID = word.id
                                }
                                Divider()
                            }
                        }
                    }
                    .frame(minWidth: 220, idealWidth: 280)
                    .keyboardNavigable(selectedID: $selectedWordID, itemIDs: filteredWords.compactMap { $0.id })

                    // Detail panel
                    if let word = selectedWord {
                        WordDetailView(word: word, tts: tts)
                            .frame(minWidth: 300)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "character.book.closed")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("Select a word")
                                .font(.headline)
                            Text("Click any word to see its meaning, pronunciation, and case forms.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Vocabulary")
        .toolbar {
            if navigation.previousSection != "Vocabulary" {
                ToolbarItem(placement: .navigation) {
                    Button {
                        navigation.shouldNavigateBack = true
                    } label: {
                        Label("Back to \(navigation.previousSection)", systemImage: "arrow.left")
                    }
                }
            }
        }
        .background(
            Button("") { isSearchFocused = true }
                .keyboardShortcut("f", modifiers: .command)
                .opacity(0)
        )
        .onReceive(navigation.$navigateToVocabWithWord) { wordID in
            if let id = wordID {
                selectedWordID = id
                searchText = ""
                selectedTag = nil
                navigation.navigateToVocabWithWord = nil
            }
        }
    }
}

// MARK: - Tag Pill

struct TagPill: View {
    let name: String
    let count: Int
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.caption2)
            Text("\(count)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
        .foregroundStyle(isSelected ? .white : .primary)
        .clipShape(Capsule())
    }
}

// MARK: - Word Row

struct WordRow: View {
    let word: WordEntry
    let isSelected: Bool
    let tts: TTSProvider

    var body: some View {
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

            Button {
                tts.speak(word.word ?? "")
            } label: {
                Image(systemName: "speaker.wave.2")
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    }
}

// MARK: - Word Detail

struct WordDetailView: View {
    let word: WordEntry
    let tts: TTSProvider

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Word + pronunciation
                HStack {
                    Text(word.word ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .textSelection(.enabled)
                    Button {
                        tts.speak(word.word ?? "")
                    } label: {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }

                Text(word.translation ?? "")
                    .font(.title3)
                    .textSelection(.enabled)

                if let pos = word.partOfSpeech {
                    HStack(spacing: 8) {
                        tagBadge(pos)
                        Text(pos)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let note = word.note {
                    Label(note, systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                // Case declensions
                if let caseJSON = word.caseForms,
                   let data = caseJSON.data(using: .utf8),
                   let cases = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                   !cases.isEmpty {
                    Divider()

                    // Detect adjective-style keys (м_ном, ж_ном, etc.) vs noun-style (ном, ген, etc.)
                    let hasAdjKeys = cases.keys.contains { $0.hasPrefix("м_") || $0.hasPrefix("ж_") || $0.hasPrefix("с_") }

                    if hasAdjKeys {
                        Text("Declension")
                            .font(.headline)
                        AdjectiveCaseTable(cases: cases)
                    } else {
                        Text("Case Forms")
                            .font(.headline)
                        NounCaseGrid(cases: cases)
                    }
                }

                // Verb conjugations
                if let conjJSON = word.conjugation,
                   let data = conjJSON.data(using: .utf8),
                   let conj = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                   !conj.isEmpty {
                    Divider()
                    Text("Conjugation")
                        .font(.headline)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(["я","ты","он","мы","вы","они"], id: \.self) { person in
                            if let form = conj[person] {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(person)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(form)
                                        .font(.callout)
                                        .fontWeight(.medium)
                                        .textSelection(.enabled)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }

                    // Past tense
                    let pastKeys = ["он(пр)","она(пр)","оно(пр)","они(пр)"]
                    let hasPast = pastKeys.contains { conj[$0] != nil }
                    if hasPast {
                        Text("Past Tense")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                        LazyVGrid(columns: [
                            GridItem(.flexible()), GridItem(.flexible()),
                            GridItem(.flexible()), GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(pastKeys, id: \.self) { key in
                                if let form = conj[key] {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(key)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        Text(form)
                                            .font(.callout)
                                            .fontWeight(.medium)
                                            .textSelection(.enabled)
                                    }
                                }
                            }
                        }
                    }
                }

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
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    func tagBadge(_ pos: String) -> some View {
        let tag: String = {
            if pos.hasPrefix("noun") { return "noun" }
            if pos.hasPrefix("verb") { return "verb" }
            if pos.hasPrefix("adjective") { return "adj" }
            if pos.hasPrefix("adverb") { return "adv" }
            if pos.hasPrefix("number") { return "num" }
            return "other"
        }()
        return Text(tag)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.blue.opacity(0.1), in: Capsule())
    }
}

// MARK: - Noun Case Grid

struct NounCaseGrid: View {
    let cases: [String: String]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
            ForEach(caseKeys, id: \.self) { key in
                if let form = cases[key] {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(caseLabel(key))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(form)
                            .font(.callout)
                            .fontWeight(.medium)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

// MARK: - Adjective Case Table

struct AdjectiveCaseTable: View {
    let cases: [String: String]

    private let genders = [("м", "Masc"), ("ж", "Fem"), ("с", "Neut"), ("мн", "Plural")]
    private let caseCols = [("ном", "Nom"), ("ген", "Gen"), ("дат", "Dat"), ("акк", "Acc"), ("инс", "Ins"), ("пре", "Prep")]

    var body: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            // Header row
            GridRow {
                Text("")
                    .font(.caption2)
                ForEach(caseCols, id: \.0) { _, label in
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 50)
                }
            }

            ForEach(genders, id: \.0) { gKey, gLabel in
                GridRow {
                    Text(gLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(alignment: .leading)
                    ForEach(caseCols, id: \.0) { cKey, _ in
                        let lookupKey = "\(gKey)_\(cKey)"
                        Text(cases[lookupKey] ?? "—")
                            .font(.caption)
                            .textSelection(.enabled)
                            .frame(minWidth: 50, alignment: .leading)
                    }
                }
            }
        }
    }
}

// MARK: - Helpers

private let caseKeys = ["ном", "ген", "дат", "акк", "инс", "пре", "мн_ном", "мн_ген", "мн_дат", "мн_акк", "мн_инс", "мн_пре"]

private func caseLabel(_ key: String) -> String {
    switch key {
    case "ном": return "Nominative"
    case "ген": return "Genitive"
    case "дат": return "Dative"
    case "акк": return "Accusative"
    case "инс": return "Instrumental"
    case "пре": return "Prepositional"
    case "мн_ном": return "Pl. Nom"
    case "мн_ген": return "Pl. Gen"
    case "мн_дат": return "Pl. Dat"
    case "мн_акк": return "Pl. Acc"
    case "мн_инс": return "Pl. Ins"
    case "мн_пре": return "Pl. Prep"
    default: return key
    }
}

/// Generate adjective case display from declension JSON
func parseAdjectiveCases(from json: String) -> [(String, String)] {
    guard let data = json.data(using: .utf8),
          let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String]
    else { return [] }

    var result: [(String, String)] = []
    let order = ["м_ном","м_ген","м_дат","м_акк","м_инс","м_пре",
                  "ж_ном","ж_ген","ж_дат","ж_акк","ж_инс","ж_пре",
                  "с_ном","с_ген","с_дат","с_акк","с_инс","с_пре"]
    for key in order {
        if let form = dict[key] {
            result.append((key, form))
        }
    }
    return result
}
