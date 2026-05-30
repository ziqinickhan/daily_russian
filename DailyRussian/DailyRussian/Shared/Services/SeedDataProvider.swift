import CoreData

/// Seeds the database with initial Russian vocabulary and grammar notes.
/// Only runs once — checks for existing data before inserting.
struct SeedDataProvider {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    /// Run once on first launch. Safe to call multiple times — skips if data exists.
    func seedIfNeeded() {
        guard needsSeeding() else { return }
        seedWords()
        seedGrammar()
        try? viewContext.save()
    }

    private func needsSeeding() -> Bool {
        let fetch: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        fetch.fetchLimit = 1
        let count = (try? viewContext.count(for: fetch)) ?? 0
        return count == 0
    }

    // MARK: - Vocabulary

    private func seedWords() {
        let words: [(word: String, translation: String, partOfSpeech: String?, difficulty: Int16)] = [
            // Greetings
            ("приве́т", "hello / hi", "greeting", 1),
            ("здра́вствуйте", "hello (formal)", "greeting", 1),
            ("до свида́ния", "goodbye", "greeting", 1),
            ("пока́", "bye (informal)", "greeting", 1),
            ("как дела́?", "how are things?", "phrase", 1),
            ("хорошо́", "good / well", "adverb", 1),
            ("спаси́бо", "thank you", "expression", 1),
            ("пожа́луйста", "please / you're welcome", "expression", 1),
            ("извини́те", "excuse me / sorry", "expression", 2),
            ("да", "yes", "particle", 1),
            ("нет", "no / not", "particle", 1),

            // People
            ("челове́к", "person", "noun m", 2),
            ("друг", "friend (male)", "noun m", 1),
            ("подру́га", "friend (female)", "noun f", 1),
            ("мужчи́на", "man", "noun m", 2),
            ("же́нщина", "woman", "noun f", 2),
            ("ребёнок", "child", "noun m", 2),
            ("семья́", "family", "noun f", 2),

            // Verbs
            ("говори́ть", "to speak", "verb impf", 2),
            ("сказа́ть", "to say (perfective)", "verb pf", 3),
            ("знать", "to know", "verb impf", 2),
            ("понима́ть", "to understand", "verb impf", 2),
            ("ду́мать", "to think", "verb impf", 2),
            ("хоте́ть", "to want", "verb impf", 2),
            ("люби́ть", "to love", "verb impf", 2),
            ("жить", "to live", "verb impf", 2),
            ("рабо́тать", "to work", "verb impf", 2),
            ("чита́ть", "to read", "verb impf", 2),
            ("есть", "to eat", "verb impf", 2),
            ("пить", "to drink", "verb impf", 2),

            // Food & drink
            ("во́да", "water", "noun f", 1),
            ("хлеб", "bread", "noun m", 1),
            ("молоко́", "milk", "noun n", 1),
            ("ко́фе", "coffee", "noun m", 1),
            ("чай", "tea", "noun m", 1),
            ("мя́со", "meat", "noun n", 2),
            ("ры́ба", "fish", "noun f", 2),

            // Places
            ("дом", "house / home", "noun m", 1),
            ("рабо́та", "work / job", "noun f", 1),
            ("шко́ла", "school", "noun f", 2),
            ("магази́н", "shop / store", "noun m", 2),
            ("рестора́н", "restaurant", "noun m", 2),
            ("у́лица", "street", "noun f", 2),

            // Time
            ("сего́дня", "today", "adverb", 1),
            ("за́втра", "tomorrow", "adverb", 1),
            ("вчера́", "yesterday", "adverb", 1),
            ("сейча́с", "now", "adverb", 1),
            ("у́тро", "morning", "noun n", 1),
            ("ве́чер", "evening", "noun m", 1),
            ("день", "day", "noun m", 1),
            ("ночь", "night", "noun f", 1),
            ("вре́мя", "time", "noun n", 2),

            // Question words
            ("кто", "who", "pronoun", 1),
            ("что", "what", "pronoun", 1),
            ("где", "where", "adverb", 1),
            ("когда́", "when", "adverb", 1),
            ("почему́", "why", "adverb", 2),
            ("как", "how", "adverb", 1),
            ("ско́лько", "how much / many", "adverb", 2),

            // Adjectives
            ("хоро́ший", "good", "adjective", 2),
            ("плохо́й", "bad", "adjective", 2),
            ("большо́й", "big", "adjective", 2),
            ("ма́ленький", "small", "adjective", 2),
            ("но́вый", "new", "adjective", 2),
            ("ста́рый", "old", "adjective", 2),
            ("краси́вый", "beautiful", "adjective", 2),
            ("ру́сский", "Russian", "adjective", 1),
        ]

        for entry in words {
            let w = WordEntry(context: viewContext)
            w.id = UUID()
            w.word = entry.word
            w.translation = entry.translation
            w.partOfSpeech = entry.partOfSpeech
            w.difficulty = entry.difficulty
            w.dateAdded = Date()
            w.isLearned = false
            w.reviewCount = 0
            w.reviewInterval = 0
            w.easeFactor = 2.5
        }
    }

