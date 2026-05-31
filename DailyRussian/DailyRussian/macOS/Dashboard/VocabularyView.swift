import SwiftUI
import CoreData

/// Interactive vocabulary browser — click any word to see translation and hear pronunciation.
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
    @State private var showTranslation = false
    @State private var filterLearned: FilterMode = .all

    private let tts = TTSProvider()

    enum FilterMode: String, CaseIterable {
        case all = "All"
        case learned = "Learned"
        case unlearned = "New"
        case due = "Due"
    }

    var filteredWords: [WordEntry] {
        var result = Array(words)

        if !searchText.isEmpty {
            result = result.filter {
                ($0.word ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.translation ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }

        switch filterLearned {
        case .all: break
        case .learned: result = result.filter(\.isLearned)
        case .unlearned: result = result.filter { !$0.isLearned }
        case .due:
            let now = Date()
            result = result.filter { word in
                guard let nextReview = word.nextReview else { return true }
                return nextReview <= now
            }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and filter bar
            HStack {
                TextField("Search...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)

                Picker("Filter", selection: $filterLearned) {
                    ForEach(FilterMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Spacer()

                Text("\(filteredWords.count) words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.bar)

            Divider()

            // Word list
            if filteredWords.isEmpty {
                ContentUnavailableView(
                    "No words found",
                    systemImage: "magnifyingglass",
                    description: Text(searchText.isEmpty ? "Seed data hasn't loaded. Try restarting the app." : "Try a different search.")
                )
            } else {
                List(filteredWords, selection: $selectedWord) { word in
                    wordRow(word)
                        .tag(word as WordEntry?)
                }
                .listStyle(.inset)
            }
        }
        .navigationTitle("Vocabulary")
        .safeAreaInset(edge: .bottom) {
            // Detail panel for selected word
            if let word = selectedWord {
                wordDetail(word)
                    .frame(maxWidth: .infinity)
                    .background(.bar)
                    .transition(.move(edge: .bottom))
            }
        }
    }

    // MARK: - Word Row

    private func wordRow(_ word: WordEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(word.word ?? "")
                    .font(.headline)
                if let pos = word.partOfSpeech {
                    Text(pos)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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

    // MARK: - Word Detail

    private func wordDetail(_ word: WordEntry) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(word.word ?? "")
                    .font(.title2)
                    .fontWeight(.bold)

                Button {
                    tts.speak(word.word ?? "")
                } label: {
                    Image(systemName: "speaker.wave.2.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    withAnimation { selectedWord = nil }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            if showTranslation {
                Text(word.translation ?? "")
                    .font(.title3)
                    .foregroundStyle(.primary)
                if let pos = word.partOfSpeech {
                    Text(pos)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Spaced repetition info
                HStack(spacing: 16) {
                    Label("Reviews: \(word.reviewCount)", systemImage: "arrow.triangle.merge")
                    Label("Ease: \(String(format: "%.1f", word.easeFactor))", systemImage: "gauge.with.dots.needle.bottom.0percent")
                    if let next = word.nextReview {
                        Label("Next: \(next.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            } else {
                Button("Show translation") {
                    withAnimation { showTranslation = true }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .onChange(of: selectedWord?.id) { _, _ in
            showTranslation = false
        }
    }
}
