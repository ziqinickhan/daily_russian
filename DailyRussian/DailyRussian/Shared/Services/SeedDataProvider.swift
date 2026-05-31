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
        let caseForms: String?   // JSON: noun declensions
        let conjugation: String?  // JSON: verb conjugations
        let note: String?
    }

    private func seedWords() {
        let words: [WordSeed] = [
            // MARK: Greetings & Politeness
            WordSeed(word: "приве́т", translation: "hello / hi", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "здра́вствуйте", translation: "hello (formal)", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "до́брое у́тро", translation: "good morning", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "до́брый день", translation: "good afternoon", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "до́брый ве́чер", translation: "good evening", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "до свида́ния", translation: "goodbye", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "пока́", translation: "bye (informal)", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "споко́йной но́чи", translation: "good night", partOfSpeech: "greeting", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "как дела́?", translation: "how are things?", partOfSpeech: "phrase", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ничего́", translation: "nothing / so-so", partOfSpeech: "expression", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "норма́льно", translation: "fine / okay", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "хорошо́", translation: "good / well", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "отли́чно", translation: "great / excellent", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "спаси́бо", translation: "thank you", partOfSpeech: "expression", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "большо́е спаси́бо", translation: "thank you very much", partOfSpeech: "expression", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "пожа́луйста", translation: "please / you're welcome", partOfSpeech: "expression", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "извини́те", translation: "excuse me / sorry", partOfSpeech: "expression", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "прости́те", translation: "I'm sorry (formal)", partOfSpeech: "expression", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ничего́ стра́шного", translation: "it's okay / no worries", partOfSpeech: "expression", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "да", translation: "yes", partOfSpeech: "particle", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "нет", translation: "no / not", partOfSpeech: "particle", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "коне́чно", translation: "of course", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "может быть", translation: "maybe", partOfSpeech: "expression", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),

            // MARK: People & Family
            WordSeed(word: "челове́к", translation: "person", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"pl_nom":"лю́ди","pl_gen":"люде́й","pl_dat":"лю́дям"}"#, conjugation: nil, note: "irregular plural"),
            WordSeed(word: "лю́ди", translation: "people", partOfSpeech: "noun pl", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "друг", translation: "friend (male)", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"gen":"дру́га","dat":"дру́гу","acc":"дру́га","ins":"дру́гом","prep":"дру́ге","pl_nom":"друзья́"}"#, conjugation: nil, note: "pl: друзья́"),
            WordSeed(word: "подру́га", translation: "friend (female)", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"gen":"подру́ги","dat":"подру́ге","acc":"подру́гу","ins":"подру́гой","prep":"подру́ге"}"#, conjugation: nil, note: nil),
            WordSeed(word: "мужчи́на", translation: "man", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "мужчи́на", "ген": "мужчи́ны", "дат": "мужчи́не", "акк": "мужчи́ну", "инс": "мужчи́ной,  мужчи́ною", "пре": "мужчи́не", "мн_ном": "мужчи́ны", "мн_ген": "мужчи́н", "мн_дат": "мужчи́нам", "мн_акк": "мужчи́н", "мн_инс": "мужчи́нами", "мн_пре": "мужчи́нах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "же́нщина", translation: "woman", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "же́нщина", "ген": "же́нщины", "дат": "же́нщине", "акк": "же́нщину", "инс": "же́нщиной, же́нщиною", "пре": "же́нщине", "мн_ном": "же́нщины", "мн_ген": "же́нщин", "мн_дат": "же́нщинам", "мн_акк": "же́нщин", "мн_инс": "же́нщинами", "мн_пре": "же́нщинах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ма́льчик", translation: "boy", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "ма́льчик", "ген": "ма́льчика", "дат": "ма́льчику", "акк": "ма́льчика", "инс": "ма́льчиком", "пре": "ма́льчике", "мн_ном": "ма́льчики", "мн_ген": "ма́льчиков", "мн_дат": "ма́льчикам", "мн_акк": "ма́льчиков", "мн_инс": "ма́льчиками", "мн_пре": "ма́льчиках"}"#, conjugation: nil, note: nil),
            WordSeed(word: "де́вочка", translation: "girl", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "де́вочка", "ген": "де́вочки", "дат": "де́вочке", "акк": "де́вочку", "инс": "де́вочкой, де́вочкою", "пре": "де́вочке", "мн_ном": "де́вочки", "мн_ген": "де́вочек", "мн_дат": "де́вочкам", "мн_акк": "де́вочек", "мн_инс": "де́вочками", "мн_пре": "де́вочках"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ребёнок", translation: "child", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"pl_nom":"де́ти","pl_gen":"дете́й","pl_dat":"де́тям"}"#, conjugation: nil, note: "irregular pl: де́ти"),
            WordSeed(word: "мать", translation: "mother", partOfSpeech: "noun f", difficulty: 3, caseForms: #"{"gen":"ма́тери","dat":"ма́тери","ins":"ма́терью","prep":"ма́тери"}"#, conjugation: nil, note: "-ь stem noun"),
            WordSeed(word: "семья́", translation: "family", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "семья́", "ген": "семьи́", "дат": "семье́", "акк": "семью́", "инс": "семьёй, семьёю", "пре": "семье́", "мн_ном": "се́мьи", "мн_ген": "семе́й", "мн_дат": "се́мьям", "мн_акк": "се́мьи", "мн_инс": "се́мьями", "мн_пре": "се́мьях"}"#, conjugation: nil, note: nil),
            WordSeed(word: "роди́тели", translation: "parents", partOfSpeech: "noun pl", difficulty: 2, caseForms: #"{"мн_ном": "роди́тели", "мн_ген": "роди́телей", "мн_дат": "роди́телям", "мн_акк": "роди́телей", "мн_инс": "роди́телями", "мн_пре": "роди́телях"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ма́ма", translation: "mom", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "ма́ма", "ген": "ма́мы", "дат": "ма́ме", "акк": "ма́му", "инс": "ма́мой,   ма́мою", "пре": "ма́ме", "мн_ном": "ма́мы", "мн_ген": "ма́м", "мн_дат": "ма́мам", "мн_акк": "ма́м", "мн_инс": "ма́мами", "мн_пре": "ма́мах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "па́па", translation: "dad", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "па́па", "ген": "па́пы", "дат": "па́пе", "акк": "па́пу", "инс": "па́пой, па́пою", "пре": "па́пе", "мн_ном": "па́пы", "мн_ген": "па́п", "мн_дат": "па́пам", "мн_акк": "па́п", "мн_инс": "па́пами", "мн_пре": "па́пах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "брат", translation: "brother", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"gen":"бра́та","dat":"бра́ту","acc":"бра́та","ins":"бра́том","prep":"бра́те","pl_nom":"бра́тья"}"#, conjugation: nil, note: "pl: бра́тья"),
            WordSeed(word: "сестра́", translation: "sister", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"gen":"сестры́","dat":"сестре́","acc":"сестру́","ins":"сестро́й","prep":"сестре́","pl_nom":"сёстры"}"#, conjugation: nil, note: "pl: сёстры, gen pl: сестёр"),
            WordSeed(word: "сын", translation: "son", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"gen":"сы́на","dat":"сы́ну","pl_nom":"сыновья́"}"#, conjugation: nil, note: "pl: сыновья́"),
            WordSeed(word: "дочь", translation: "daughter", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"gen":"до́чери","dat":"до́чери","ins":"до́черью","pl_nom":"до́чери"}"#, conjugation: nil, note: "irregular, -ь ending"),
            WordSeed(word: "муж", translation: "husband", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"gen":"му́жа","pl_nom":"мужья́"}"#, conjugation: nil, note: "pl: мужья́"),
            WordSeed(word: "жена́", translation: "wife", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"gen":"жены́","dat":"жене́","acc":"жену́","ins":"жено́й","prep":"жене́","pl_nom":"жёны"}"#, conjugation: nil, note: nil),
            WordSeed(word: "и́мя", translation: "name", partOfSpeech: "noun n", difficulty: 1, caseForms: #"{"gen":"и́мени","dat":"и́мени","ins":"и́менем","prep":"и́мени"}"#, conjugation: nil, note: "neuter -мя noun, irregular"),

            // MARK: Verbs — Essential
            WordSeed(word: "быть", translation: "to be", partOfSpeech: "verb impf", difficulty: 1, caseForms: nil, conjugation: #"{"я": "есть", "ты": "есть", "он": "есть", "мы": "есть", "вы": "есть", "они": "есть", "он(пр)": "бы́л", "она(пр)": "была́", "оно(пр)": "бы́ло", "они(пр)": "бы́ли"}"#, note: nil),
            WordSeed(word: "говори́ть", translation: "to speak", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "говорю́", "ты": "говори́шь", "он": "говори́т", "мы": "говори́м", "вы": "говори́те", "они": "говоря́т", "он(пр)": "говори́л", "она(пр)": "говори́ла", "оно(пр)": "говори́ло", "они(пр)": "говори́ли"}"#, note: nil),
            WordSeed(word: "сказа́ть", translation: "to say (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "знать", translation: "to know", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "зна́ю", "ты": "зна́ешь", "он": "зна́ет", "мы": "зна́ем", "вы": "зна́ете", "они": "зна́ют", "он(пр)": "зна́л", "она(пр)": "зна́ла", "оно(пр)": "зна́ло", "они(пр)": "зна́ли"}"#, note: nil),
            WordSeed(word: "понима́ть", translation: "to understand", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "понима́ю", "ты": "понима́ешь", "он": "понима́ет", "мы": "понима́ем", "вы": "понима́ете", "они": "понима́ют", "он(пр)": "понима́л", "она(пр)": "понима́ла", "оно(пр)": "понима́ло", "они(пр)": "понима́ли"}"#, note: nil),
            WordSeed(word: "ду́мать", translation: "to think", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "ду́маю", "ты": "ду́маешь", "он": "ду́мает", "мы": "ду́маем", "вы": "ду́маете", "они": "ду́мают", "он(пр)": "ду́мал", "она(пр)": "ду́мала", "оно(пр)": "ду́мало", "они(пр)": "ду́мали"}"#, note: nil),
            WordSeed(word: "хоте́ть", translation: "to want", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "хочу́", "ты": "хо́чешь", "он": "хо́чет", "мы": "хоти́м", "вы": "хоти́те", "они": "хотя́т", "он(пр)": "хоте́л", "она(пр)": "хоте́ла", "оно(пр)": "хоте́ло", "они(пр)": "хоте́ли"}"#, note: nil),
            WordSeed(word: "люби́ть", translation: "to love", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "люблю́", "ты": "лю́бишь", "он": "лю́бит", "мы": "лю́бим", "вы": "лю́бите", "они": "лю́бят", "он(пр)": "люби́л", "она(пр)": "люби́ла", "оно(пр)": "люби́ло", "они(пр)": "люби́ли"}"#, note: nil),
            WordSeed(word: "жить", translation: "to live", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "живу́", "ты": "живёшь", "он": "живёт", "мы": "живём", "вы": "живёте", "они": "живу́т", "он(пр)": "жи́л", "она(пр)": "жила́", "оно(пр)": "жи́ло,жило́", "они(пр)": "жи́ли"}"#, note: nil),
            WordSeed(word: "рабо́тать", translation: "to work", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "рабо́таю", "ты": "рабо́таешь", "он": "рабо́тает", "мы": "рабо́таем", "вы": "рабо́таете", "они": "рабо́тают", "он(пр)": "рабо́тал", "она(пр)": "рабо́тала", "оно(пр)": "рабо́тало", "они(пр)": "рабо́тали"}"#, note: nil),
            WordSeed(word: "де́лать", translation: "to do / make", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "де́лаю", "ты": "де́лаешь", "он": "де́лает", "мы": "де́лаем", "вы": "де́лаете", "они": "де́лают", "он(пр)": "де́лал", "она(пр)": "де́лала", "оно(пр)": "де́лало", "они(пр)": "де́лали"}"#, note: nil),
            WordSeed(word: "сде́лать", translation: "to do / make (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ви́деть", translation: "to see", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "ви́жу", "ты": "ви́дишь", "он": "ви́дит", "мы": "ви́дим", "вы": "ви́дите", "они": "ви́дят", "он(пр)": "ви́дел", "она(пр)": "ви́дела", "оно(пр)": "ви́дело", "они(пр)": "ви́дели"}"#, note: nil),
            WordSeed(word: "уви́деть", translation: "to see (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "слы́шать", translation: "to hear", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "слы́шу", "ты": "слы́шишь", "он": "слы́шит", "мы": "слы́шим", "вы": "слы́шите", "они": "слы́шат", "он(пр)": "слы́шал", "она(пр)": "слы́шала", "оно(пр)": "слы́шало", "они(пр)": "слы́шали"}"#, note: nil),
            WordSeed(word: "идти́", translation: "to go (on foot)", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ходи́ть", translation: "to go (on foot, multi)", partOfSpeech: "verb impf", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "е́хать", translation: "to go (by vehicle)", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "е́здить", translation: "to go (by vehicle, multi)", partOfSpeech: "verb impf", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "чита́ть", translation: "to read", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "чита́ю", "ты": "чита́ешь", "он": "чита́ет", "мы": "чита́ем", "вы": "чита́ете", "они": "чита́ют", "он(пр)": "чита́л", "она(пр)": "чита́ла", "оно(пр)": "чита́ло", "они(пр)": "чита́ли"}"#, note: nil),
            WordSeed(word: "писа́ть", translation: "to write", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "пишу́", "ты": "пи́шешь", "он": "пи́шет", "мы": "пи́шем", "вы": "пи́шете", "они": "пи́шут", "он(пр)": "писа́л", "она(пр)": "писа́ла", "оно(пр)": "писа́ло", "они(пр)": "писа́ли"}"#, note: nil),
            WordSeed(word: "есть", translation: "to eat", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "е́м", "ты": "е́шь", "он": "е́ст", "мы": "еди́м", "вы": "еди́те", "они": "едя́т", "он(пр)": "е́л", "она(пр)": "е́ла", "оно(пр)": "е́ло", "они(пр)": "е́ли"}"#, note: nil),
            WordSeed(word: "пить", translation: "to drink", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "пью́", "ты": "пьёшь", "он": "пьёт", "мы": "пьём", "вы": "пьёте", "они": "пью́т", "он(пр)": "пи́л", "она(пр)": "пила́", "оно(пр)": "пи́ло", "они(пр)": "пи́ли"}"#, note: nil),
            WordSeed(word: "спать", translation: "to sleep", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "сплю́", "ты": "спи́шь", "он": "спи́т", "мы": "спи́м", "вы": "спи́те", "они": "спя́т", "он(пр)": "спа́л", "она(пр)": "спала́", "оно(пр)": "спа́ло", "они(пр)": "спа́ли"}"#, note: nil),
            WordSeed(word: "брать", translation: "to take", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "беру́", "ты": "берёшь", "он": "берёт", "мы": "берём", "вы": "берёте", "они": "беру́т", "он(пр)": "бра́л", "она(пр)": "брала́", "оно(пр)": "бра́ло", "они(пр)": "бра́ли"}"#, note: nil),
            WordSeed(word: "взять", translation: "to take (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "дава́ть", translation: "to give", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "даю́", "ты": "даёшь", "он": "даёт", "мы": "даём", "вы": "даёте", "они": "даю́т", "он(пр)": "дава́л", "она(пр)": "дава́ла", "оно(пр)": "дава́ло", "они(пр)": "дава́ли"}"#, note: nil),
            WordSeed(word: "дать", translation: "to give (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "смотре́ть", translation: "to watch / look", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "смотрю́", "ты": "смо́тришь", "он": "смо́трит", "мы": "смо́трим", "вы": "смо́трите", "они": "смо́трят", "он(пр)": "смотре́л", "она(пр)": "смотре́ла", "оно(пр)": "смотре́ло", "они(пр)": "смотре́ли"}"#, note: nil),
            WordSeed(word: "посмотре́ть", translation: "to watch / look (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ждать", translation: "to wait", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "жду́", "ты": "ждёшь", "он": "ждёт", "мы": "ждём", "вы": "ждёте", "они": "жду́т", "он(пр)": "жда́л", "она(пр)": "ждала́", "оно(пр)": "жда́ло", "они(пр)": "жда́ли"}"#, note: nil),
            WordSeed(word: "стоя́ть", translation: "to stand", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "стою́", "ты": "стои́шь", "он": "стои́т", "мы": "стои́м", "вы": "стои́те", "они": "стоя́т", "он(пр)": "стоя́л", "она(пр)": "стоя́ла", "оно(пр)": "стоя́ло", "они(пр)": "стоя́ли"}"#, note: nil),

            // MARK: Food & Drink
            WordSeed(word: "во́да", translation: "water", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "вода́", "ген": "воды́", "дат": "воде́", "акк": "во́ду", "инс": "водо́й,  водо́ю", "пре": "воде́", "мн_ном": "во́ды", "мн_ген": "во́д", "мн_дат": "во́дам", "мн_акк": "во́ды", "мн_инс": "во́дами", "мн_пре": "во́дах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "хлеб", translation: "bread", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "хле́б", "ген": "хле́ба", "дат": "хле́бу", "акк": "хле́б", "инс": "хле́бом", "пре": "хле́бе", "мн_ном": "хле́бы", "мн_ген": "хле́бов", "мн_дат": "хле́бам", "мн_акк": "хле́бы", "мн_инс": "хле́бами", "мн_пре": "хле́бах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "молоко́", translation: "milk", partOfSpeech: "noun n", difficulty: 1, caseForms: #"{"ном": "молоко́", "ген": "молока́", "дат": "молоку́", "акк": "молоко́", "инс": "молоко́м", "пре": "молоке́"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ко́фе", translation: "coffee", partOfSpeech: "noun m", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "чай", translation: "tea", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "ча́й", "ген": "ча́я", "дат": "ча́ю", "акк": "ча́й", "инс": "ча́ем", "пре": "ча́е", "мн_ном": "чаи́", "мн_ген": "чаёв", "мн_дат": "чая́м", "мн_акк": "чаи́", "мн_инс": "чая́ми", "мн_пре": "чая́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "са́хар", translation: "sugar", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "са́хар", "ген": "са́хара", "дат": "са́хару", "акк": "са́хар", "инс": "са́харом", "пре": "са́харе", "мн_ном": "сахара́", "мн_ген": "сахаро́в", "мн_дат": "сахара́м", "мн_акк": "сахара́", "мн_инс": "сахара́ми", "мн_пре": "сахара́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "соль", translation: "salt", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "со́ль", "ген": "со́ли", "дат": "со́ли", "акк": "со́ль", "инс": "со́лью", "пре": "со́ли", "мн_ном": "со́ли", "мн_ген": "соле́й", "мн_дат": "соля́м", "мн_акк": "со́ли", "мн_инс": "соля́ми", "мн_пре": "соля́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "мя́со", translation: "meat", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "мя́со", "ген": "мя́са", "дат": "мя́су", "акк": "мя́со", "инс": "мя́сом", "пре": "мя́се", "мн_ном": "мя́са", "мн_ген": "мя́с", "мн_дат": "мя́сам", "мн_акк": "мя́са", "мн_инс": "мя́сами", "мн_пре": "мя́сах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ры́ба", translation: "fish", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "ры́ба", "ген": "ры́бы", "дат": "ры́бе", "акк": "ры́бу", "инс": "ры́бой, ры́бою", "пре": "ры́бе", "мн_ном": "ры́бы", "мн_ген": "ры́б", "мн_дат": "ры́бам", "мн_акк": "ры́б", "мн_инс": "ры́бами", "мн_пре": "ры́бах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ку́рица", translation: "chicken", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "ку́рица", "ген": "ку́рицы", "дат": "ку́рице", "акк": "ку́рицу", "инс": "ку́рицей, ку́рицею", "пре": "ку́рице", "мн_ном": "ку́ры", "мн_ген": "ку́р", "мн_дат": "ку́рам", "мн_акк": "ку́р", "мн_инс": "ку́рами", "мн_пре": "ку́рах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "яйцо́", translation: "egg", partOfSpeech: "noun n", difficulty: 1, caseForms: #"{"ном": "яйцо́", "ген": "яйца́", "дат": "яйцу́", "акк": "яйцо́", "инс": "яйцо́м", "пре": "яйце́", "мн_ном": "я́йца", "мн_ген": "яи́ц", "мн_дат": "я́йцам", "мн_акк": "я́йца", "мн_инс": "я́йцами", "мн_пре": "я́йцах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "суп", translation: "soup", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "су́п", "ген": "су́па", "дат": "су́пу", "акк": "су́п", "инс": "су́пом", "пре": "су́пе", "мн_ном": "супы́", "мн_ген": "супо́в", "мн_дат": "супа́м", "мн_акк": "супы́", "мн_инс": "супа́ми", "мн_пре": "супа́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "сыр", translation: "cheese", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "сы́р", "ген": "сы́ра", "дат": "сы́ру", "акк": "сы́р", "инс": "сы́ром", "пре": "сы́ре", "мн_ном": "сыры́", "мн_ген": "сыро́в", "мн_дат": "сыра́м", "мн_акк": "сыры́", "мн_инс": "сыра́ми", "мн_пре": "сыра́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ма́сло", translation: "butter / oil", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "ма́сло", "ген": "ма́сла", "дат": "ма́слу", "акк": "ма́сло", "инс": "ма́слом", "пре": "ма́сле", "мн_ном": "масла́", "мн_ген": "ма́сел", "мн_дат": "масла́м", "мн_акк": "масла́", "мн_инс": "масла́ми", "мн_пре": "масла́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "фру́кты", translation: "fruit", partOfSpeech: "noun pl", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "о́вощи", translation: "vegetables", partOfSpeech: "noun pl", difficulty: 2, caseForms: #"{"мн_ном": "о́вощи", "мн_ген": "овоще́й", "мн_дат": "овоща́м", "мн_акк": "о́вощи", "мн_инс": "овоща́ми", "мн_пре": "овоща́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "карто́шка", translation: "potato", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "карто́шка", "ген": "карто́шки", "дат": "карто́шке", "акк": "карто́шку", "инс": "карто́шкой, карто́шкою", "пре": "карто́шке", "мн_ном": "карто́шки", "мн_ген": "карто́шек", "мн_дат": "карто́шкам", "мн_акк": "карто́шки", "мн_инс": "карто́шками", "мн_пре": "карто́шках"}"#, conjugation: nil, note: nil),
            WordSeed(word: "рис", translation: "rice", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "ри́с", "ген": "ри́са", "дат": "ри́су", "акк": "ри́с", "инс": "ри́сом", "пре": "ри́се", "мн_ном": "ри́сы", "мн_ген": "ри́сов", "мн_дат": "ри́сам", "мн_акк": "ри́сы", "мн_инс": "ри́сами", "мн_пре": "ри́сах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "за́втрак", translation: "breakfast", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "за́втрак", "ген": "за́втрака", "дат": "за́втраку", "акк": "за́втрак", "инс": "за́втраком", "пре": "за́втраке", "мн_ном": "за́втраки", "мн_ген": "за́втраков", "мн_дат": "за́втракам", "мн_акк": "за́втраки", "мн_инс": "за́втраками", "мн_пре": "за́втраках"}"#, conjugation: nil, note: nil),
            WordSeed(word: "обе́д", translation: "lunch", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "обе́д", "ген": "обе́да", "дат": "обе́ду", "акк": "обе́д", "инс": "обе́дом", "пре": "обе́де", "мн_ном": "обе́ды", "мн_ген": "обе́дов", "мн_дат": "обе́дам", "мн_акк": "обе́ды", "мн_инс": "обе́дами", "мн_пре": "обе́дах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "у́жин", translation: "dinner", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "ужи́н", "ген": "ужи́на", "дат": "ужи́ну", "акк": "ужи́н", "инс": "ужи́ном", "пре": "ужи́не", "мн_ном": "ужи́ны", "мн_ген": "ужи́нов", "мн_дат": "ужи́нам", "мн_акк": "ужи́ны", "мн_инс": "ужи́нами", "мн_пре": "ужи́нах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "вку́сно", translation: "tasty / delicious", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),

            // MARK: Places & Directions
            WordSeed(word: "дом", translation: "house / home", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "до́м", "ген": "до́ма", "дат": "до́му", "акк": "до́м", "инс": "до́мом", "пре": "до́ме", "мн_ном": "дома́", "мн_ген": "домо́в", "мн_дат": "дома́м", "мн_акк": "дома́", "мн_инс": "дома́ми", "мн_пре": "дома́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "до́ма", translation: "at home", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "рабо́та", translation: "work / job", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "рабо́та", "ген": "рабо́ты", "дат": "рабо́те", "акк": "рабо́ту", "инс": "рабо́той,  рабо́тою", "пре": "рабо́те", "мн_ном": "рабо́ты", "мн_ген": "рабо́т", "мн_дат": "рабо́там", "мн_акк": "рабо́ты", "мн_инс": "рабо́тами", "мн_пре": "рабо́тах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "шко́ла", translation: "school", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "шко́ла", "ген": "шко́лы", "дат": "шко́ле", "акк": "шко́лу", "инс": "шко́лой, шко́лою", "пре": "шко́ле", "мн_ном": "шко́лы", "мн_ген": "шко́л", "мн_дат": "шко́лам", "мн_акк": "шко́лы", "мн_инс": "шко́лами", "мн_пре": "шко́лах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "магази́н", translation: "shop / store", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "магази́н", "ген": "магази́на", "дат": "магази́ну", "акк": "магази́н", "инс": "магази́ном", "пре": "магази́не", "мн_ном": "магази́ны", "мн_ген": "магази́нов", "мн_дат": "магази́нам", "мн_акк": "магази́ны", "мн_инс": "магази́нами", "мн_пре": "магази́нах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "рестора́н", translation: "restaurant", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "рестора́н", "ген": "рестора́на", "дат": "рестора́ну", "акк": "рестора́н", "инс": "рестора́ном", "пре": "рестора́не", "мн_ном": "рестора́ны", "мн_ген": "рестора́нов", "мн_дат": "рестора́нам", "мн_акк": "рестора́ны", "мн_инс": "рестора́нами", "мн_пре": "рестора́нах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "у́лица", translation: "street", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "у́лица", "ген": "у́лицы", "дат": "у́лице", "акк": "у́лицу", "инс": "у́лицей, у́лицею", "пре": "у́лице", "мн_ном": "у́лицы", "мн_ген": "у́лиц", "мн_дат": "у́лицам", "мн_акк": "у́лицы", "мн_инс": "у́лицами", "мн_пре": "у́лицах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "доро́га", translation: "road", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "доро́га", "ген": "доро́ги", "дат": "доро́ге", "акк": "доро́гу", "инс": "доро́гой, доро́гою", "пре": "доро́ге", "мн_ном": "доро́ги", "мн_ген": "доро́г", "мн_дат": "доро́гам", "мн_акк": "доро́ги", "мн_инс": "доро́гами", "мн_пре": "доро́гах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "го́род", translation: "city", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "го́род", "ген": "го́рода", "дат": "го́роду", "акк": "го́род", "инс": "го́родом", "пре": "го́роде", "мн_ном": "города́", "мн_ген": "городо́в", "мн_дат": "города́м", "мн_акк": "города́", "мн_инс": "города́ми", "мн_пре": "города́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "страна́", translation: "country", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "страна́", "ген": "страны́", "дат": "стране́", "акк": "страну́", "инс": "страно́й, страно́ю", "пре": "стране́", "мн_ном": "стра́ны", "мн_ген": "стра́н", "мн_дат": "стра́нам", "мн_акк": "стра́ны", "мн_инс": "стра́нами", "мн_пре": "стра́нах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "Москва́", translation: "Moscow", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "Москва́", "ген": "Москвы́", "дат": "Москве́", "акк": "Москву́", "инс": "Москво́й,  Москво́ю", "пре": "Москве́"}"#, conjugation: nil, note: nil),
            WordSeed(word: "Росси́я", translation: "Russia", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "Росси́я", "ген": "Росси́и", "дат": "Росси́и", "акк": "Росси́ю", "инс": "Росси́ей,   Росси́ею", "пре": "Росси́и"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ме́сто", translation: "place", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "ме́сто", "ген": "ме́ста", "дат": "ме́сту", "акк": "ме́сто", "инс": "ме́стом", "пре": "ме́сте", "мн_ном": "места́", "мн_ген": "ме́ст", "мн_дат": "места́м", "мн_акк": "места́", "мн_инс": "места́ми", "мн_пре": "места́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "здесь", translation: "here", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "там", translation: "there", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "пря́мо", translation: "straight ahead", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "нале́во", translation: "to the left", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "напра́во", translation: "to the right", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ря́дом", translation: "nearby", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "далеко́", translation: "far", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),

            // MARK: Time
            WordSeed(word: "сего́дня", translation: "today", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "за́втра", translation: "tomorrow", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "вчера́", translation: "yesterday", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "сейча́с", translation: "now", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "пото́м", translation: "later / then", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "всегда́", translation: "always", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "иногда́", translation: "sometimes", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "никогда́", translation: "never", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ча́сто", translation: "often", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "у́тро", translation: "morning", partOfSpeech: "noun n", difficulty: 1, caseForms: #"{"ном": "у́тро", "ген": "у́тра, утра́", "дат": "у́тру, утру́", "акк": "у́тро", "инс": "у́тром", "пре": "у́тре", "мн_ном": "у́тра", "мн_ген": "утр", "мн_дат": "у́трам, утра́м", "мн_акк": "у́тра", "мн_инс": "у́трами, утра́ми", "мн_пре": "у́трах, утра́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "день", translation: "day", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "день", "ген": "дня", "дат": "дню", "акк": "день", "инс": "днём", "пре": "дне", "мн_ном": "дни", "мн_ген": "дне́й", "мн_дат": "дня́м", "мн_акк": "дни", "мн_инс": "дня́ми", "мн_пре": "днях"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ве́чер", translation: "evening", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "ве́чер", "ген": "ве́чера", "дат": "ве́черу", "акк": "ве́чер", "инс": "ве́чером", "пре": "ве́чере", "мн_ном": "вечера́", "мн_ген": "вечеро́в", "мн_дат": "вечера́м", "мн_акк": "вечера́", "мн_инс": "вечера́ми", "мн_пре": "вечера́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ночь", translation: "night", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "но́чь", "ген": "но́чи", "дат": "но́чи", "акк": "но́чь", "инс": "но́чью", "пре": "но́чи", "мн_ном": "но́чи", "мн_ген": "ноче́й", "мн_дат": "ноча́м", "мн_акк": "но́чи", "мн_инс": "ноча́ми", "мн_пре": "ноча́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "вре́мя", translation: "time", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "вре́мя", "ген": "вре́мени", "дат": "вре́мени", "акк": "вре́мя", "инс": "вре́менем", "пре": "вре́мени", "мн_ном": "времена́", "мн_ген": "времён", "мн_дат": "времена́м", "мн_акк": "времена́", "мн_инс": "времена́ми", "мн_пре": "времена́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "час", translation: "hour", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "ча́с", "ген": "ча́са,    часа́", "дат": "ча́су", "акк": "ча́с", "инс": "ча́сом", "пре": "часу́, ча́се", "мн_ном": "часы́", "мн_ген": "часо́в", "мн_дат": "часа́м", "мн_акк": "часы́", "мн_инс": "часа́ми", "мн_пре": "часа́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "мину́та", translation: "minute", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "мину́та", "ген": "мину́ты", "дат": "мину́те", "акк": "мину́ту", "инс": "мину́той, мину́тою", "пре": "мину́те", "мн_ном": "мину́ты", "мн_ген": "мину́т", "мн_дат": "мину́там", "мн_акк": "мину́ты", "мн_инс": "мину́тами", "мн_пре": "мину́тах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "неде́ля", translation: "week", partOfSpeech: "noun f", difficulty: 1, caseForms: #"{"ном": "неде́ля", "ген": "неде́ли", "дат": "неде́ле", "акк": "неде́лю", "инс": "неде́лей, неде́лею", "пре": "неде́ле", "мн_ном": "неде́ли", "мн_ген": "неде́ль", "мн_дат": "неде́лям", "мн_акк": "неде́ли", "мн_инс": "неде́лями", "мн_пре": "неде́лях"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ме́сяц", translation: "month", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "ме́сяц", "ген": "ме́сяца", "дат": "ме́сяцу", "акк": "ме́сяц", "инс": "ме́сяцем", "пре": "ме́сяце", "мн_ном": "ме́сяцы", "мн_ген": "ме́сяцев", "мн_дат": "ме́сяцам", "мн_акк": "ме́сяцы", "мн_инс": "ме́сяцами", "мн_пре": "ме́сяцах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "год", translation: "year", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "го́д", "ген": "го́да", "дат": "го́ду", "акк": "го́д", "инс": "го́дом", "пре": "году́", "мн_ном": "лета́", "мн_ген": "ле́т", "мн_дат": "лета́м", "мн_акк": "лета́", "мн_инс": "лета́ми", "мн_пре": "лета́х"}"#, conjugation: nil, note: nil),

            // MARK: Question Words
            WordSeed(word: "кто", translation: "who", partOfSpeech: "pronoun", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "что", translation: "what", partOfSpeech: "pronoun", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "где", translation: "where", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "куда́", translation: "where to", partOfSpeech: "adverb", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "отку́да", translation: "where from", partOfSpeech: "adverb", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "когда́", translation: "when", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "почему́", translation: "why", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "как", translation: "how", partOfSpeech: "adverb", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ско́лько", translation: "how much / many", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "како́й", translation: "which / what kind", partOfSpeech: "pronoun", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "чей", translation: "whose", partOfSpeech: "pronoun", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),

            // MARK: Adjectives
            WordSeed(word: "хоро́ший", translation: "good", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "плохо́й", translation: "bad", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "большо́й", translation: "big", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ма́ленький", translation: "small", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "но́вый", translation: "new", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ста́рый", translation: "old", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "молодо́й", translation: "young", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "краси́вый", translation: "beautiful", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ру́сский", translation: "Russian", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ва́жный", translation: "important", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "до́брый", translation: "kind", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "пло́хо", translation: "badly", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "холодный", translation: "cold", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "тёплый", translation: "warm", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "горя́чий", translation: "hot (object)", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "бе́лый", translation: "white", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "чёрный", translation: "black", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),

            // MARK: Body & Health
            WordSeed(word: "рука́", translation: "hand / arm", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "рука́", "ген": "руки́", "дат": "руке́", "акк": "ру́ку", "инс": "руко́й", "пре": "руке́", "мн_ном": "ру́ки", "мн_ген": "ру́к", "мн_дат": "рука́м", "мн_акк": "ру́ки", "мн_инс": "рука́ми", "мн_пре": "рука́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "нога́", translation: "foot / leg", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "нога́", "ген": "ноги́", "дат": "ноге́", "акк": "но́гу", "инс": "ного́й,     ного́ю", "пре": "ноге́", "мн_ном": "но́ги", "мн_ген": "ног", "мн_дат": "нога́м", "мн_акк": "но́ги", "мн_инс": "нога́ми", "мн_пре": "нога́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "голова́", translation: "head", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "голова́", "ген": "головы́", "дат": "голове́", "акк": "го́лову", "инс": "голово́й", "пре": "голове́", "мн_ном": "го́ловы", "мн_ген": "голо́в", "мн_дат": "голова́м", "мн_акк": "го́ловы", "мн_инс": "голова́ми", "мн_пре": "голова́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "глаз", translation: "eye", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "гла́з", "ген": "гла́за", "дат": "гла́зу", "акк": "гла́з", "инс": "гла́зом", "пре": "гла́зе", "мн_ном": "глаза́", "мн_ген": "гла́з", "мн_дат": "глаза́м", "мн_акк": "глаза́", "мн_инс": "глаза́ми", "мн_пре": "глаза́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "у́хо", translation: "ear", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "у́хо", "ген": "у́ха", "дат": "у́ху", "акк": "у́хо", "инс": "у́хом", "пре": "у́хе", "мн_ном": "у́ши", "мн_ген": "уше́й", "мн_дат": "уша́м", "мн_акк": "у́ши", "мн_инс": "уша́ми", "мн_пре": "уша́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "нос", translation: "nose", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "нос", "ген": "но́са, но́су", "дат": "но́су", "акк": "нос", "инс": "но́сом", "пре": "но́се", "мн_ном": "носы́", "мн_ген": "носо́в", "мн_дат": "носа́м", "мн_акк": "носы́", "мн_инс": "носа́ми", "мн_пре": "носа́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "рот", translation: "mouth", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "ро́т", "ген": "рта́", "дат": "рту́", "акк": "ро́т", "инс": "рто́м", "пре": "рте́, рту́", "мн_ном": "рты́", "мн_ген": "рто́в", "мн_дат": "рта́м", "мн_акк": "рты́", "мн_инс": "рта́ми", "мн_пре": "рта́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "се́рдце", translation: "heart", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "се́рдце", "ген": "се́рдца", "дат": "се́рдцу", "акк": "се́рдце", "инс": "се́рдцем", "пре": "се́рдце", "мн_ном": "сердца́", "мн_ген": "серде́ц", "мн_дат": "сердца́м", "мн_акк": "сердца́", "мн_инс": "сердца́ми", "мн_пре": "сердца́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "боле́ть", translation: "to hurt / be sick", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "боле́ю", "ты": "боле́ешь", "он": "боле́ет, боли́т", "мы": "боле́ем", "вы": "боле́ете", "они": "боле́ют, боля́т", "он(пр)": "боле́л", "она(пр)": "боле́ла", "оно(пр)": "боле́ло", "они(пр)": "боле́ли"}"#, note: nil),
            WordSeed(word: "здоро́вье", translation: "health", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "здоро́вье", "ген": "здоро́вья", "дат": "здоро́вью", "акк": "здоро́вье", "инс": "здоро́вьем", "пре": "здоро́вье", "мн_ном": "здоро́вья", "мн_ген": "здоро́вий", "мн_дат": "здоро́вьям", "мн_акк": "здоро́вья", "мн_инс": "здоро́вьями", "мн_пре": "здоро́вьях"}"#, conjugation: nil, note: nil),

            // MARK: Weather & Nature
            WordSeed(word: "пого́да", translation: "weather", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "пого́да", "ген": "пого́ды", "дат": "пого́де", "акк": "пого́ду", "инс": "пого́дой,  пого́дою", "пре": "пого́де", "мн_ном": "пого́ды", "мн_ген": "пого́д", "мн_дат": "пого́дам", "мн_акк": "пого́ды", "мн_инс": "пого́дами", "мн_пре": "пого́дах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "со́лнце", translation: "sun", partOfSpeech: "noun n", difficulty: 1, caseForms: #"{"ном": "со́лнце", "ген": "со́лнца", "дат": "со́лнцу", "акк": "со́лнце", "инс": "со́лнцем", "пре": "со́лнце", "мн_ном": "со́лнца", "мн_ген": "со́лнц", "мн_дат": "со́лнцам", "мн_акк": "со́лнца", "мн_инс": "со́лнцами", "мн_пре": "со́лнцах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "дождь", translation: "rain", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "до́ждь", "ген": "дождя́", "дат": "дождю́", "акк": "до́ждь", "инс": "дождём", "пре": "дожде́", "мн_ном": "дожди́", "мн_ген": "дожде́й", "мн_дат": "дождя́м", "мн_акк": "дожди́", "мн_инс": "дождя́ми", "мн_пре": "дождя́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "снег", translation: "snow", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "сне́г", "ген": "сне́га", "дат": "сне́гу", "акк": "сне́г", "инс": "сне́гом", "пре": "сне́ге,  снегу́", "мн_ном": "снега́", "мн_ген": "снего́в", "мн_дат": "снега́м", "мн_акк": "снега́", "мн_инс": "снега́ми", "мн_пре": "снега́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ве́тер", translation: "wind", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "ве́тер", "ген": "ве́тра", "дат": "ве́тру", "акк": "ве́тер", "инс": "ве́тром", "пре": "ве́тре"}"#, conjugation: nil, note: nil),
            WordSeed(word: "хо́лодно", translation: "it's cold", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "тепло́", translation: "it's warm", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "жа́рко", translation: "it's hot", partOfSpeech: "adverb", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),

            // MARK: Clothing
            WordSeed(word: "оде́жда", translation: "clothing", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "оде́жда", "ген": "оде́жды", "дат": "оде́жде", "акк": "оде́жду", "инс": "оде́ждой, оде́ждою", "пре": "оде́жде", "мн_ном": "оде́жды", "мн_ген": "оде́жд", "мн_дат": "оде́ждам", "мн_акк": "оде́жды", "мн_инс": "оде́ждами", "мн_пре": "оде́ждах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "руба́шка", translation: "shirt", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "руба́шка", "ген": "руба́шки", "дат": "руба́шке", "акк": "руба́шку", "инс": "руба́шкой, руба́шкою", "пре": "руба́шке", "мн_ном": "руба́шки", "мн_ген": "руба́шек", "мн_дат": "руба́шкам", "мн_акк": "руба́шки", "мн_инс": "руба́шками", "мн_пре": "руба́шках"}"#, conjugation: nil, note: nil),
            WordSeed(word: "штаны́", translation: "pants", partOfSpeech: "noun pl", difficulty: 2, caseForms: #"{"мн_ном": "штаны́", "мн_ген": "штано́в", "мн_дат": "штана́м", "мн_акк": "штаны́", "мн_инс": "штана́ми", "мн_пре": "штана́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "пла́тье", translation: "dress", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "пла́тье", "ген": "пла́тья", "дат": "пла́тью", "акк": "пла́тье", "инс": "пла́тьем", "пре": "пла́тье", "мн_ном": "пла́тья", "мн_ген": "пла́тьев", "мн_дат": "пла́тьям", "мн_акк": "пла́тья", "мн_инс": "пла́тьями", "мн_пре": "пла́тьях"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ку́ртка", translation: "jacket", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "ку́ртка", "ген": "ку́ртки", "дат": "ку́ртке", "акк": "ку́ртку", "инс": "ку́рткой, ку́рткою", "пре": "ку́ртке", "мн_ном": "ку́ртки", "мн_ген": "ку́рток", "мн_дат": "ку́рткам", "мн_акк": "ку́ртки", "мн_инс": "ку́ртками", "мн_пре": "ку́ртках"}"#, conjugation: nil, note: nil),
            WordSeed(word: "ша́пка", translation: "hat", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "ша́пка", "ген": "ша́пки", "дат": "ша́пке", "акк": "ша́пку", "инс": "ша́пкой, ша́пкою", "пре": "ша́пке", "мн_ном": "ша́пки", "мн_ген": "ша́пок", "мн_дат": "ша́пкам", "мн_акк": "ша́пки", "мн_инс": "ша́пками", "мн_пре": "ша́пках"}"#, conjugation: nil, note: nil),
            WordSeed(word: "о́бувь", translation: "footwear", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "о́бувь", "ген": "о́буви", "дат": "о́буви", "акк": "о́бувь", "инс": "о́бувью", "пре": "о́буви"}"#, conjugation: nil, note: nil),

            // MARK: Technology & Modern Life
            WordSeed(word: "телефо́н", translation: "telephone", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "телефо́н", "ген": "телефо́на", "дат": "телефо́ну", "акк": "телефо́н", "инс": "телефо́ном", "пре": "телефо́не", "мн_ном": "телефо́ны", "мн_ген": "телефо́нов", "мн_дат": "телефо́нам", "мн_акк": "телефо́ны", "мн_инс": "телефо́нами", "мн_пре": "телефо́нах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "компью́тер", translation: "computer", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "компью́тер", "ген": "компью́тера", "дат": "компью́теру", "акк": "компью́тер", "инс": "компью́тером", "пре": "компью́тере", "мн_ном": "компью́теры", "мн_ген": "компью́теров", "мн_дат": "компью́терам", "мн_акк": "компью́теры", "мн_инс": "компью́терами", "мн_пре": "компью́терах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "интерне́т", translation: "internet", partOfSpeech: "noun m", difficulty: 1, caseForms: #"{"ном": "интерне́т", "ген": "интерне́та", "дат": "интерне́ту", "акк": "интерне́т", "инс": "интерне́том", "пре": "интерне́те", "мн_ном": "интерне́ты", "мн_ген": "интерне́тов", "мн_дат": "интерне́там", "мн_акк": "интерне́ты", "мн_инс": "интерне́тами", "мн_пре": "интерне́тах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "сообщ́ение", translation: "message / text", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "сообще́ние", "ген": "сообще́ния", "дат": "сообще́нию", "акк": "сообще́ние", "инс": "сообще́нием", "пре": "сообще́нии", "мн_ном": "сообще́ния", "мн_ген": "сообще́ний", "мн_дат": "сообще́ниям", "мн_акк": "сообще́ния", "мн_инс": "сообще́ниями", "мн_пре": "сообще́ниях"}"#, conjugation: nil, note: nil),
            WordSeed(word: "звони́ть", translation: "to call (on phone)", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "позвони́ть", translation: "to call (pf)", partOfSpeech: "verb pf", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "отпра́вить", translation: "to send", partOfSpeech: "verb pf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "отпра́влю", "ты": "отпра́вишь", "он": "отпра́вит", "мы": "отпра́вим", "вы": "отпра́вите", "они": "отпра́вят", "он(пр)": "отпра́вил", "она(пр)": "отпра́вила", "оно(пр)": "отпра́вило", "они(пр)": "отпра́вили"}"#, note: nil),
            WordSeed(word: "получи́ть", translation: "to receive", partOfSpeech: "verb pf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "получу́", "ты": "полу́чишь", "он": "полу́чит", "мы": "полу́чим", "вы": "полу́чите", "они": "полу́чат", "он(пр)": "получи́л", "она(пр)": "получи́ла", "оно(пр)": "получи́ло", "они(пр)": "получи́ли"}"#, note: nil),
            WordSeed(word: "фо́то", translation: "photo", partOfSpeech: "noun n", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "де́ньги", translation: "money", partOfSpeech: "noun pl", difficulty: 1, caseForms: #"{"мн_ном": "де́ньги", "мн_ген": "де́нег", "мн_дат": "деньга́м", "мн_акк": "де́ньги", "мн_инс": "деньга́ми", "мн_пре": "деньга́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "биле́т", translation: "ticket", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "биле́т", "ген": "биле́та", "дат": "биле́ту", "акк": "биле́т", "инс": "биле́том", "пре": "биле́те", "мн_ном": "биле́ты", "мн_ген": "биле́тов", "мн_дат": "биле́там", "мн_акк": "биле́ты", "мн_инс": "биле́тами", "мн_пре": "биле́тах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "па́спорт", translation: "passport", partOfSpeech: "noun m", difficulty: 2, caseForms: #"{"ном": "па́спорт", "ген": "па́спорта", "дат": "па́спорту", "акк": "па́спорт", "инс": "па́спортом", "пре": "па́спорте", "мн_ном": "паспорта́", "мн_ген": "паспорто́в", "мн_дат": "паспорта́м", "мн_акк": "паспорта́", "мн_инс": "паспорта́ми", "мн_пре": "паспорта́х"}"#, conjugation: nil, note: nil),

            // MARK: Emotions
            WordSeed(word: "ра́дость", translation: "joy", partOfSpeech: "noun f", difficulty: 3, caseForms: #"{"ном": "ра́дость", "ген": "ра́дости", "дат": "ра́дости", "акк": "ра́дость", "инс": "ра́достью", "пре": "ра́дости", "мн_ном": "ра́дости", "мн_ген": "ра́достей", "мн_дат": "ра́достям", "мн_акк": "ра́дости", "мн_инс": "ра́достями", "мн_пре": "ра́достях"}"#, conjugation: nil, note: nil),
            WordSeed(word: "грусть", translation: "sadness", partOfSpeech: "noun f", difficulty: 3, caseForms: #"{"ном": "гру́сть", "ген": "гру́сти", "дат": "гру́сти", "акк": "гру́сть", "инс": "гру́стью", "пре": "гру́сти"}"#, conjugation: nil, note: nil),
            WordSeed(word: "страх", translation: "fear", partOfSpeech: "noun m", difficulty: 3, caseForms: #"{"ном": "стра́х", "ген": "стра́ха", "дат": "стра́ху", "акк": "стра́х", "инс": "стра́хом", "пре": "стра́хе", "мн_ном": "стра́хи", "мн_ген": "стра́хов", "мн_дат": "стра́хам", "мн_акк": "стра́хи", "мн_инс": "стра́хами", "мн_пре": "стра́хах"}"#, conjugation: nil, note: nil),
            WordSeed(word: "удивле́ние", translation: "surprise", partOfSpeech: "noun n", difficulty: 3, caseForms: #"{"ном": "удивле́ние", "ген": "удивле́ния", "дат": "удивле́нию", "акк": "удивле́ние", "инс": "удивле́нием", "пре": "удивле́нии", "мн_ном": "удивле́ния", "мн_ген": "удивле́ний", "мн_дат": "удивле́ниям", "мн_акк": "удивле́ния", "мн_инс": "удивле́ниями", "мн_пре": "удивле́ниях"}"#, conjugation: nil, note: nil),
            WordSeed(word: "сча́стье", translation: "happiness", partOfSpeech: "noun n", difficulty: 2, caseForms: #"{"ном": "сча́стье", "ген": "сча́стья", "дат": "сча́стью", "акк": "сча́стье", "инс": "сча́стьем", "пре": "сча́стье", "мн_ном": "сча́стья", "мн_ген": "сча́стий", "мн_дат": "сча́стьям", "мн_акк": "сча́стья", "мн_инс": "сча́стьями", "мн_пре": "сча́стьях"}"#, conjugation: nil, note: nil),
            WordSeed(word: "любо́вь", translation: "love", partOfSpeech: "noun f", difficulty: 2, caseForms: #"{"ном": "любо́вь", "ген": "любви́", "дат": "любви́", "акк": "любо́вь", "инс": "любо́вью", "пре": "любви́", "мн_ном": "любви́", "мн_ген": "любве́й", "мн_дат": "любвя́м", "мн_акк": "любви́", "мн_инс": "любвя́ми", "мн_пре": "любвя́х"}"#, conjugation: nil, note: nil),
            WordSeed(word: "смея́ться", translation: "to laugh", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "смею́сь", "ты": "смеёшься", "он": "смеётся", "мы": "смеёмся", "вы": "смеётесь", "они": "смею́тся", "он(пр)": "смея́лся", "она(пр)": "смея́лась", "оно(пр)": "смея́лось", "они(пр)": "смея́лись"}"#, note: nil),
            WordSeed(word: "пла́кать", translation: "to cry", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "пла́чу", "ты": "пла́чешь", "он": "пла́чет", "мы": "пла́чем", "вы": "пла́чете", "они": "пла́чут", "он(пр)": "пла́кал", "она(пр)": "пла́кала", "оно(пр)": "пла́кало", "они(пр)": "пла́кали"}"#, note: nil),
            WordSeed(word: "боя́ться", translation: "to be afraid", partOfSpeech: "verb impf", difficulty: 2, caseForms: nil, conjugation: #"{"я": "бою́сь", "ты": "бои́шься", "он": "бои́тся", "мы": "бои́мся", "вы": "бои́тесь", "они": "боя́тся", "он(пр)": "боя́лся", "она(пр)": "боя́лась", "оно(пр)": "боя́лось", "они(пр)": "боя́лись"}"#, note: nil),

            // MARK: Colors
            WordSeed(word: "кра́сный", translation: "red", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "си́ний", translation: "dark blue", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "зелёный", translation: "green", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "жёлтый", translation: "yellow", partOfSpeech: "adjective", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "голубо́й", translation: "light blue", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "се́рый", translation: "gray", partOfSpeech: "adjective", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),

            // MARK: Numbers
            WordSeed(word: "оди́н", translation: "one", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "два", translation: "two", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "три", translation: "three", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "четы́ре", translation: "four", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "пять", translation: "five", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "шесть", translation: "six", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "семь", translation: "seven", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "во́семь", translation: "eight", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "де́вять", translation: "nine", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "де́сять", translation: "ten", partOfSpeech: "number", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "сто", translation: "one hundred", partOfSpeech: "number", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ты́сяча", translation: "one thousand", partOfSpeech: "number", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),

            // MARK: Prepositions
            WordSeed(word: "в", translation: "in / into", partOfSpeech: "preposition", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "на", translation: "on / onto", partOfSpeech: "preposition", difficulty: 1, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "с", translation: "with / from", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "без", translation: "without", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "для", translation: "for", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "до", translation: "until / before", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "по́сле", translation: "after", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "о́коло", translation: "near / approximately", partOfSpeech: "preposition", difficulty: 2, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "че́рез", translation: "through / across", partOfSpeech: "preposition", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
            WordSeed(word: "ме́жду", translation: "between", partOfSpeech: "preposition", difficulty: 3, caseForms: nil, conjugation: nil, note: nil),
        ]

        for entry in words {
            let w = WordEntry(context: viewContext)
            w.id = UUID()
            w.word = entry.word
            w.translation = entry.translation
            w.partOfSpeech = entry.partOfSpeech
            w.difficulty = entry.difficulty
            w.caseForms = entry.caseForms
            w.conjugation = entry.conjugation
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
