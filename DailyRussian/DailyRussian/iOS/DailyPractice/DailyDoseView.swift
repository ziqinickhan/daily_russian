import SwiftUI
import CoreData

/// Main daily practice view — shows today's words and phrases to learn/review.
struct DailyDoseView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WordEntry.dateAdded, ascending: false)],
        predicate: NSPredicate(format: "nextReview == nil OR nextReview <= %@", Date() as NSDate),
        animation: .default
    )
    private var dueWords: FetchedResults<WordEntry>

    @State private var currentIndex = 0
    @State private var showTranslation = false
    @State private var sessionWordsReviewed = 0
    @State private var sessionStart = Date()

    private let tts = TTSProvider()

    var body: some View {
        NavigationStack {
            VStack {
                if dueWords.isEmpty {
                    emptyState
                } else if currentIndex < dueWords.count {
                    wordCard(dueWords[currentIndex])
                } else {
                    completionView
                }
            }
            .navigationTitle("Daily Practice")
            #if os(iOS)
            .toolbar {
                if !dueWords.isEmpty && currentIndex < dueWords.count {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text("\(currentIndex + 1) / \(dueWords.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            #endif
        }
    }

    // MARK: - Word Card

    private func wordCard(_ word: WordEntry) -> some View {
        VStack(spacing: 24) {
            Spacer()

            // Russian word
            Button {
                tts.speak(word.word ?? "")
            } label: {
                Text(word.word ?? "")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            .buttonStyle(.plain)

            if let pos = word.partOfSpeech {
                Text(pos)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Translation (revealed on tap)
            if showTranslation {
                Text(word.translation ?? "")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .transition(.opacity)
            } else {
                Button("Show translation") {
                    withAnimation { showTranslation = true }
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            // Rating buttons (after translation shown)
            if showTranslation {
                ratingButtons(for: word)
            }
        }
        .padding()
    }

    // MARK: - Rating Buttons

    @ViewBuilder
    private func ratingButtons(for word: WordEntry) -> some View {
        VStack(spacing: 8) {
            Text("How well did you know it?")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(0..<6) { quality in
                    Button {
                        rateWord(word, quality: quality)
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(quality)")
                                .fontWeight(.medium)
                            Text(labelForQuality(quality))
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(qualityColor(quality).opacity(0.15))
                        .foregroundStyle(qualityColor(quality))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            Text("Session complete!")
                .font(.title2)
                .fontWeight(.bold)
            Text("Reviewed \(sessionWordsReviewed) words")
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Nothing due for review")
                .font(.title3)
            Text("New words will appear here as you add them.")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

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

        if quality >= 3 && !word.isLearned {
            word.isLearned = true
        }

        try? viewContext.save()

        // Advance
        sessionWordsReviewed += 1
        withAnimation {
            showTranslation = false
            currentIndex += 1
        }
    }

    // MARK: - Helpers

    private func labelForQuality(_ q: Int) -> String {
        switch q {
        case 0: return "blank"
        case 1: return "vague"
        case 2: return "hard"
        case 3: return "okay"
        case 4: return "good"
        case 5: return "easy"
        default: return ""
        }
    }

    private func qualityColor(_ q: Int) -> Color {
        switch q {
        case 0..<3: return .red
        case 3: return .orange
        case 4: return .yellow
        case 5: return .green
        default: return .gray
        }
    }
}
