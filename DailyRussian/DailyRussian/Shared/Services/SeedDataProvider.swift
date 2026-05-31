import CoreData

/// Seeds the database with initial Russian vocabulary and grammar notes.
/// Only runs once — checks for existing data before inserting.
struct SeedDataProvider {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func seedIfNeeded() {
        guard needsSeeding() else { return }
        seedWords()
        seedGrammar()
        seedPhrases()
        try? viewContext.save()
    }

    private func needsSeeding() -> Bool {
        let fetch: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        fetch.fetchLimit = 1
        let count = (try? viewContext.count(for: fetch)) ?? 0
        return count == 0
    }

    // MARK: - Vocabulary

    private struct WordSeed {
        let word: String
        let translation: String
        let partOfSpeech: String?
        let difficulty: Int16
        let caseForms: String?  // JSON: {"gen":"...","dat":"...",...}
        let note: String?
    }

    private func seedWords() {
        let words: [WordSeed] = [
            // MARK: Greetings & Politeness
            WordSeed(word: "приве́т", translation: "hello / hi", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "здра́вствуйте", translation: "hello (formal)", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "до́брое у́тро", translation: "good morning", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "до́брый день", translation: "good afternoon", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "до́брый ве́чер", translation: "good evening", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "до свида́ния", translation: "goodbye", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "пока́", translation: "bye (informal)", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "споко́йной но́чи", translation: "good night", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "как дела́?", translation: "how are things?", partOfSpeech: "phrase", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ничего́", translation: "nothing / so-so", partOfSpeech: "expression", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "норма́льно", translation: "fine / okay", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "хорошо́", translation: "good / well", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "отли́чно", translation: "great / excellent", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "спаси́бо", translation: "thank you", partOfSpeech: "expression", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "большо́е спаси́бо", translation: "thank you very much", partOfSpeech: "expression", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "пожа́луйста", translation: "please / you're welcome", partOfSpeech: "expression", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "извини́те", translation: "excuse me / sorry", partOfSpeech: "expression", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "прости́те", translation: "I'm sorry (formal)", partOfSpeech: "expression", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ничего́ стра́шного", translation: "it's okay / no worries", partOfSpeech: "expression", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "да", translation: "yes", partOfSpeech: "particle", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "нет", translation: "no / not", partOfSpeech: "particle", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "коне́чно", translation: "of course", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "может быть", translation: "maybe", partOfSpeech: "expression", difficulty: 2, caseForms: nil, note: nil),

            // MARK: People & Family
            WordSeed(word: "челове́к", translation: "person", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"pl_nom":"лю́ди","pl_gen":"люде́й","pl_dat":"лю́дям"}"#, note: "irregular plural"),
            WordSeed(word: "лю́ди", translation: "people", partOfSpeech: "noun pl", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "друг", translation: "friend (male)", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"gen":"дру́га","dat":"дру́гу","acc":"дру́га","ins":"дру́гом","prep":"дру́ге","pl_nom":"друзья́"}"#, note: "pl: друзья́"),
            WordSeed(word: "подру́га", translation: "friend (female)", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"gen":"подру́ги","dat":"подру́ге","acc":"подру́гу","ins":"подру́гой","prep":"подру́ге"}"#, note: nil),
            WordSeed(word: "мужчи́на", translation: "man", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "же́нщина", translation: "woman", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ма́льчик", translation: "boy", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "де́вочка", translation: "girl", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ребёнок", translation: "child", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"pl_nom":"де́ти","pl_gen":"дете́й","pl_dat":"де́тям"}"#, note: "irregular pl: де́ти"),
            WordSeed(word: "мать", translation: "mother", partOfSpeech: "noun f", difficulty: 3, caseForms: #"{"gen":"ма́тери","dat":"ма́тери","ins":"ма́терью","prep":"ма́тери"}"#, note: "-ь stem noun"),
            WordSeed(word: "семья́", translation: "family", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "роди́тели", translation: "parents", partOfSpeech: "noun pl", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ма́ма", translation: "mom", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "па́па", translation: "dad", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "брат", translation: "brother", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"gen":"бра́та","dat":"бра́ту","acc":"бра́та","ins":"бра́том","prep":"бра́те","pl_nom":"бра́тья"}"#, note: "pl: бра́тья"),
            WordSeed(word: "сестра́", translation: "sister", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"gen":"сестры́","dat":"сестре́","acc":"сестру́","ins":"сестро́й","prep":"сестре́","pl_nom":"сёстры"}"#, note: "pl: сёстры, gen pl: сестёр"),
            WordSeed(word: "сын", translation: "son", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"gen":"сы́на","dat":"сы́ну","pl_nom":"сыновья́"}"#, note: "pl: сыновья́"),
            WordSeed(word: "дочь", translation: "daughter", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"gen":"до́чери","dat":"до́чери","ins":"до́черью","pl_nom":"до́чери"}"#, note: "irregular, -ь ending"),
            WordSeed(word: "муж", translation: "husband", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"gen":"му́жа","pl_nom":"мужья́"}"#, note: "pl: мужья́"),
            WordSeed(word: "жена́", translation: "wife", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"gen":"жены́","dat":"жене́","acc":"жену́","ins":"жено́й","prep":"жене́","pl_nom":"жёны"}"#, note: nil),
            WordSeed(word: "и́мя", translation: "name", partOfSpeech: "noun n", difficulty: 1, caseForms: #"{"gen":"и́мени","dat":"и́мени","ins":"и́менем","prep":"и́мени"}"#, note: "neuter -мя noun, irregular"),

            // MARK: Verbs — Essential
            WordSeed(word: "быть", translation: "to be", partOfSpeech: "verb impf", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "говори́ть", translation: "to speak", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "сказа́ть", translation: "to say (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "знать", translation: "to know", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "понима́ть", translation: "to understand", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ду́мать", translation: "to think", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "хоте́ть", translation: "to want", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "люби́ть", translation: "to love", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "жить", translation: "to live", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "рабо́тать", translation: "to work", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "де́лать", translation: "to do / make", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "сде́лать", translation: "to do / make (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "ви́деть", translation: "to see", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "уви́деть", translation: "to see (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "слы́шать", translation: "to hear", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "идти́", translation: "to go (on foot)", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ходи́ть", translation: "to go (on foot, multi)", partOfSpeech: "verb impf", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "е́хать", translation: "to go (by vehicle)", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "е́здить", translation: "to go (by vehicle, multi)", partOfSpeech: "verb impf", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "чита́ть", translation: "to read", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "писа́ть", translation: "to write", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "есть", translation: "to eat", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "пить", translation: "to drink", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "спать", translation: "to sleep", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "брать", translation: "to take", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "взять", translation: "to take (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "дава́ть", translation: "to give", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "дать", translation: "to give (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "смотре́ть", translation: "to watch / look", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "посмотре́ть", translation: "to watch / look (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "ждать", translation: "to wait", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "стоя́ть", translation: "to stand", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Food & Drink
            WordSeed(word: "во́да", translation: "water", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "хлеб", translation: "bread", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "молоко́", translation: "milk", partOfSpeech: "noun n", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ко́фе", translation: "coffee", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "чай", translation: "tea", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "са́хар", translation: "sugar", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "соль", translation: "salt", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "мя́со", translation: "meat", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ры́ба", translation: "fish", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ку́рица", translation: "chicken", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "яйцо́", translation: "egg", partOfSpeech: "noun n", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "суп", translation: "soup", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "сыр", translation: "cheese", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ма́сло", translation: "butter / oil", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "фру́кты", translation: "fruit", partOfSpeech: "noun pl", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "о́вощи", translation: "vegetables", partOfSpeech: "noun pl", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "карто́шка", translation: "potato", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "рис", translation: "rice", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "за́втрак", translation: "breakfast", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "обе́д", translation: "lunch", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "у́жин", translation: "dinner", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "вку́сно", translation: "tasty / delicious", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Places & Directions
            WordSeed(word: "дом", translation: "house / home", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "до́ма", translation: "at home", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "рабо́та", translation: "work / job", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "шко́ла", translation: "school", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "магази́н", translation: "shop / store", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "рестора́н", translation: "restaurant", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "у́лица", translation: "street", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "доро́га", translation: "road", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "го́род", translation: "city", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "страна́", translation: "country", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "Москва́", translation: "Moscow", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "Росси́я", translation: "Russia", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ме́сто", translation: "place", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "здесь", translation: "here", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "там", translation: "there", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "пря́мо", translation: "straight ahead", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "нале́во", translation: "to the left", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "напра́во", translation: "to the right", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ря́дом", translation: "nearby", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "далеко́", translation: "far", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Time
            WordSeed(word: "сего́дня", translation: "today", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "за́втра", translation: "tomorrow", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "вчера́", translation: "yesterday", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "сейча́с", translation: "now", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "пото́м", translation: "later / then", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "всегда́", translation: "always", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "иногда́", translation: "sometimes", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "никогда́", translation: "never", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ча́сто", translation: "often", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "у́тро", translation: "morning", partOfSpeech: "noun n", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "день", translation: "day", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ве́чер", translation: "evening", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ночь", translation: "night", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "вре́мя", translation: "time", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "час", translation: "hour", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "мину́та", translation: "minute", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "неде́ля", translation: "week", partOfSpeech: "noun f", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ме́сяц", translation: "month", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "год", translation: "year", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),

            // MARK: Question Words
            WordSeed(word: "кто", translation: "who", partOfSpeech: "pronoun", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "что", translation: "what", partOfSpeech: "pronoun", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "где", translation: "where", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "куда́", translation: "where to", partOfSpeech: "adverb", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "отку́да", translation: "where from", partOfSpeech: "adverb", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "когда́", translation: "when", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "почему́", translation: "why", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "как", translation: "how", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ско́лько", translation: "how much / many", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "како́й", translation: "which / what kind", partOfSpeech: "pronoun", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "чей", translation: "whose", partOfSpeech: "pronoun", difficulty: 3, caseForms: nil, note: nil),

            // MARK: Adjectives
            WordSeed(word: "хоро́ший", translation: "good", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "плохо́й", translation: "bad", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "большо́й", translation: "big", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ма́ленький", translation: "small", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "но́вый", translation: "new", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ста́рый", translation: "old", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "молодо́й", translation: "young", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "краси́вый", translation: "beautiful", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ру́сский", translation: "Russian", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "ва́жный", translation: "important", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "до́брый", translation: "kind", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "пло́хо", translation: "badly", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "холодный", translation: "cold", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "тёплый", translation: "warm", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "горя́чий", translation: "hot (object)", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "бе́лый", translation: "white", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "чёрный", translation: "black", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, note: nil),

            // MARK: Body & Health
            WordSeed(word: "рука́", translation: "hand / arm", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "нога́", translation: "foot / leg", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "голова́", translation: "head", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "глаз", translation: "eye", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "у́хо", translation: "ear", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "нос", translation: "nose", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "рот", translation: "mouth", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "се́рдце", translation: "heart", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "боле́ть", translation: "to hurt / be sick", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "здоро́вье", translation: "health", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Weather & Nature
            WordSeed(word: "пого́да", translation: "weather", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "со́лнце", translation: "sun", partOfSpeech: "noun n", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "дождь", translation: "rain", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "снег", translation: "snow", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ве́тер", translation: "wind", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "хо́лодно", translation: "it's cold", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "тепло́", translation: "it's warm", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "жа́рко", translation: "it's hot", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Clothing
            WordSeed(word: "оде́жда", translation: "clothing", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "руба́шка", translation: "shirt", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "штаны́", translation: "pants", partOfSpeech: "noun pl", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "пла́тье", translation: "dress", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ку́ртка", translation: "jacket", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ша́пка", translation: "hat", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "о́бувь", translation: "footwear", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Technology & Modern Life
            WordSeed(word: "телефо́н", translation: "telephone", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "компью́тер", translation: "computer", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "интерне́т", translation: "internet", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "сообщ́ение", translation: "message / text", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "звони́ть", translation: "to call (on phone)", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "позвони́ть", translation: "to call (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "отпра́вить", translation: "to send", partOfSpeech: "verb pf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "получи́ть", translation: "to receive", partOfSpeech: "verb pf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "фо́то", translation: "photo", partOfSpeech: "noun n", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "де́ньги", translation: "money", partOfSpeech: "noun pl", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "биле́т", translation: "ticket", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "па́спорт", translation: "passport", partOfSpeech: "noun m", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Emotions
            WordSeed(word: "ра́дость", translation: "joy", partOfSpeech: "noun f", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "грусть", translation: "sadness", partOfSpeech: "noun f", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "страх", translation: "fear", partOfSpeech: "noun m", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "удивле́ние", translation: "surprise", partOfSpeech: "noun n", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "сча́стье", translation: "happiness", partOfSpeech: "noun n", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "любо́вь", translation: "love", partOfSpeech: "noun f", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "смея́ться", translation: "to laugh", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "пла́кать", translation: "to cry", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "боя́ться", translation: "to be afraid", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Colors
            WordSeed(word: "кра́сный", translation: "red", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "си́ний", translation: "dark blue", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "зелёный", translation: "green", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "жёлтый", translation: "yellow", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "голубо́й", translation: "light blue", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "се́рый", translation: "gray", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Numbers
            WordSeed(word: "оди́н", translation: "one", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "два", translation: "two", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "три", translation: "three", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "четы́ре", translation: "four", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "пять", translation: "five", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "шесть", translation: "six", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "семь", translation: "seven", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "во́семь", translation: "eight", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "де́вять", translation: "nine", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "де́сять", translation: "ten", partOfSpeech: "number", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "сто", translation: "one hundred", partOfSpeech: "number", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "ты́сяча", translation: "one thousand", partOfSpeech: "number", difficulty: 2, caseForms: nil, note: nil),

            // MARK: Prepositions
            WordSeed(word: "в", translation: "in / into", partOfSpeech: "preposition", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "на", translation: "on / onto", partOfSpeech: "preposition", difficulty: 1, caseForms: nil, note: nil),
            WordSeed(word: "с", translation: "with / from", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "без", translation: "without", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "для", translation: "for", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "до", translation: "until / before", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "по́сле", translation: "after", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "о́коло", translation: "near / approximately", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, note: nil),
            WordSeed(word: "че́рез", translation: "through / across", partOfSpeech: "preposition", difficulty: 3, caseForms: nil, note: nil),
            WordSeed(word: "ме́жду", translation: "between", partOfSpeech: "preposition", difficulty: 3, caseForms: nil, note: nil),
        ]

        for entry in words {
            let w = WordEntry(context: viewContext)
            w.id = UUID()
            w.word = entry.word
            w.translation = entry.translation
            w.partOfSpeech = entry.partOfSpeech
            w.difficulty = entry.difficulty
            w.caseForms = entry.caseForms
            w.note = entry.note
            w.dateAdded = Date()
            w.isLearned = false
            w.reviewCount = 0
            w.reviewInterval = 0
            w.easeFactor = 2.5
        }
    }

    // MARK: - Common Phrases

    private func seedPhrases() {
        let phrases: [(String, String, String, String)] = [
            ("Что случи́лось?", "What happened?", "asking about a situation", "conversation"),
            ("Как вас зову́т?", "What's your name? (formal)", "introductions", "conversation"),
            ("О́чень прия́тно", "Nice to meet you", "introductions", "conversation"),
            ("Ско́лько э́то сто́ит?", "How much does this cost?", "shopping", "practical"),
            ("Я не понима́ю", "I don't understand", "clarification", "essential"),
            ("Повтори́те, пожа́луйста", "Please repeat (formal)", "clarification", "essential"),
            ("Говори́те ме́дленнее", "Speak slower (formal)", "clarification", "essential"),
            ("Как сказа́ть по-ру́сски...?", "How do you say... in Russian?", "learning", "essential"),
            ("Что э́то зна́чит?", "What does this mean?", "learning", "essential"),
            ("Мне ну́жно...", "I need...", "requests", "practical"),
            ("Я хочу́...", "I want...", "requests", "practical"),
            ("Где нахо́дится...?", "Where is... located?", "directions", "practical"),
            ("Мо́жно мне...?", "May I have...?", "polite requests", "practical"),
            ("С днём рожде́ния!", "Happy birthday!", "congratulations", "social"),
            ("На здоро́вье!", "To your health! / Enjoy your meal!", "toast / politeness", "social"),
            ("Всего́ хоро́шего", "All the best / take care", "farewell", "conversation"),
            ("Уда́чи!", "Good luck!", "farewell", "conversation"),
            ("К сожале́нию", "Unfortunately", "hedging", "conversation"),
            ("На са́мом де́ле", "Actually / in fact", "hedging", "conversation"),
            ("Мне всё равно́", "I don't care / it's all the same to me", "opinion", "conversation"),
        ]

        for entry in phrases {
            let p = PhraseEntry(context: viewContext)
            p.id = UUID()
            p.phrase = entry.0
            p.translation = entry.1
            p.context = entry.2
            p.source = entry.3
            p.dateAdded = Date()
        }
    }

    // MARK: - Grammar Notes

    private func seedGrammar() {
        let notes: [(String, String, String)] = [
            ("The Case System",
             "Russian has 6 grammatical cases:\n\n• **Nominative** (кто? что?) — subject\n• **Genitive** (кого́? чего́?) — possession, negation, quantity\n• **Dative** (кому́? чему́?) — indirect object, recipient\n• **Accusative** (кого́? что?) — direct object, direction\n• **Instrumental** (кем? чем?) — means, tool, accompaniment\n• **Prepositional** (о ком? о чём?) — location, about\n\nExample: **дом** (house)\n• Я ви́жу **дом** (Acc — I see the house)\n• Кры́ша **до́ма** (Gen — the roof of the house)\n• Я иду́ к **до́му** (Dat — I go toward the house)\n• Я пишу́ **до́мом** (Ins — I write with the house? nonsense!)\n• Мы говори́м о **до́ме** (Prep — we talk about the house)\n\n💡 **Real-world tip**: You'll use Genitive the most (possession, numbers, negation). Focus there first.",
             "Case"),

            ("Genitive Case Deep Dive",
             "The Genitive answers **кого́? чего́?** (of whom? of what?).\n\n**When to use it:**\n1. **Possession**: кни́га бра́та (brother's book)\n2. **Negation**: У меня́ нет вре́мени (I don't have time)\n3. **Quantity (2-4)**: два ча́са (two hours)\n4. **Quantity (5+)**: пять часо́в (five hours) — note the plural genitive!\n5. **After prepositions**: у, без, для, до, по́сле, о́коло, из, от\n\n**Ending changes — masculine:** -а/-я → -а/-я (стол → стола́)\n**Ending changes — feminine:** -а/-я → -ы/-и (кни́га → кни́ги)\n**Ending changes — neuter:** -о/-е → -а/-я (окно́ → окна́)\n\n💡 **Why this matters**: Without genitive, you can't say \"I don't have...\", \"a lot of...\", or \"from...\" — extremely common patterns.",
             "Case"),

            ("Verb Aspects",
             "Every Russian verb is a pair: **imperfective** (process) and **perfective** (result).\n\n**Imperfective** (что де́лать?): ongoing, repeated, habitual, name of action\n• Я чита́л кни́гу (I was reading a book)\n• Я ча́сто чиста́ю (I often read)\n\n**Perfective** (что сде́лать?): completed result, one-time action\n• Я прочита́л кни́гу (I read/finished the book)\n• Я прочита́ю э́то за́втра (I'll finish reading it tomorrow)\n\n**How they're formed:** prefix added to imperfective\n• чита́ть → **про**чита́ть (read)\n• писа́ть → **на**писа́ть (write)\n• де́лать → **с**де́лать (do)\n• учи́ть → **вы́**учить (learn)\n\n💡 **Real-world**: If you say \"Я чита́л кни́гу\" it implies you didn't necessarily finish. If you say \"Я прочита́л кни́гу\" it means you finished it. Big difference in meaning!",
             "Verb"),

            ("Motion Verbs",
             "Russian has a famously complex system for verbs of motion:\n\n**Unidirectional (one direction, once)**:\n• идти́ — to go on foot (right now, going somewhere)\n• е́хать — to go by vehicle (right now, going somewhere)\n\n**Multidirectional (return trip, general, habitual)**:\n• ходи́ть — to go on foot (in general, there and back)\n• е́здить — to go by vehicle (in general, there and back)\n\n**Examples:**\n• Сейча́с я иду́ в магази́н (Now I'm going to the store — one way)\n• Я хожу́ в шко́лу ка́ждый день (I go to school every day — habitual)\n• Вчера́ я ходи́л к врачу́ (Yesterday I went to the doctor — there and back)\n\n💡 **Use unidirectional when**: going right now, one direction, one-time\n💡 **Use multidirectional when**: round trip, habit, general ability, past tense return trips",
             "Verb"),

            ("Prepositions & Their Cases",
             "Each preposition demands a specific case. No exceptions — you must memorize.\n\n| Preposition | Case | Meaning |\n|------------|------|--------|\n| в | Prep | in, at (location) |\n| в | Acc | into (direction) |\n| на | Prep | on, at (location) |\n| на | Acc | onto (direction) |\n| с | Gen | from, off of |\n| с | Ins | with (accompaniment) |\n| у | Gen | near, at someone's |\n| к | Dat | toward, to (a person) |\n| о | Prep | about |\n| без | Gen | without |\n| для | Gen | for |\n| по́сле | Gen | after |\n\n**Examples:**\n• Я в магази́не (I'm in the store — Prep)\n• Я иду́ в магази́н (I'm going to the store — Acc)\n• Я с дру́гом (I'm with a friend — Ins)\n• Я из магази́на (I'm from the store — Gen)\n\n💡 **Самое важное**: в/на use Prep for WHERE, Acc for WHERE TO. Mix them up and you'll confuse everyone!",
             "Preposition"),

            ("Gender of Nouns",
             "Russian nouns have 3 genders. You can usually tell from the dictionary form:\n\n**Masculine**: ends in a consonant or -й\n• стол (table), дом (house), чай (tea), музе́й (museum)\n• Some people-words end in -а/я: па́па, дя́дя, де́душка\n\n**Feminine**: ends in -а/-я or -ь\n• кни́га (book), неде́ля (week), ночь (night), жизнь (life)\n• Soft sign (-ь) feminines must be memorized\n\n**Neuter**: ends in -о/-е or -мя\n• окно́ (window), мо́ре (sea), вре́мя (time), и́мя (name)\n\n💡 **Why it matters**: Adjectives, past tense verbs, and pronouns all change based on gender. \"Мой но́вый стол\" (my new table — masculine) vs \"Моя́ но́вая кни́га\" (my new book — feminine).",
             "Noun"),

            ("Hard vs Soft Adjectives",
             "Adjectives change endings to match gender, number, and case.\n\n**Nominative endings:**\n| Gender | Hard (-ый) | Soft (-ий) |\n|--------|-----------|----------|\n| Masc | -ый/-о́й | -ий |\n| Fem | -ая | -яя |\n| Neut | -ое | -ее |\n| Plural | -ые | -ие |\n\n**Rule**: After к, г, х, ж, ч, ш, щ — always use soft (-ий, -ая, etc.)\n\n**Examples:**\n• но́вый → но́вая кни́га, но́вое окно́, но́вые столы́\n• ру́сский → ру́сская, ру́сское, ру́сские\n• хоро́ший → хоро́шая, хоро́шее, хоро́шие\n• большо́й → больша́я, большо́е, больши́е\n\n💡 **Stress**: Some adjectives shift stress (большо́й → больша́я) — listen carefully for the accent!",
             "Adjective"),

            ("Counting & Numbers",
             "Numbers in Russian affect the noun that follows:\n\n**1** + Nominative singular: оди́н час (one hour)\n**2-4** + Genitive singular: два ча́са (two hours)\n**5-20** + Genitive plural: пять часо́в (five hours)\n**Compound numbers**: follow the LAST digit: два́дцать оди́н час (21 hours), два́дцать два ча́са (22 hours), два́дцать пять часо́в (25 hours)\n\n**2, 3, 4 have gendered forms**:\n• два (m/n), две (f): два сто́ла, две кни́ги\n• три, четы́ре (no gender distinction)\n\n💡 **This trips up even advanced learners!** Get comfortable with it — you'll use it every time you count or buy anything.",
             "Noun"),

            ("Reflexive Verbs (-ся)",
             "Verbs ending in -ся/-сь are reflexive — the action points back to the subject.\n\n**Meanings**:\n1. **Self-directed**: мы́ться (to wash oneself), одева́ться (to dress oneself)\n2. **Mutual**: встреча́ться (to meet each other), целова́ться (to kiss each other)\n3. **Passive**: Дом стро́ится (The house is being built)\n4. **Fixed expressions**: нра́виться (to be liked → to like), учи́ться (to study)\n\n**Grammar note**: -ся is added after consonants, -сь after vowels:\n• Я мо́юсь (I wash myself) — after vowel → -сь\n• Он мо́ется (He washes himself) — after consonant → -ся\n\n💡 **Мне нра́вится** = I like it (literally: \"it is pleasing to me\"). The thing you like is the subject! This is a very Russian way of thinking.",
             "Verb"),

            ("Идти vs Ходить vs Ехать vs Ездить",
             "The four most important motion verbs — master these first!\n\n**On foot:**\n• **идти́** — going on foot now, one direction: Я иду́ домо́й (I'm walking home)\n• **ходи́ть** — walk in general, round trips: Я хожу́ в шко́лу (I walk to school every day)\n\n**By transport:**\n• **е́хать** — going by vehicle now, one direction: Я е́ду на рабо́ту (I'm driving to work)\n• **е́здить** — travel by vehicle in general: Я е́зжу в Москву́ ча́сто (I go to Moscow often)\n\n**Past tense tells the story:**\n• Я шёл по у́лице (I was walking along the street — process)\n• Я сходи́л в магази́н (I went to the store and came back — round trip complete!)\n• Я е́здил в Росси́ю (I went to Russia — and came back)\n\n💡 **Mental model**: If you returned, use multidirectional (ходи́л/е́здил). If you went and stayed there, use unidirectional (шёл/е́хал).",
             "Verb"),

            ("The Particle же",
             "**Же** (or ж) is untranslatable but essential. It adds emphasis — like \"but\" or \"after all\" or \"the very same.\"\n\n**Uses:**\n1. **Contrast**: Я же говори́л! (But I told you! / I did say that!)\n2. **Identity**: Така́я же (the same kind), Тот же (the same one)\n3. **Softer requests**: Иди́ же сюда́! (Come here, would you?)\n4. **After all / actually**: Сего́дня же пятница! (But it's Friday today! — as a reason to relax)\n\n💡 **No direct translation** — listen for it in native speech and you'll hear it everywhere. It's one of those words that makes your Russian sound natural.",
             "Expression"),
        ]

        for entry in notes {
            let n = GrammarNote(context: viewContext)
            n.id = UUID()
            n.title = entry.0
            n.content = entry.1
            n.category = entry.2
            n.dateAdded = Date()
        }
    }
}
