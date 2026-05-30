import SwiftUI
import CoreData

/// Quick review of words due for spaced repetition review.
struct ReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WordEntry.nextReview, ascending: true)],
        predicate: NSPredicate(format: "nextReview != nil AND nextReview <= %@", Date() as NSDate),
        animation: .default
    )
    private var overdueWords: FetchedResults<WordEntry>

    @State private var selectedWord: WordEntry?
    @State private var showTranslation = false

    private let tts = TTSProvider()

    var body: some View {
        NavigationStack {
            List {
                if overdueWords.isEmpty {
                    ContentUnavailableView(
                        "All caught up!",
                        systemImage: "clock.badge.checkmark",
                        description: Text("No words are overdue for review.")
                    )
                } else {
                    Section("\(overdueWords.count) words due") {
                        ForEach(overdueWords) { word in
                            reviewRow(word)
                        }
                    }
                }
            }
            .navigationTitle("Review")
        }
    }

    private func reviewRow(_ word: WordEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word ?? "")
                    .font(.headline)
                if let pos = word.partOfSpeech {
                    Text(pos)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Speak button
            Button {
                tts.speak(word.word ?? "")
            } label: {
                Image(systemName: "speaker.wave.2")
            }
            .buttonStyle(.plain)

            // Quick review toggle
            Button {
                withAnimation {
                    if selectedWord?.id == word.id {
                        selectedWord = nil
                        showTranslation = false
                    } else {
                        selectedWord = word
                        showTranslation = false
                    }
                }
            } label: {
                Image(systemName: selectedWord?.id == word.id ? "chevron.up.circle.fill" : "chevron.down.circle")
            }
        }
        .padding(.vertical, 4)
        // Expanded translation
        .sheet(item: $selectedWord) { word in
            reviewSheet(for: word)
        }
    }

    private func reviewSheet(for word: WordEntry) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(word.word ?? "")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(word.translation ?? "")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text("Next review:")
                        .foregroundStyle(.secondary)
                    Text(word.nextReview ?? Date(), style: .relative)
                }
                .font(.caption)

                Divider()

                HStack(spacing: 16) {
                    Button("Forgot") {
                        rateWord(word, quality: 1)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                    Button("Hard") {
                        rateWord(word, quality: 3)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)

                    Button("Good") {
                        rateWord(word, quality: 5)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding()
            .navigationTitle("Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { selectedWord = nil }
                }
            }
        }
    }

    private func rateWord(_ word: WordEntry, quality: Int) {
        let result = SpacedRepetition.schedule(
            quality: quality,
            currentInterval: word.reviewInterval,
            currentEaseFactor: word.easeFactor,
            reviewCount: word.reviewCount.asInt
        )
        word.lastReviewed = Date()
        word.nextReview = result.nextReview
        word.reviewInterval = result.interval
        word.easeFactor = result.easeFactor
        word.reviewCount += 1
        try? viewContext.save()
        selectedWord = nil
    }
}
