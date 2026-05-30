import SwiftUI
import CoreData

/// Browse all words in the collection.
struct QuickLookView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WordEntry.dateAdded, ascending: false)]
    )
    private var words: FetchedResults<WordEntry>

    @State private var searchText = ""

    private let tts = TTSProvider()

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredWords) { word in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(word.word ?? "")
                                .font(.headline)
                            Text(word.translation ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if word.isLearned {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        }
                        Button {
                            tts.speak(word.word ?? "")
                        } label: {
                            Image(systemName: "speaker.wave.2")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Words")
            .overlay {
                if filteredWords.isEmpty {
                    ContentUnavailableView(
                        "No words yet",
                        systemImage: "character.book.closed",
                        description: Text("Start learning to build your vocabulary!")
                    )
                }
            }
        }
    }

    private var filteredWords: [WordEntry] {
        if searchText.isEmpty {
            return Array(words)
        }
        return words.filter {
            ($0.word ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.translation ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
}
