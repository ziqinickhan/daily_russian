import SwiftUI
import CoreData

/// Multiple choice quiz — translation and fill-in-blank modes.
struct QuizView: View {
    @Environment(\.managedObjectContext) private var viewContext

    enum Mode: String, CaseIterable { case translation = "Translation", fillBlank = "Fill-in-Blank" }

    @State private var mode: Mode = .translation
    @State private var currentWord: WordEntry?
    @State private var options: [String] = []
    @State private var selectedAnswer: String?
    @State private var isCorrect: Bool?
    @State private var score = 0
    @State private var total = 0

    // Fill-in-blank state
    @State private var sentenceText = ""
    @State private var blankAnswer = ""

    private let tts = TTSProvider()

    var body: some View {
        VStack(spacing: 0) {
            // Mode picker + score
            HStack {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { m in Text(m.rawValue).tag(m) }
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
                Spacer()
                Text("Score: \(score)/\(total)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()

            Divider()

            // Quiz content
            if let word = currentWord {
                VStack(spacing: 24) {
                    Spacer()

                    if mode == .translation {
                        translationQuiz(word)
                    } else {
                        fillBlankQuiz(word)
                    }

                    Spacer()

                    // Feedback
                    if let correct = isCorrect {
                        HStack {
                            Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(correct ? .green : .red)
                            Text(correct ? "Correct!" : "Wrong — the answer is highlighted below")
                                .font(.headline)
                        }
                        Button("Next") { nextQuestion() }
                            .buttonStyle(.borderedProminent)
                            .keyboardShortcut(.return, modifiers: [])
                    }
                }
                .padding()
            } else {
                ContentUnavailableView("Quiz", systemImage: "questionmark.circle", description: Text("Loading..."))
                    .onAppear { nextQuestion() }
            }
        }
        .navigationTitle("Quiz")
    }

    // MARK: - Translation Quiz

    private func translationQuiz(_ word: WordEntry) -> some View {
        VStack(spacing: 16) {
            Text("What does this word mean?")
                .font(.caption).foregroundStyle(.secondary)

            Button { tts.speak(word.word ?? "") } label: {
                Text(word.word ?? "")
                    .font(.largeTitle).fontWeight(.bold)
            }
            .buttonStyle(.plain)

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button {
                        checkTranslationAnswer(option, correct: word.translation ?? "")
                    } label: {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(optionBackground(option, word: word))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .disabled(isCorrect != nil)
                }
            }
            .frame(maxWidth: 400)
        }
    }

    private func optionBackground(_ option: String, word: WordEntry) -> some ShapeStyle {
        guard let isCorrect = isCorrect else { return Color.gray.opacity(0.1) }
        if option == selectedAnswer {
            return isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        }
        if option == word.translation {
            return Color.green.opacity(0.15)
        }
        return Color.gray.opacity(0.05)
    }

    // MARK: - Fill-in-Blank Quiz

    private func fillBlankQuiz(_ word: WordEntry) -> some View {
        VStack(spacing: 16) {
            Text("Choose the correct form")
                .font(.caption).foregroundStyle(.secondary)

            Text(sentenceText)
                .font(.title3)
                .lineSpacing(6)

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button {
                        checkBlankAnswer(option)
                    } label: {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(optionBlankBackground(option))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .disabled(isCorrect != nil)
                }
            }
            .frame(maxWidth: 400)
        }
    }

    private func optionBlankBackground(_ option: String) -> some ShapeStyle {
        guard let isCorrect = isCorrect else { return Color.gray.opacity(0.1) }
        if option == selectedAnswer {
            return isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        }
        if option == blankAnswer {
            return Color.green.opacity(0.15)
        }
        return Color.gray.opacity(0.05)
    }

    // MARK: - Logic

    private func nextQuestion() {
        isCorrect = nil
        selectedAnswer = nil

        // Pick a random word with case forms
        let fetch: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        fetch.predicate = NSPredicate(format: "caseForms != nil")
        fetch.fetchLimit = 500
        guard let all = try? viewContext.fetch(fetch), !all.isEmpty else { return }
        let word = all.randomElement()!
        currentWord = word

        if mode == .translation {
            generateTranslationOptions(word)
        } else {
            generateFillBlankOptions(word)
        }
    }

    private func generateTranslationOptions(_ word: WordEntry) {
        let correct = word.translation ?? ""
        let fetch: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        fetch.fetchLimit = 200
        let all = (try? viewContext.fetch(fetch)) ?? []
        var distractors: [String] = all
            .filter { $0.translation != correct && $0.translation != nil }
            .compactMap { $0.translation }
            .shuffled()
        distractors = Array(distractors.prefix(3))
        distractors.append(correct)
        options = distractors.shuffled()
    }

    private func generateFillBlankOptions(_ word: WordEntry) {
        guard let json = word.caseForms,
              let data = json.data(using: .utf8),
              let cases = try? JSONSerialization.jsonObject(with: data) as? [String: String],
              !cases.isEmpty else {
            // Fall back to translation quiz
            mode = .translation
            nextQuestion()
            return
        }

        let caseNames: [String: String] = [
            "ном": "Nominative", "ген": "Genitive", "дат": "Dative",
            "акк": "Accusative", "инс": "Instrumental", "пре": "Prepositional"
        ]

        // Pick a random case form
        let caseEntries = Array(cases).filter { caseNames[$0.key] != nil }
        guard let picked = caseEntries.randomElement() else { return }

        let correctForm = picked.value
        blankAnswer = correctForm

        // Generate sentence
        let caseLabel = caseNames[picked.key] ?? picked.key
        sentenceText = "Вы́берите фо́рму \(caseLabel) падежа́: ___ (\(word.word ?? ""))"

        // Distractors: other case forms of the same word
        var distractors = Array(cases.values.filter { $0 != correctForm }.shuffled().prefix(3))
        if distractors.count < 3 {
            let fetch: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
            fetch.fetchLimit = 100
            if let all = try? viewContext.fetch(fetch) {
                var extraForms: [String] = []
                for w in all {
                    if let j = w.caseForms,
                       let d = j.data(using: .utf8),
                       let c = try? JSONSerialization.jsonObject(with: d) as? [String: String],
                       let form = c.values.first {
                        extraForms.append(form)
                    }
                }
                extraForms.shuffle()
                let needed = min(3 - distractors.count, extraForms.count)
                distractors.append(contentsOf: extraForms.prefix(needed))
            }
        }
        distractors.append(correctForm)
        options = Array(distractors).shuffled()
    }

    private func checkTranslationAnswer(_ selected: String, correct: String) {
        selectedAnswer = selected
        isCorrect = selected == correct
        total += 1
        if isCorrect == true { score += 1 }
        updateSM2(correct: isCorrect == true)
    }

    private func checkBlankAnswer(_ selected: String) {
        selectedAnswer = selected
        isCorrect = selected == blankAnswer
        total += 1
        if isCorrect == true { score += 1 }
        updateSM2(correct: isCorrect == true)
    }

    private func updateSM2(correct: Bool) {
        guard let word = currentWord else { return }
        let quality = correct ? 5 : 2
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
    }
}
