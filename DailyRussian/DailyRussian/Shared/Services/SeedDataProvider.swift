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

    // MARK: - Vocabulary (200+ words)

    private func seedWords() {
        let words: [(String, String, String?, Int16)] = [
            // MARK: Greetings & Politeness
            ("приве́т", "hello / hi", "greeting", 1),
            ("здра́вствуйте", "hello (formal)", "greeting", 1),
            ("до́брое у́тро", "good morning", "greeting", 1),
            ("до́брый день", "good afternoon", "greeting", 1),
            ("до́брый ве́чер", "good evening", "greeting", 1),
            ("до свида́ния", "goodbye", "greeting", 1),
            ("пока́", "bye (informal)", "greeting", 1),
            ("споко́йной но́чи", "good night", "greeting", 1),
            ("как дела́?", "how are things?", "phrase", 1),
            ("ничего́", "nothing / so-so", "expression", 1),
            ("норма́льно", "fine / okay", "adverb", 1),
            ("хорошо́", "good / well", "adverb", 1),
            ("отли́чно", "great / excellent", "adverb", 2),
            ("спаси́бо", "thank you", "expression", 1),
            ("большо́е спаси́бо", "thank you very much", "expression", 1),
            ("пожа́луйста", "please / you're welcome", "expression", 1),
            ("извини́те", "excuse me / sorry", "expression", 2),
            ("прости́те", "I'm sorry (formal)", "expression", 2),
            ("ничего́ стра́шного", "it's okay / no worries", "expression", 2),
            ("да", "yes", "particle", 1),
            ("нет", "no / not", "particle", 1),
            ("коне́чно", "of course", "adverb", 2),
            ("может быть", "maybe", "expression", 2),

            // MARK: People & Family
            ("челове́к", "person", "noun m", 2),
            ("лю́ди", "people", "noun pl", 2),
            ("друг", "friend (male)", "noun m", 1),
            ("подру́га", "friend (female)", "noun f", 1),
            ("мужчи́на", "man", "noun m", 2),
            ("же́нщина", "woman", "noun f", 2),
            ("ма́льчик", "boy", "noun m", 1),
            ("де́вочка", "girl", "noun f", 1),
            ("ребёнок", "child", "noun m", 2),
            ("семья́", "family", "noun f", 2),
            ("роди́тели", "parents", "noun pl", 2),
            ("ма́ма", "mom", "noun f", 1),
            ("па́па", "dad", "noun m", 1),
            ("брат", "brother", "noun m", 1),
            ("сестра́", "sister", "noun f", 1),
            ("сын", "son", "noun m", 2),
            ("дочь", "daughter", "noun f", 2),
            ("муж", "husband", "noun m", 2),
            ("жена́", "wife", "noun f", 2),
            ("и́мя", "name", "noun n", 1),

            // MARK: Verbs — Essential
            ("быть", "to be", "verb impf", 1),
            ("говори́ть", "to speak", "verb impf", 2),
            ("сказа́ть", "to say (pf)", "verb pf", 3),
            ("знать", "to know", "verb impf", 2),
            ("понима́ть", "to understand", "verb impf", 2),
            ("ду́мать", "to think", "verb impf", 2),
            ("хоте́ть", "to want", "verb impf", 2),
            ("люби́ть", "to love", "verb impf", 2),
            ("жить", "to live", "verb impf", 2),
            ("рабо́тать", "to work", "verb impf", 2),
            ("де́лать", "to do / make", "verb impf", 2),
            ("сде́лать", "to do / make (pf)", "verb pf", 3),
            ("ви́деть", "to see", "verb impf", 2),
            ("уви́деть", "to see (pf)", "verb pf", 3),
            ("слы́шать", "to hear", "verb impf", 2),
            ("идти́", "to go (on foot)", "verb impf", 2),
            ("ходи́ть", "to go (on foot, multi)", "verb impf", 3),
            ("е́хать", "to go (by vehicle)", "verb impf", 2),
            ("е́здить", "to go (by vehicle, multi)", "verb impf", 3),
            ("чита́ть", "to read", "verb impf", 2),
            ("писа́ть", "to write", "verb impf", 2),
            ("есть", "to eat", "verb impf", 2),
            ("пить", "to drink", "verb impf", 2),
            ("спать", "to sleep", "verb impf", 2),
            ("брать", "to take", "verb impf", 2),
            ("взять", "to take (pf)", "verb pf", 3),
            ("дава́ть", "to give", "verb impf", 2),
            ("дать", "to give (pf)", "verb pf", 3),
            ("смотре́ть", "to watch / look", "verb impf", 2),
            ("посмотре́ть", "to watch / look (pf)", "verb pf", 3),
            ("ждать", "to wait", "verb impf", 2),
            ("стоя́ть", "to stand", "verb impf", 2),

            // MARK: Food & Drink
            ("во́да", "water", "noun f", 1),
            ("хлеб", "bread", "noun m", 1),
            ("молоко́", "milk", "noun n", 1),
            ("ко́фе", "coffee", "noun m", 1),
            ("чай", "tea", "noun m", 1),
            ("са́хар", "sugar", "noun m", 1),
            ("соль", "salt", "noun f", 2),
            ("мя́со", "meat", "noun n", 2),
            ("ры́ба", "fish", "noun f", 2),
            ("ку́рица", "chicken", "noun f", 2),
            ("яйцо́", "egg", "noun n", 1),
            ("суп", "soup", "noun m", 1),
            ("сыр", "cheese", "noun m", 1),
            ("ма́сло", "butter / oil", "noun n", 2),
            ("фру́кты", "fruit", "noun pl", 1),
            ("о́вощи", "vegetables", "noun pl", 2),
            ("карто́шка", "potato", "noun f", 1),
            ("рис", "rice", "noun m", 2),
            ("за́втрак", "breakfast", "noun m", 1),
            ("обе́д", "lunch", "noun m", 1),
            ("у́жин", "dinner", "noun m", 1),
            ("вку́сно", "tasty / delicious", "adverb", 2),

            // MARK: Places & Directions
            ("дом", "house / home", "noun m", 1),
            ("до́ма", "at home", "adverb", 1),
            ("рабо́та", "work / job", "noun f", 1),
            ("шко́ла", "school", "noun f", 2),
            ("магази́н", "shop / store", "noun m", 2),
            ("рестора́н", "restaurant", "noun m", 2),
            ("у́лица", "street", "noun f", 2),
            ("доро́га", "road", "noun f", 2),
            ("го́род", "city", "noun m", 2),
            ("страна́", "country", "noun f", 2),
            ("Москва́", "Moscow", "noun f", 1),
            ("Росси́я", "Russia", "noun f", 1),
            ("ме́сто", "place", "noun n", 2),
            ("здесь", "here", "adverb", 1),
            ("там", "there", "adverb", 1),
            ("пря́мо", "straight ahead", "adverb", 2),
            ("нале́во", "to the left", "adverb", 2),
            ("напра́во", "to the right", "adverb", 2),
            ("ря́дом", "nearby", "adverb", 2),
            ("далеко́", "far", "adverb", 2),

            // MARK: Time
            ("сего́дня", "today", "adverb", 1),
            ("за́втра", "tomorrow", "adverb", 1),
            ("вчера́", "yesterday", "adverb", 1),
            ("сейча́с", "now", "adverb", 1),
            ("пото́м", "later / then", "adverb", 2),
            ("всегда́", "always", "adverb", 2),
            ("иногда́", "sometimes", "adverb", 2),
            ("никогда́", "never", "adverb", 2),
            ("ча́сто", "often", "adverb", 2),
            ("у́тро", "morning", "noun n", 1),
            ("день", "day", "noun m", 1),
            ("ве́чер", "evening", "noun m", 1),
            ("ночь", "night", "noun f", 1),
            ("вре́мя", "time", "noun n", 2),
            ("час", "hour", "noun m", 1),
            ("мину́та", "minute", "noun f", 1),
            ("неде́ля", "week", "noun f", 1),
            ("ме́сяц", "month", "noun m", 1),
            ("год", "year", "noun m", 1),

            // MARK: Question Words
            ("кто", "who", "pronoun", 1),
            ("что", "what", "pronoun", 1),
            ("где", "where", "adverb", 1),
            ("куда́", "where to", "adverb", 3),
            ("отку́да", "where from", "adverb", 3),
            ("когда́", "when", "adverb", 1),
            ("почему́", "why", "adverb", 2),
            ("как", "how", "adverb", 1),
            ("ско́лько", "how much / many", "adverb", 2),
            ("како́й", "which / what kind", "pronoun", 2),
            ("чей", "whose", "pronoun", 3),

            // MARK: Adjectives
            ("хоро́ший", "good", "adjective", 2),
            ("плохо́й", "bad", "adjective", 2),
            ("большо́й", "big", "adjective", 2),
            ("ма́ленький", "small", "adjective", 2),
            ("но́вый", "new", "adjective", 2),
            ("ста́рый", "old", "adjective", 2),
            ("молодо́й", "young", "adjective", 2),
            ("краси́вый", "beautiful", "adjective", 2),
            ("ру́сский", "Russian", "adjective", 1),
            ("ва́жный", "important", "adjective", 2),
            ("до́брый", "kind", "adjective", 2),
            ("пло́хо", "badly", "adverb", 2),
            ("холодный", "cold", "adjective", 2),
            ("тёплый", "warm", "adjective", 2),
            ("горя́чий", "hot (object)", "adjective", 2),
            ("бе́лый", "white", "adjective", 1),
            ("чёрный", "black", "adjective", 1),

            // MARK: Body & Health
            ("рука́", "hand / arm", "noun f", 2),
            ("нога́", "foot / leg", "noun f", 2),
            ("голова́", "head", "noun f", 2),
            ("глаз", "eye", "noun m", 2),
            ("у́хо", "ear", "noun n", 2),
            ("нос", "nose", "noun m", 2),
            ("рот", "mouth", "noun m", 2),
            ("се́рдце", "heart", "noun n", 2),
            ("боле́ть", "to hurt / be sick", "verb impf", 2),
            ("здоро́вье", "health", "noun n", 2),

            // MARK: Weather & Nature
            ("пого́да", "weather", "noun f", 2),
            ("со́лнце", "sun", "noun n", 1),
            ("дождь", "rain", "noun m", 2),
            ("снег", "snow", "noun m", 2),
            ("ве́тер", "wind", "noun m", 2),
            ("хо́лодно", "it's cold", "adverb", 2),
            ("тепло́", "it's warm", "adverb", 2),
            ("жа́рко", "it's hot", "adverb", 2),

            // MARK: Clothing
            ("оде́жда", "clothing", "noun f", 2),
            ("руба́шка", "shirt", "noun f", 2),
            ("штаны́", "pants", "noun pl", 2),
            ("пла́тье", "dress", "noun n", 2),
            ("ку́ртка", "jacket", "noun f", 2),
            ("ша́пка", "hat", "noun f", 2),
            ("о́бувь", "footwear", "noun f", 2),

            // MARK: Technology & Modern Life
            ("телефо́н", "telephone", "noun m", 1),
            ("компью́тер", "computer", "noun m", 2),
            ("интерне́т", "internet", "noun m", 1),
            ("сообщ́ение", "message / text", "noun n", 2),
            ("звони́ть", "to call (on phone)", "verb impf", 2),
            ("позвони́ть", "to call (pf)", "verb pf", 3),
            ("отпра́вить", "to send", "verb pf", 2),
            ("получи́ть", "to receive", "verb pf", 2),
            ("фо́то", "photo", "noun n", 1),
            ("де́ньги", "money", "noun pl", 1),
            ("биле́т", "ticket", "noun m", 2),
            ("па́спорт", "passport", "noun m", 2),

            // MARK: Emotions
            ("ра́дость", "joy", "noun f", 3),
            ("грусть", "sadness", "noun f", 3),
            ("страх", "fear", "noun m", 3),
            ("удивле́ние", "surprise", "noun n", 3),
            ("сча́стье", "happiness", "noun n", 2),
            ("любо́вь", "love", "noun f", 2),
            ("смея́ться", "to laugh", "verb impf", 2),
            ("пла́кать", "to cry", "verb impf", 2),
            ("боя́ться", "to be afraid", "verb impf", 2),

            // MARK: Colors
            ("кра́сный", "red", "adjective", 1),
            ("си́ний", "dark blue", "adjective", 1),
            ("зелёный", "green", "adjective", 1),
            ("жёлтый", "yellow", "adjective", 1),
            ("голубо́й", "light blue", "adjective", 2),
            ("се́рый", "gray", "adjective", 2),

            // MARK: Numbers
            ("оди́н", "one", "number", 1),
            ("два", "two", "number", 1),
            ("три", "three", "number", 1),
            ("четы́ре", "four", "number", 1),
            ("пять", "five", "number", 1),
            ("шесть", "six", "number", 1),
            ("семь", "seven", "number", 1),
            ("во́семь", "eight", "number", 1),
            ("де́вять", "nine", "number", 1),
            ("де́сять", "ten", "number", 1),
            ("сто", "one hundred", "number", 2),
            ("ты́сяча", "one thousand", "number", 2),

            // MARK: Prepositions
            ("в", "in / into", "preposition", 1),
            ("на", "on / onto", "preposition", 1),
            ("с", "with / from", "preposition", 2),
            ("без", "without", "preposition", 2),
            ("для", "for", "preposition", 2),
            ("до", "until / before", "preposition", 2),
            ("по́сле", "after", "preposition", 2),
            ("о́коло", "near / approximately", "preposition", 2),
            ("че́рез", "through / across", "preposition", 3),
            ("ме́жду", "between", "preposition", 3),
        ]

        for entry in words {
            let w = WordEntry(context: viewContext)
            w.id = UUID()
            w.word = entry.0
            w.translation = entry.1
            w.partOfSpeech = entry.2
            w.difficulty = entry.3
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
