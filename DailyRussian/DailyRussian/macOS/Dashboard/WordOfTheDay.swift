import SwiftUI
import CoreData

/// Shows a daily word — picks a medium-difficulty, high-frequency word.
struct WordOfTheDayCard: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var word: WordEntry?
    @State private var expanded = false

    private let tts = TTSProvider()

    /// Deterministic word pick based on today's date
    private static func todaySeed() -> Int {
        let cal = Calendar.current
        let day = cal.component(.day, from: Date())
        let month = cal.component(.month, from: Date())
        let year = cal.component(.year, from: Date())
        return (year * 10000 + month * 100 + day)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("Word of the Day", systemImage: "sparkles")
                    .font(.caption).fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Date(), style: .date)
                    .font(.caption2).foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)

            if let word = word {
                Divider()
                VStack(spacing: 10) {
                    HStack {
                        Button { tts.speak(word.word ?? "") } label: {
                            Text(word.word ?? "")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.plain)
                        if let pos = word.partOfSpeech {
                            Text(pos)
                                .font(.caption).foregroundStyle(.secondary)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1), in: Capsule())
                        }
                        Spacer()
                    }

                    Text(word.translation ?? "")
                        .font(.title3).foregroundStyle(.primary)

                    if expanded {
                        if let caseJSON = word.caseForms,
                           let data = caseJSON.data(using: .utf8),
                           let cases = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                           !cases.isEmpty {
                            Divider()
                            HStack(spacing: 8) {
                                ForEach(["ном","ген","дат","акк","инс","пре"], id: \.self) { k in
                                    if let form = cases[k] {
                                        VStack(spacing: 2) {
                                            Text(form).font(.caption).fontWeight(.medium)
                                            Text(caseAbbr(k)).font(.caption2).foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button { withAnimation { expanded.toggle() } } label: {
                        Text(expanded ? "Show less" : "Show case forms")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
            } else {
                Divider()
                Text("Loading...").font(.caption).foregroundStyle(.secondary)
                    .padding(12)
                    .onAppear { pickWord() }
            }
        }
        .background(Color.accentColor.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            pickWord()
        }
    }

    private func pickWord() {
        let fetch: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        // Pick medium-difficulty words (2-3) that are frequent (not too obscure)
        fetch.predicate = NSPredicate(format: "difficulty >= 2 AND difficulty <= 3 AND caseForms != nil")
        fetch.fetchLimit = 500
        guard let candidates = try? viewContext.fetch(fetch), !candidates.isEmpty else { return }

        // Deterministic but varied per day
        let seed = Self.todaySeed()
        let index = seed % candidates.count
        word = candidates[index]
    }

    private func caseAbbr(_ key: String) -> String {
        switch key {
        case "ном": return "Nom"; case "ген": return "Gen"
        case "дат": return "Dat"; case "акк": return "Acc"
        case "инс": return "Ins"; case "пре": return "Prep"
        default: return key
        }
    }
}