    // MARK: - Grammar

    private func seedGrammar() {
        let notes: [(title: String, content: String, category: String)] = [
            (
                title: "The Case System",
                content: "Russian has 6 grammatical cases. Each case changes the ending of nouns, adjectives, and pronouns depending on their role in the sentence.\n\n• Nominative (кто? что?) — the subject\n• Genitive (кого́? чего́?) — possession, negation, quantity\n• Dative (кому́? чему́?) — indirect object, recipient\n• Accusative (кого́? что?) — direct object\n• Instrumental (кем? чем?) — means, tool, accompaniment\n• Prepositional (о ком? о чём?) — location, about whom/what\n\nExample: дом (house)\n• Gen: до́ма (of the house)\n• Dat: до́му (to the house)\n• Acc: дом (object)\n• Ins: до́мом (with the house)\n• Prep: о до́ме (about the house)",
                category: "Case"
            ),
            (
                title: "Verb Aspects",
                content: "Every Russian verb comes in a pair: imperfective (ongoing/repeated) and perfective (completed action).\n\nImperfective (что де́лать?):\n• Describes process, repetition, or habit\n• Used for present tense\n\nPerfective (что сде́лать?):\n• Describes a completed result\n• No present tense — used for past/future only\n\nExamples:\n• чита́ть (impf) / прочита́ть (pf) — to read\n• писа́ть (impf) / написа́ть (pf) — to write\n• говори́ть (impf) / сказа́ть (pf) — to speak/say",
                category: "Verb"
            ),
            (
                title: "Prepositions and Cases",
                content: "Every preposition governs a specific case. You must memorize which case follows which preposition.\n\n• в / на + Prepositional: location (в до́ме = in the house)\n• в / на + Accusative: direction (в дом = into the house)\n• с + Genitive: from (с рабо́ты = from work)\n• с + Instrumental: with (с дру́гом = with a friend)\n• у + Genitive: near / at someone's place (у меня́ = I have / at my place)\n• к + Dative: toward (к до́му = toward the house)\n• о + Prepositional: about (о тебе́ = about you)",
                category: "Preposition"
            ),
            (
                title: "Gender of Nouns",
                content: "Russian nouns have three genders. You can usually tell from the ending:\n\nMasculine: \n• End in a consonant: дом, стол, друг\n• Some end in -а/я for male people: па́па, дя́дя\n\nFeminine:\n• End in -а/я: кни́га, неде́ля, семья́\n• Some end in -ь: ночь, жизнь, любо́вь\n\nNeuter:\n• End in -о/е: окно́, мо́ре, вре́мя\n• Some end in -мя: и́мя, вре́мя\n\nGender affects adjective endings and past tense verb forms.",
                category: "Noun"
            ),
            (
                title: "Hard vs Soft Adjectives",
                content: "Adjectives agree with nouns in gender, number, and case. There are two patterns: hard-stem and soft-stem.\n\nHard stem (ends in -ый/-ой):\nно́вый (new): но́вый, но́вая, но́вое, но́вые\n\nSoft stem (ends in -ий):\nси́ний (dark blue): си́ний, си́няя, си́нее, си́ние\n\nAfter к, г, х, ж, ч, ш, щ, use -ий not -ый:\nру́сский, хоро́ший, большо́й",
                category: "Adjective"
            ),
        ]

        for entry in notes {
            let n = GrammarNote(context: viewContext)
            n.id = UUID()
            n.title = entry.title
            n.content = entry.content
            n.category = entry.category
            n.dateAdded = Date()
        }
    }
}
