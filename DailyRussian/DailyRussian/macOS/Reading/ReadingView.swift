import SwiftUI
import CoreData

/// Reading practice — filterable passages with topic tags, hover-to-translate words.
struct ReadingView: View {
    @State private var selectedTextID: UUID?
    @State private var searchText = ""
    @State private var selectedTags: Set<String> = []
    @State private var selectedDifficulties: Set<String> = []
    @FocusState private var isSearchFocused: Bool

    private let tts = TTSProvider()

    // All distinct tags and difficulties
    var allTags: [String] {
        Array(Set(texts.map { $0.topic })).sorted()
    }
    var allDifficulties: [String] { ["Beginner", "Intermediate", "Advanced"] }

    var filteredTexts: [ReadingText] {
        texts.filter { text in
            if !searchText.isEmpty {
                let q = searchText.lowercased()
                guard text.title.lowercased().contains(q) ||
                      text.body.lowercased().contains(q) ||
                      text.topic.lowercased().contains(q) else { return false }
            }
            if !selectedTags.isEmpty, !selectedTags.contains(text.topic) { return false }
            if !selectedDifficulties.isEmpty, !selectedDifficulties.contains(text.difficulty) { return false }
            return true
        }
    }

    var selectedText: ReadingText? {
        guard let id = selectedTextID else { return nil }
        return texts.first { $0.id == id }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left panel: search + filters + passage list
            VStack(spacing: 0) {
                // Search
                TextField("Search passages...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
                    .focused($isSearchFocused)

                // Topic filter
                FilterRow(title: "Topic", options: allTags, selected: $selectedTags)
                    .padding(.horizontal, 10)
                // Difficulty filter
                FilterRow(title: "Level", options: allDifficulties, selected: $selectedDifficulties)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)

                Divider()

                // Count
                Text("\(filteredTexts.count) passages")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)

                Divider()

                if filteredTexts.isEmpty {
                    ContentUnavailableView("No matches", systemImage: "magnifyingglass")
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredTexts) { text in
                                passageRow(text)
                                Divider().padding(.leading, 10)
                            }
                        }
                    }
                    .keyboardNavigable(selectedID: $selectedTextID, itemIDs: filteredTexts.map { $0.id })
                }
            }
            .frame(minWidth: 260, idealWidth: 300)

            Divider()

            // Right panel: detail
            if let text = selectedText {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(text.title).font(.title2).fontWeight(.bold)
                            Spacer()
                            HStack(spacing: 6) {
                                TopicBadge(topic: text.topic)
                                DifficultyBadge(level: text.difficulty)
                            }
                        }

                        RussianFlowText(text: text.body)
                            .lineSpacing(8)
                            .textSelection(.enabled)

                        Divider()

                        DisclosureGroup("Translation", isExpanded: .constant(true)) {
                            Text(text.translation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }

                        if let notes = text.notes {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Notes").font(.headline).fontWeight(.medium)
                                Text(notes)
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .toolbar {
                    ToolbarItem {
                        Button { tts.speak(text.body) } label: {
                            Image(systemName: "speaker.wave.2")
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "book").font(.largeTitle).foregroundStyle(.secondary)
                    Text("Select a passage").font(.headline)
                    Text("\(texts.count) passages — hover any word to see translation.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Reading")
        .background(
            Button("") { isSearchFocused = true }
                .keyboardShortcut("f", modifiers: .command)
                .opacity(0)
        )
    }

    private func passageRow(_ text: ReadingText) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(text.title)
                .font(.headline)
            Text(text.englishTitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            HStack {
                TopicBadge(topic: text.topic)
                DifficultyBadge(level: text.difficulty)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selectedTextID == text.id ? Color.accentColor.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { selectedTextID = text.id }
    }
}

// MARK: - Filter Row

struct FilterRow: View {
    let title: String
    let options: [String]
    @Binding var selected: Set<String>

    var body: some View {
        HStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
                .frame(width: 35, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            if selected.contains(option) { selected.remove(option) }
                            else { selected.insert(option) }
                        } label: {
                            Text(option)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selected.contains(option) ? Color.accentColor : Color.gray.opacity(0.12))
                                .foregroundStyle(selected.contains(option) ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    if !selected.isEmpty {
                        Button("clear") { selected.removeAll() }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Badges

struct TopicBadge: View {
    let topic: String
    var color: Color {
        switch topic {
        case "Conversation": return .blue
        case "Daily Life": return .green
        case "Food & Drink": return .orange
        case "Travel": return .teal
        case "Health": return .red
        case "Practical": return .purple
        case "Culture & Tech": return .indigo
        case "Humour": return .yellow
        default: return .gray
        }
    }
    var body: some View {
        Text(topic).font(.caption2).fontWeight(.medium)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(color.opacity(0.12)).foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct DifficultyBadge: View {
    let level: String
    var color: Color {
        switch level {
        case "Beginner": return .green
        case "Intermediate": return .orange
        default: return .red
        }
    }
    var body: some View {
        Text(level).font(.caption2)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(color.opacity(0.12)).foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - Model

struct ReadingText: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let englishTitle: String
    let topic: String
    let difficulty: String
    let body: String
    let translation: String
    let notes: String?
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ReadingText, rhs: ReadingText) -> Bool { lhs.id == rhs.id }
}

// MARK: - Passages (38 total)

private let texts: [ReadingText] = [
    // MARK: Conversation (6)
    ReadingText(title: "Знакомство", englishTitle: "Introductions", topic: "Conversation", difficulty: "Beginner", body: "— Приве́т! Как тебя́ зову́т?\n— Меня́ зову́т А́нна. А тебя́?\n— Меня́ зову́т Макси́м. О́чень прия́тно.\n— Взаи́мно. Отку́да ты?\n— Я из Москвы́. А ты?\n— Я из Санкт-Петербу́рга.\n— Кру́то! Я всегда́ хоте́л побыва́ть в Пи́тере.", translation: "Hi! What's your name? — My name is Anna. And yours? — Maxim. Nice to meet you. — Likewise. Where are you from? — I'm from Moscow. And you? — I'm from Saint Petersburg. — Cool! I've always wanted to visit Petersburg.", notes: "Пи́тер = informal for Saint Petersburg. Прия́тно = pleasant/nice."),
    ReadingText(title: "Пе́рвый разгово́р", englishTitle: "First Conversation", topic: "Conversation", difficulty: "Beginner", body: "— Здра́вствуйте! Вы но́вый сосе́д?\n— Да, меня́ зову́т Ива́н. А вас?\n— Еле́на. О́чень прия́тно. Вы давно́ здесь живёте?\n— Нет, то́лько неде́лю. Перее́хал из другого го́рода.\n— Е́сли что́-то ну́жно — обраща́йтесь!", translation: "Hello! Are you the new neighbour? — Yes, my name is Ivan. And you? — Elena. Nice to meet you. Have you lived here long? — No, only a week. I moved from another city. — If you need anything — let me know!", notes: "Обраща́йтесь = reach out / ask (formal imperative). Перее́хал = moved (perfective)."),
    ReadingText(title: "Встре́ча ста́рых друзе́й", englishTitle: "Reunion with Old Friends", topic: "Conversation", difficulty: "Intermediate", body: "— Ско́лько лет, ско́лько зим! Как ты?\n— О, приве́т! Не ви́делись це́лую ве́чность. У меня́ всё хорошо́.\n— Ты всё ещё рабо́таешь в той компа́нии?\n— Нет, ушёл год наза́д. Сейча́с фрила́нсер. А ты как?\n— Да так, потихо́ньку. Семья́, рабо́та, ничего́ но́вого.", translation: "Long time no see! How are you? — Oh, hi! Haven't seen you in ages. I'm doing well. — You still working at that company? — No, left a year ago. Freelancing now. How about you? — Oh, you know, slowly. Family, work, nothing new.", notes: "Ско́лько лет, ско́лько зим! = idiomatic 'long time no see'. Потихо́ньку = slowly / bit by bit."),
    ReadingText(title: "Пе́рвое свида́ние", englishTitle: "First Date", topic: "Conversation", difficulty: "Intermediate", body: "— Ты о́чень краси́вая сего́дня.\n— Спаси́бо. Ты то́же хорошо́ вы́глядишь.\n— Что бу́дешь пить? Вино́ и́ли мо́жет кокте́йль?\n— Дава́й вино́. Кра́сное, е́сли есть.\n— Расскажи́ о себе́. Чем ты увлека́ешься?\n— Я люблю́ путеше́ствовать и фотографи́ровать. А ты?\n— Я то́же люблю́ путеше́ствовать! Где ты была́ в после́дний раз?", translation: "You look really beautiful tonight. — Thanks. You look good too. — What'll you drink? Wine or maybe a cocktail? — Let's go with wine. Red, if they have it. — Tell me about yourself. What are you into? — I love travelling and photography. You? — I love travelling too! Where did you go last?", notes: "Вы́глядишь = you look (appearance). Увлека́ешься = you're into / keen on (+ instrumental)."),
    ReadingText(title: "Разгово́р по телефо́ну", englishTitle: "Phone Call", topic: "Conversation", difficulty: "Beginner", body: "— Алло́!\n— Приве́т, Ле́на! Э́то Ди́ма. Ты сейча́с свобо́дна?\n— Ой, приве́т! Да, а что?\n— Ду́маю пойти́ в кино́ сего́дня ве́чером. Не хо́чешь со мно́й?\n— С удово́льствием! А что идёт?\n— Како́й-то но́вый фи́льм. Говоря́т, интере́сный.\n— Хорошо́. Во ско́лько и где встре́тимся?\n— Дава́й в шесть у метро́.\n— Договори́лись! До встре́чи!", translation: "Hello! — Hi Lena, it's Dima. Are you free? — Oh hi! Yeah, what's up? — Thinking of going to the cinema tonight. Want to come? — With pleasure! What's playing? — Some new film. Apparently interesting. — OK. When and where? — Let's say six at the metro. — Deal! See you!", notes: "Дава́й в шесть = Let's (meet) at six — dropping the verb. Договори́лись! = Agreed! / Deal!"),
    ReadingText(title: "Сообщ́ение в ме́ссенджере", englishTitle: "Messenger Chat", topic: "Conversation", difficulty: "Intermediate", body: "Приве́т! Как про́шла твоя́ пое́здка?\nСу́пер! Москва́ — потряса́ющий го́род. Я влюби́лась в э́ту архитекту́ру.\nА погода как?\nХолоднова́то, но я́сно. Мы мно́го гуля́ли.\nПривезёшь сувени́р?\nКоне́чно! Купи́ла тебе́ ко́е-что интере́сное.\nЖду не дожду́сь! Когда́ ты возвраща́ешься?\nВо вто́рник ве́чером. Дава́й встре́тимся в сре́ду?", translation: "Hi! How was your trip? — Amazing! Moscow is a stunning city. I fell in love with the architecture. — And the weather? — A bit chilly but clear. We walked a lot. — Bringing me a souvenir? — Of course! Got you something interesting. — Can't wait! When do you get back? — Tuesday evening. Let's meet Wednesday?", notes: "Влюби́лась = fell in love (feminine). Кое-что = something (specific but unspecified). Жду не дожду́сь = I can't wait (idiom)."),

    // MARK: Daily Life (8)
    ReadingText(title: "У́тренняя рути́на", englishTitle: "Morning Routine", topic: "Daily Life", difficulty: "Beginner", body: "Ка́ждое у́тро я встаю́ в семь часо́в. Снача́ла я умыва́юсь и чи́щу зу́бы. Пото́м я гото́влю за́втрак — обы́чно ка́шу и́ли яи́чницу с хле́бом. Я пью ко́фе и смотрю́ но́вости на телефо́не. В во́семь часо́в я выхожу́ из до́ма и иду́ на рабо́ту. Доро́га занима́ет о́коло получа́са. Я обы́чно слу́шаю му́зыку и́ли подка́ст в метро́.", translation: "Every morning I wake up at 7:00. First I wash my face and brush my teeth. Then I make breakfast — usually porridge or scrambled eggs with bread. I drink coffee and check the news on my phone. At 8:00 I leave the house and go to work. The journey takes about half an hour. I usually listen to music or a podcast on the metro.", notes: "Умыва́юсь = I wash (myself) — reflexive. Занима́ет = takes (time). Получа́са = half an hour (genitive)."),
    ReadingText(title: "В магази́не", englishTitle: "At the Grocery Store", topic: "Daily Life", difficulty: "Beginner", body: "Я зашёл в магази́н купи́ть хлеб и молоко́. В магази́не бы́ло мно́го люде́й. Я взял корзи́ну и пошёл по отде́лам. Снача́ла я вы́брал хлеб — чёрный, как обы́чно. Пото́м я нашёл молоко́, но оста́лась то́лько одна́ буты́лка. На ка́ссе де́вушка спроси́ла: «Паке́т ну́жен?» Я сказа́л: «Да, пожа́луйста». В ито́ге я заплати́л сто пятьдеся́т рубле́й.", translation: "I dropped into the shop to buy bread and milk. It was crowded. I grabbed a basket and went through the aisles. First I picked bread — black, as usual. Then I found milk, but only one bottle was left. At the register the cashier asked: 'Need a bag?' I said: 'Yes, please.' Altogether I paid 150 rubles.", notes: "Зашёл = dropped in (perfective of заходи́ть). Отде́лам = aisles/sections (dative plural)."),
    ReadingText(title: "Пла́ны на вы́ходные", englishTitle: "Weekend Plans", topic: "Daily Life", difficulty: "Intermediate", body: "Вчера́ мы с дру́гом обсужда́ли пла́ны на вы́ходные. Он предложи́л пое́хать за́ город — там у его́ роди́телей есть да́ча. Я никогда́ не́ был на да́че зимо́й, поэ́этому согласи́лся. Мы реши́ли вы́ехать в суббо́ту у́тром, что́бы не стоя́ть в про́бках. Друг сказа́л, что мы бу́дем жа́рить шашлы́к и па́риться в ба́не. Звучи́т отли́чно! Я уже́ купи́л тёплые ве́щи — обеща́ют ми́нус пятна́дцать.", translation: "Yesterday my friend and I discussed weekend plans. He suggested going out of town — his parents have a dacha there. I've never been to a dacha in winter, so I agreed. We decided to leave Saturday morning to avoid traffic. My friend said we'll grill shashlik and use the banya. Sounds great! I already bought warm clothes — they're forecasting minus fifteen.", notes: "Да́ча = Russian country house (cultural essential). Про́бки = traffic jams. Шашлы́к = BBQ skewers. Ба́ня = Russian sauna."),
    ReadingText(title: "В соцсетя́х", englishTitle: "On Social Media", topic: "Daily Life", difficulty: "Intermediate", body: "Смотре́л вчера́ ле́нту в телегра́ме — така́я тоска́. Одни́ но́вости про поли́тику и́ли рекла́ма. Реши́л отпи́сываться от полови́ны кана́лов. А пото́м наткну́лся на прико́льный кана́л про ру́сскую ку́хню. Там ба́бушка гото́вит и расска́зывает. Я да́же реце́пт сохрани́л — хочу́ попро́бовать сде́лать пельме́ни. Правда, те́сто у меня́ никогда́ не получа́ется как на́до. Мо́жет, ты поможешь? Ты же ма́стер по пельме́ням!", translation: "Was scrolling Telegram yesterday — so boring. Just political news or ads. Decided to unsubscribe from half the channels. Then I stumbled on a funny channel about Russian cooking. This grandma cooks and tells stories. I even saved a recipe — want to try making pelmeni. Though my dough never turns out right. Maybe you can help? You're the pelmeni master after all!", notes: "Ле́нта = social feed. Тоска́ = boredom/melancholy. Наткну́лся = stumbled upon. Ты же ма́стер = you ARE a master (же = after all)."),
    ReadingText(title: "По́иск кварти́ры", englishTitle: "Apartment Hunting", topic: "Daily Life", difficulty: "Advanced", body: "Мы уже́ два ме́сяца и́щем но́вую кварти́ру. Э́то оказа́лось гораздо сло́жнее, чем мы ду́мали. Хоти́м двухко́мнатную в це́нтре, но це́ны про́сто косми́ческие. Вчера́ смотре́ли вариа́нт — вро́де бы ничего́, но сли́шком далеко́ от метро́. Рие́лтор говори́т, что ну́жно бы́стро принима́ть реше́ние, потому́ что хоро́шие вариа́нты ухо́дят за не́сколько часо́в. Мы уже́ уста́ли, но продолжа́ем.", translation: "We've been looking for a new apartment for two months. It turned out much harder than we thought. We want a two-room in the centre, but prices are astronomical. Yesterday we viewed one — seemed okay, but too far from the metro. The agent says you need to decide fast because good options are gone within hours. We're already tired but we keep going.", notes: "Косми́ческие це́ны = astronomical prices. Вро́де бы = seems like / sort of. Ухо́дят = go / are taken (literally 'leave')."),
    ReadingText(title: "Очередь на по́чте", englishTitle: "Queue at the Post Office", topic: "Daily Life", difficulty: "Intermediate", body: "Сего́дня я пошёл на по́чту отпра́вить посы́лку. Вхожу́ — а там о́чередь из десяти́ челове́к. Я взял тало́нчик и стал жда́ть. Через пятна́дцать мину́т подошла́ моя́ о́чередь. Сотру́дница взве́сила посы́лку и спроси́ла: «Что внутр́и?» Я сказа́л, что докуме́нты. Запо́лнила бланк и заплати́л три́ста рубле́й. Вся процеду́ра заняла́ два́дцать мину́т. Не так уж и мно́го!", translation: "Today I went to the post office to send a parcel. I walk in — and there's a queue of ten people. I took a ticket and waited. After fifteen minutes it was my turn. The clerk weighed the parcel and asked: 'What's inside?' I said documents. Filled out a form and paid 300 rubles. The whole thing took twenty minutes. Not that much after all!", notes: "Тало́нчик = ticket (diminutive of тало́н). Подошла́ о́чередь = my turn came. Не так уж и мно́го = not that much (emphatic)."),
    ReadingText(title: "Дома́шние дела́", englishTitle: "Household Chores", topic: "Daily Life", difficulty: "Beginner", body: "По суббо́там я обы́чно занима́юсь дома́шними дела́ми. Снача́ла я убира́ю кварти́ру: пылесо́шу, вытира́ю пыль и мою́ по́лы. Э́то занима́ет приме́рно час. Пото́м я иду́ в магази́н за проду́ктами на неде́лю. Я всегда́ составля́ю спи́сок, что́бы ничего́ не забы́ть. Ве́чером гото́влю у́жин на не́сколько дней вперёд. В э́ту суббо́ту бу́ду вари́ть борщ.", translation: "On Saturdays I usually do housework. First I clean the flat: I vacuum, dust, and mop the floors. This takes about an hour. Then I go to the shop for the week's groceries. I always make a list so I don't forget anything. In the evening I cook dinner for several days ahead. This Saturday I'll be making borscht.", notes: "Пылесо́шу = I vacuum (from пылесо́с = vacuum cleaner). Составля́ю спи́сок = I make a list. На не́сколько дней вперёд = for several days ahead."),
    ReadingText(title: "Опозда́ние на рабо́ту", englishTitle: "Late for Work", topic: "Daily Life", difficulty: "Intermediate", body: "Сего́дня я проспа́л! Обы́чно я встаю́ в семь, но буди́льник не срабо́тал. В ито́ге я откры́л глаза́ в во́семь пятна́дцать. В па́нике я оде́лся за пять мину́т, вы́пил ко́фе на ходу́ и вы́бежал из до́ма. Коне́чно, попа́л в про́бку. На рабо́ту пришёл с опозда́нием на́ сорок мину́т. Нача́льник посмотре́л на меня́ стро́го, но ничего́ не сказа́л. За́втра поста́влю два буди́льника.", translation: "Today I overslept! Usually I get up at seven, but the alarm didn't go off. I opened my eyes at 8:15. In a panic I got dressed in five minutes, drank coffee on the go, and ran out of the house. Of course, I hit traffic. Got to work forty minutes late. The boss gave me a stern look but said nothing. Tomorrow I'm setting two alarms.", notes: "Проспа́л = overslept. На ходу́ = on the go. Попа́л в про́бку = hit traffic. Стро́го = sternly."),

    // MARK: Food & Drink (6)
    ReadingText(title: "В кафе́", englishTitle: "At the Café", topic: "Food & Drink", difficulty: "Beginner", body: "— Здра́вствуйте! Что бу́дете зака́зывать?\n— Мне, пожа́луйста, капучи́но и круасса́н.\n— Большо́й и́ли ма́ленький?\n— Ма́ленький, спаси́бо.\n— Что-нибу́дь ещё?\n— Нет, э́то всё. Ско́лько с меня́?\n— Четы́реста пятьдеся́т рубле́й.\n— Вот, возьми́те. Спаси́бо!", translation: "Hello! What will you order? — I'd like a cappuccino and a croissant, please. — Large or small? — Small, thank you. — Anything else? — No, that's all. How much do I owe? — 450 rubles. — Here you go. Thanks!", notes: "Ско́лько с меня́? = How much do I owe? (lit: how much from me)."),
    ReadingText(title: "В рестора́не", englishTitle: "At the Restaurant", topic: "Food & Drink", difficulty: "Intermediate", body: "Вчера́ мы ходи́ли в но́вый рестора́н в це́нтре. Я заказа́л борщ на пе́рвое и котле́ту с пюре́ на второ́е. Моя́ подру́га взяла́ сала́т и ры́бу. Всё бы́ло о́чень вку́сно, но поря́дки ма́ленькие. На десе́рт мы заказа́ли блины́ с варе́ньем — э́то бы́ло лу́чшее. Обслу́живание бы́ло прия́тным, но немно́го ме́дленным. В ито́ге мы оста́вили чаевы́е и ушли́ дово́льные.", translation: "Yesterday we went to a new restaurant in the centre. I ordered borscht for the first course and a cutlet with mashed potatoes for the main. My friend got salad and fish. Everything was very tasty, but portions were small. For dessert we ordered blini with jam — that was the best part. Service was pleasant but a bit slow. In the end we left a tip and went home happy.", notes: "На пе́рвое / на второ́е = for first/second course. Чаевы́е = tips. Дово́льные = satisfied/pleased."),
    ReadingText(title: "На ры́нке", englishTitle: "At the Market", topic: "Food & Drink", difficulty: "Intermediate", body: "— Почём огурцы́?\n— Сто рубле́й за кило́. О́чень све́жие, то́лько что с гря́дки.\n— Дорогова́то. А помидо́ры?\n— Эти по две́сти. Но есть други́е, подеше́вле — сто пятьдеся́т.\n— Дава́йте полкило́ огурцо́в и кило́гра́мм тех помидо́ров, что подеше́вле.\n— С вас сто пятьдеся́т рубле́й.\n— Вот, держи́те. Спаси́бо!", translation: "How much for the cucumbers? — 100 rubles per kilo. Very fresh, straight from the garden. — A bit pricey. And the tomatoes? — These are 200. But there are others, cheaper — 150. — I'll take half a kilo of cucumbers and a kilo of the cheaper tomatoes. — That'll be 150 rubles. — Here you go. Thanks!", notes: "Почём? = How much? (colloquial). Дорогова́то = a bit pricey (diminutive of до́рого). С гря́дки = from the garden bed."),
    ReadingText(title: "Готовим у́жин", englishTitle: "Cooking Dinner", topic: "Food & Drink", difficulty: "Intermediate", body: "Сего́дня я реши́ла пригото́вить что́-то осо́бенное. Нашла́ в интерне́те реце́пт ку́рицы с карто́шкой в духо́вке. На́до бы́ло замаринова́ть ку́рицу зара́нее — на два ча́са. Я доба́вила чесно́к, перец и немно́го лимо́на. Карто́шку наре́зала кру́жками и вы́ложила на про́тивень. Через́ сорок мину́т в духо́вке всё бы́ло гото́во. Получи́лось о́чень вку́сно! Да́же сосе́ди по ле́стнице чу́вствовали за́пах.", translation: "Today I decided to cook something special. Found a recipe online for chicken with potatoes in the oven. Had to marinate the chicken in advance — for two hours. I added garlic, pepper, and a bit of lemon. Sliced the potatoes into rounds and laid them on the baking tray. After forty minutes in the oven, everything was ready. Turned out really tasty! Even the neighbours on the stairwell could smell it.", notes: "Духо́вка = oven. Про́тивень = baking tray. Замаринова́ть = to marinate. По ле́стнице = on the stairwell."),
    ReadingText(title: "За́втрак в Росси́и", englishTitle: "Breakfast in Russia", topic: "Food & Drink", difficulty: "Beginner", body: "Типи́чный ру́сский за́втрак — э́то ка́ша. Са́мая популя́рная — овся́ная и гре́чневая. Мно́гие до́бавляют ма́сло и́ли варе́нье. Кро́ме ка́ши, ру́сские едя́т на за́втрак яи́чницу, бутербро́ды с сы́ром и́ли колбасо́й, и коне́чно, пьют чай и́ли ко́фе. В вы́ходные за́втрак мо́жет быть бо́лее плотным — блины́ со смета́ной и́ли сы́рники. Са́мое гла́вное — за́втрак до́лжен быть сы́тным.", translation: "A typical Russian breakfast is kasha (porridge). The most popular kinds are oatmeal and buckwheat. Many people add butter or jam. Besides porridge, Russians eat scrambled eggs, sandwiches with cheese or sausage, and of course drink tea or coffee. On weekends breakfast can be heartier — blini with sour cream or syrniki (cottage cheese pancakes). The main thing — breakfast should be filling.", notes: "Ка́ша = porridge (cultural staple). Сы́рники = cottage cheese pancakes. Сы́тный = filling/hearty."),
    ReadingText(title: "Дие́та", englishTitle: "The Diet", topic: "Food & Drink", difficulty: "Advanced", body: "Я реши́ла се́сть на дие́ту по́сле Но́вого го́да. Не то́лько потому́ что набра́ла вес, но и для здоро́вья. Исключи́ла са́хар и мучно́е. Ста́ла гото́вить на пару́ вместо жа́рки. Вме́сто сла́дкого ем фру́кты и́ли сухофру́кты. Че́стно говоря́, пе́рвую неде́лю бы́ло тяжело́ — постоя́нно хоте́лось шокола́да. Но сейча́с уже́ привы́кла и чу́вствую себя́ намно́го лу́чше. Да́же ко́жа ста́ла чи́ще.", translation: "I decided to go on a diet after New Year's. Not just because I gained weight, but also for my health. I cut out sugar and flour-based foods. Started steaming instead of frying. Instead of sweets I eat fruit or dried fruit. Honestly, the first week was hard — I constantly craved chocolate. But now I've gotten used to it and feel much better. Even my skin has cleared up.", notes: "Набра́ла вес = gained weight. На пару́ = steamed (lit: on steam). Мучно́е = flour-based foods. Привы́кла = got used to."),

    // MARK: Travel (6)
    ReadingText(title: "На у́лице", englishTitle: "On the Street", topic: "Travel", difficulty: "Beginner", body: "— Извини́те, вы не зна́ете, где метро́?\n— Да, коне́чно! Иди́те пря́мо, пото́м поверни́те нале́во. Метро́ бу́дет на углу́.\n— Э́то далеко́?\n— Нет, мину́т пять пешко́м.\n— Спаси́бо большо́е!\n— Не за что!", translation: "Excuse me, do you know where the metro is? — Yes, of course! Go straight, then turn left. The metro will be on the corner. — Is it far? — No, about five minutes on foot. — Thank you very much! — You're welcome!", notes: "Вы не зна́ете... = polite softener. На углу́ = on the corner (prepositional). Не за что = you're welcome."),
    ReadingText(title: "В аэропорту́", englishTitle: "At the Airport", topic: "Travel", difficulty: "Intermediate", body: "Я прие́хал в аэропо́рт за два ча́са до вы́лета. Снача́ла про́шёл регистра́цию и сда́л бага́ж. Сотру́дница прове́рила па́спорт и спроси́ла про ме́сто — у окна́ и́ли у прохо́да. Я вы́брал у окна́. Пото́м я прошёл па́спортный контро́ль и досмо́тр. В зо́не вы́лета купи́л воды́ и се́л ждать поса́дку. Объяви́ли, что ре́йс заде́рживается на́ сорок мину́т. Что ж, бу́ду чита́ть кни́гу.", translation: "I arrived at the airport two hours before departure. First I checked in and dropped off my luggage. The clerk checked my passport and asked about my seat — window or aisle. I chose window. Then I went through passport control and security. In the departure area I bought water and sat down to wait for boarding. They announced the flight is delayed by forty minutes. Well, I'll read my book.", notes: "Сда́л бага́ж = checked in luggage. У окна́ / у прохо́да = window / aisle. Заде́рживается = is being delayed."),
    ReadingText(title: "В по́езде", englishTitle: "On the Train", topic: "Travel", difficulty: "Intermediate", body: "Я е́хал в по́езде из Москвы́ в Санкт-Петербу́рг. Э́то о́чень удо́бный ночно́й по́езд — сади́шься ве́чером, а у́тром уже́ на ме́сте. В купе́ со мной е́хали ещё́ три челове́ка. Мы немно́го поговори́ли, пото́м я за́нял ве́рхнюю по́лку и доста́л кни́гу. Проводни́к принёс посте́льное бельё и предло́жил чай. Я вы́пил чай и за́снул под сту́к колёс. Просну́лся уже́ в Пи́тере.", translation: "I travelled by train from Moscow to Saint Petersburg. It's a very convenient overnight train — you board in the evening and you're there by morning. Three other people were in my compartment. We chatted a bit, then I took the upper berth and got out my book. The attendant brought bedding and offered tea. I drank the tea and fell asleep to the sound of the wheels. Woke up already in Petersburg.", notes: "Купе́ = compartment (from French coupé). По́лка = berth (lit: shelf). Проводни́к = train attendant. Под сту́к колёс = to the sound of wheels."),
    ReadingText(title: "Потеря́лся в го́роде", englishTitle: "Lost in the City", topic: "Travel", difficulty: "Intermediate", body: "Э́то был мой пе́рвый день в незнако́мом го́роде. Я вы́шел из гости́ницы и реши́л прогуля́ться. Че́рез ча́с я поня́л, что заблуди́лся. Телефо́н разряди́лся, а ка́рты при себе́ не́ было. Я попыта́лся спроси́ть доро́гу у прохо́жих, но они́ говори́ли о́чень бы́стро, и я ничего́ не по́нял. В конце́ концо́в я нашёл остано́вку авто́буса и по номера́м маршру́тов определи́л, где нахожу́сь. Че́рез полчаса́ я уже́ был в гости́нице. Больше не пойду́ гуля́ть без телефо́на!", translation: "It was my first day in an unfamiliar city. I left the hotel and decided to take a walk. An hour later I realised I was lost. My phone had died and I didn't have a map on me. I tried asking passers-by for directions, but they spoke very fast and I didn't understand anything. Eventually I found a bus stop and figured out where I was from the route numbers. Half an hour later I was back at the hotel. Never going walking without my phone again!", notes: "Заблуди́лся = got lost. Разряди́лся = ran out of battery. Прохо́жие = passers-by. В конце́ концо́в = eventually."),
    ReadingText(title: "Та́кси че́рез приложе́ние", englishTitle: "Taxi via App", topic: "Travel", difficulty: "Beginner", body: "Мне ну́жно бы́ло бы́стро добра́ться до вокза́ла. Я откры́л приложе́ние и вы́звал такси́. Ввёл а́дрес и че́рез мину́ту уже́ ви́дел маши́ну на ка́рте. Води́тель прие́хал о́чень бы́стро — мину́ты через три. Я се́л в маши́ну и мы пое́хали. Води́тель спроси́л: «По како́му маршру́ту лу́чше?» Я сказа́л: «Как удо́бнее». Дое́хали за пятна́дцать мину́т. Я оплати́л в приложе́нии и вы́шел.", translation: "I needed to get to the station quickly. I opened the app and called a taxi. Entered the address and within a minute I could see the car on the map. The driver arrived very quickly — in about three minutes. I got in and we set off. The driver asked: 'Which route is better?' I said: 'Whichever is more convenient.' We got there in fifteen minutes. I paid in the app and got out.", notes: "Вы́звал такси́ = called a taxi. Добра́ться = to get to / reach. Как удо́бнее = whichever is more convenient."),
    ReadingText(title: "Путе́шествие на о́зеро Байка́л", englishTitle: "Journey to Lake Baikal", topic: "Travel", difficulty: "Advanced", body: "Э́тим ле́том мы наконе́ц осуществи́ли мечту́ — съе́здили на Байка́л. Э́то са́мое глубо́кое о́зеро в ми́ре, и оно́ действи́тельно впечатля́ет. Вода́ така́я прозра́чная, что ви́дно ка́мни на глубине́ не́скольких ме́тров. Мы останови́лись в небольшо́м посёлке на бе́регу. Ме́стные жи́тели о́чень гостеприи́мные — угоща́ли нас копчёной ры́бой и расска́зывали леге́нды об о́зере. Осо́бенно запомина́ющимся был зака́т — не́бо ста́ло ро́зовым, а вода́ — золото́й. Обяза́тельно верну́сь туда́ ещё́ раз.", translation: "This summer we finally fulfilled a dream — we went to Baikal. It's the deepest lake in the world, and it truly impresses. The water is so clear you can see stones at a depth of several metres. We stayed in a small settlement on the shore. The locals are very hospitable — they treated us to smoked fish and told legends about the lake. The sunset was especially memorable — the sky turned pink and the water golden. I'll definitely go back again.", notes: "Осуществи́ли мечту́ = fulfilled a dream. Впечатля́ет = impresses. Гостеприи́мные = hospitable. Копчёный = smoked."),

    // MARK: Health (5)
    ReadingText(title: "У врача́", englishTitle: "At the Doctor", topic: "Health", difficulty: "Intermediate", body: "Пацие́нт зашёл в кабине́т и се́л на сту́л. Врач спроси́ла: «На что жа́луетесь?» Пацие́нт отве́тил: «У меня́ боли́т горло́ и температу́ра уже́ три дня». Врач осмотре́ла го́рло и сказа́ла: «Э́то анги́на. Я вы́пишу антибио́тики. Принима́йте их три ра́за в день по́сле еды́. И бо́льше пейте тёплое». Пацие́нт поблагодари́л и ушёл в апте́ку.", translation: "The patient entered the office and sat down. The doctor asked: 'What are your complaints?' The patient replied: 'My throat hurts and I've had a temperature for three days.' The doctor examined the throat and said: 'It's tonsillitis. I'll prescribe antibiotics. Take them three times a day after meals. And drink more warm liquids.' The patient thanked her and went to the pharmacy.", notes: "На что жа́луетесь? = What are your complaints? (standard doctor opening). Анги́на = tonsillitis. Вы́пишу = I'll prescribe."),
    ReadingText(title: "Записываюсь к врачу́", englishTitle: "Booking a Doctor's Appointment", topic: "Health", difficulty: "Intermediate", body: "— Здра́вствуйте! Я хоте́л бы записа́ться к терапе́вту.\n— У вас есть по́лис?\n— Да, коне́чно. Вот.\n— На како́е число́ и вре́мя?\n— На э́ту неде́лю, е́сли мо́жно.\n— В пя́тницу есть окно́ в де́сять утра́. Подойдёт?\n— Отли́чно. Спаси́бо!\n— Запи́сываю. Приходи́те за пятна́дцать мину́т до приёма.", translation: "Hello! I'd like to book an appointment with a GP. — Do you have your insurance card? — Yes, of course. Here. — For what date and time? — This week, if possible. — There's a slot on Friday at 10am. Does that work? — Perfect. Thanks! — Booked. Come fifteen minutes before your appointment.", notes: "Записа́ться = to sign up / book. По́лис = insurance policy/card. Окно́ = slot/window. До приёма = before the appointment."),
    ReadingText(title: "Просту́да", englishTitle: "A Cold", topic: "Health", difficulty: "Beginner", body: "Вчера́ я промо́к под дождём и сего́дня просну́лся с насмо́рком. Це́лый день чиха́ю и ка́шляю. На́чало боле́ть го́рло. Я пью горя́чий чай с мёдом и лимо́ном, но э́то не о́чень помога́ет. Купи́л в апте́ке лека́рства — ка́пли в нос и табле́тки от бо́ли в го́рле. Наде́юсь, что че́рез па́ру дней бу́дет лу́чше. Пока́ сижу́ до́ма под одея́лом.", translation: "Yesterday I got soaked in the rain and today I woke up with a runny nose. I've been sneezing and coughing all day. My throat started hurting. I'm drinking hot tea with honey and lemon, but it's not really helping. I bought medicine at the pharmacy — nose drops and throat lozenges. I hope in a couple of days it'll be better. For now I'm sitting at home under a blanket.", notes: "Промо́к = got soaked. Насмо́рк = runny nose. Чиха́ть = to sneeze. Ка́шлять = to cough."),
    ReadingText(title: "В апте́ке", englishTitle: "At the Pharmacy", topic: "Health", difficulty: "Beginner", body: "— Здра́вствуйте! Что вы посове́туете от головно́й бо́ли?\n— Попро́буйте э́тот препара́т. Он бы́стро де́йствует.\n— А как его́ принима́ть?\n— По одно́й табле́тке три ра́за в день, по́сле еды́.\n— Есть ли побо́чные эффе́кты?\n— Мо́жет вызыва́ть сонли́вость, так что лу́чше не за рулём.\n— Поня́тно. Ско́лько он сто́ит?\n— Три́ста пятьдеся́т рубле́й.\n— Хорошо́, я возьму́.", translation: "Hello! What would you recommend for a headache? — Try this one. It works fast. — And how do you take it? — One tablet three times a day, after meals. — Any side effects? — May cause drowsiness, so better not to drive. — I see. How much is it? — 350 rubles. — OK, I'll take it.", notes: "Посове́туете = would you recommend. Де́йствует = works / acts. Побо́чные эффе́кты = side effects. Сонли́вость = drowsiness."),
    ReadingText(title: "Здоро́вый о́браз жи́зни", englishTitle: "Healthy Lifestyle", topic: "Health", difficulty: "Advanced", body: "В после́днее вре́мя я стара́юсь вести́ здоро́вый о́браз жи́зни. Бро́сил кури́ть — э́то бы́ло са́мое тру́дное. Тепе́рь я бе́гаю три ра́за в неде́лю по у́трам, да́же в дождь. Стара́юсь ложи́ться спать до оди́ннадцати и спать не ме́ньше восьми́ часо́в. В пита́нии то́же измене́ния — ме́ньше сла́дкого, бо́льше овоще́й. Чу́вствую себя́ значи́тельно лу́чше, чем полго́да наза́д. Всем сове́тую!", translation: "Lately I've been trying to lead a healthy lifestyle. I quit smoking — that was the hardest part. Now I run three times a week in the mornings, even in the rain. I try to go to bed before eleven and sleep at least eight hours. Changes in diet too — less sugar, more vegetables. I feel significantly better than six months ago. I recommend it to everyone!", notes: "Бро́сил кури́ть = quit smoking. Ложи́ться спать = to go to bed. Полго́да = half a year."),

    // MARK: Practical (4)
    ReadingText(title: "В банке", englishTitle: "At the Bank", topic: "Practical", difficulty: "Intermediate", body: "— Здра́вствуйте! Я хочу́ откры́ть счёт.\n— Вам накопи́тельный и́ли теку́щий?\n— Теку́щий. И мне ну́жна́ ка́рта.\n— Хорошо́. Ваш па́спорт, пожа́луйста.\n— Вот, возьми́те.\n— Запо́лните э́ту а́нкету. Здесь укажи́те ваш а́дрес и телефо́н.\n— Я зако́нчил. Ско́лько вре́мени займёт оформле́ние?\n— Ка́рта бу́дет гото́ва че́рез не́сколько дней. Вам позво́нят.", translation: "Hello! I'd like to open an account. — Savings or current? — Current. And I need a card. — OK. Your passport, please. — Here you go. — Fill out this form. Indicate your address and phone here. — I'm done. How long will processing take? — The card will be ready in a few days. They'll call you.", notes: "Счёт = account. Накопи́тельный = savings. Теку́щий = current/checking. Оформле́ние = processing / paperwork."),
    ReadingText(title: "На по́чте", englishTitle: "At the Post Office", topic: "Practical", difficulty: "Intermediate", body: "Мне ну́жно бы́ло отпра́вить посы́лку в друго́й го́род. Я пришёл на по́чту, взял тало́н и стал жда́ть. Когда́ подошла́ моя́ о́чередь, я объясни́л, что мне ну́жно. Сотру́дница взве́сила посы́лку и сказа́ла: «Обы́чная доста́вка и́ли уско́ренная?» Я вы́брал обы́чную — э́то деше́вле. Заполни́л бланк с а́дресом получа́теля и заплати́л. Она́ да́ла мне тре́кинг-но́мер и сказа́ла: «Придёт че́рез пять-семь рабо́чих дней».", translation: "I needed to send a parcel to another city. I came to the post office, got a ticket, and waited. When my turn came, I explained what I needed. The clerk weighed the parcel and said: 'Regular delivery or express?' I chose regular — it's cheaper. I filled out a form with the recipient's address and paid. She gave me a tracking number and said: 'It'll arrive in five to seven working days.'", notes: "Тало́н = ticket/number. Обы́чная / уско́ренная доста́вка = regular / express delivery. Получа́тель = recipient."),
    ReadingText(title: "Заполня́ю а́нкету", englishTitle: "Filling Out a Form", topic: "Practical", difficulty: "Advanced", body: "Для получе́ния ви́зы ну́жно бы́ло заполни́ть огро́мную а́нкету. В ней бы́ло бо́лее тридцати́ вопро́сов — от ли́чных да́нных до исто́рии пое́здок за после́дние пять лет. Я провёл за э́тим де́лом почти́ два ча́са. На́до бы́ло ука́зать все предыду́щие па́спорта, места́ рабо́ты за после́дние де́сять лет, и да́же а́дреса, где я жил. Не́сколько раз я ошиба́лся и прихо́дилось перепи́сывать. Слава́ Бо́гу, в конце́ всё получи́лось.", translation: "To get the visa, I had to fill out an enormous form. It had over thirty questions — from personal details to travel history for the last five years. I spent almost two hours on this. I had to list all previous passports, workplaces from the past ten years, and even addresses where I'd lived. I made mistakes several times and had to redo it. Thank God, in the end everything worked out.", notes: "Получе́ние = obtaining. Ука́зать = to indicate / list. Ошиба́лся = I made mistakes. Слава́ Бо́гу = thank God."),
    ReadingText(title: "Разгово́р с нача́льником", englishTitle: "Talking to the Boss", topic: "Practical", difficulty: "Advanced", body: "Вчера́ у меня́ был непросто́й разгово́р с нача́льником. Я хоте́л попроси́ть повыше́ние зарпла́ты и гото́вился к э́тому разгово́ру не́сколько дней. Собра́л да́нные о свои́х результа́тах, сравни́л ры́ночные зарпла́ты, подгото́вил аргуме́нты. Нача́льник вы́слушал меня́ внима́тельно и сказа́л, что це́нит мой вкла́д, но бюдже́т на э́тот год уже́ утверждён. Обеща́л верну́ться к э́тому вопро́су в сле́дующем кварта́ле. Не ска́зал ни да, ни нет, но по кра́йней ме́ре, не отказа́л сра́зу.", translation: "Yesterday I had a difficult conversation with my boss. I wanted to ask for a raise and I'd been preparing for this conversation for several days. I gathered data on my results, compared market salaries, prepared arguments. The boss listened attentively and said he values my contribution, but the budget for this year has already been approved. He promised to return to this question next quarter. He didn't say yes or no, but at least he didn't refuse outright.", notes: "Повыше́ние зарпла́ты = salary raise. Це́нит = values. Вкла́д = contribution. Утверждён = approved. Отказа́л = refused."),

    // MARK: Culture & Tech (2)
    ReadingText(title: "Онла́йн-шопинг", englishTitle: "Online Shopping", topic: "Culture & Tech", difficulty: "Intermediate", body: "Вчера́ я зака́зывал ве́щи че́рез интерне́т-магази́н. Давно́ хоте́л купи́ть но́вую ку́ртку на зи́му. Вы́брал не́сколько вариа́нтов, прочита́л отзы́вы, сравни́л це́ны. В концо́в концо́в останови́лся на чёрной с утепли́телем. Офо́рмил зака́з, оплати́л ка́ртой. Доста́вка обеща́ли на сле́дующий день. И действи́тельно, уже́ сего́дня у́тром курье́р позвони́л в дверь. Приме́рил — сиди́т идеа́льно! О́чень дово́лен поку́пкой.", translation: "Yesterday I was ordering things through an online store. I'd long wanted to buy a new winter jacket. I chose several options, read reviews, compared prices. In the end I settled on a black one with insulation. I placed the order, paid by card. Delivery was promised for the next day. And indeed, this morning the courier rang the doorbell. I tried it on — fits perfectly! Very happy with the purchase.", notes: "Отзы́вы = reviews. Останови́лся на... = settled on... (+ prepositional). Утепли́тель = insulation. Сиди́т = fits (of clothing)."),
    ReadingText(title: "Ру́сский рок", englishTitle: "Russian Rock", topic: "Culture & Tech", difficulty: "Advanced", body: "Я давно́ увлека́юсь ру́сским ро́ком. Э́то не про́сто му́зыка — э́то це́лый культу́рный пласт. Мои́ люби́мые гру́ппы — «Кино́», «ДДТ», и «А́квариум». Их те́ксты о́чень глубо́кие и поэти́чные. В них поднима́ются ва́жные те́мы — свобо́да, любо́вь, смысл жи́зни. Е́сли вы хоти́те поня́ть ру́сскую ду́шу, послу́шайте э́ти пе́сни. Да́же е́сли вы не всё поймёте в слова́х, настрое́ние и эне́ргию вы почу́вствуете.", translation: "I've long been into Russian rock. It's not just music — it's a whole cultural layer. My favourite bands are Kino, DDT, and Akvarium. Their lyrics are very deep and poetic. They raise important themes — freedom, love, the meaning of life. If you want to understand the Russian soul, listen to these songs. Even if you don't understand all the words, you'll feel the mood and the energy.", notes: "Увлека́юсь = I'm into (+ instrumental). Культу́рный пласт = cultural layer. Поднима́ются = are raised (themes). Ру́сскую ду́шу = the Russian soul (accusative)."),

    // MARK: Humour (1)
    ReadingText(title: "Прико́л на рабо́те", englishTitle: "A Funny Thing at Work", topic: "Humour", difficulty: "Intermediate", body: "На рабо́те сего́дня произошёл забавный слу́чай. Ко́ллега перепу́тал день и пришёл в о́фис в суббо́ту. Он удиви́лся, что никого́ нет, и поду́мал, что всех уво́лили. На́чал звони́ть всем подря́д в па́нике: «Где вы все? Почему́ о́фис пусто́й?» Мы ему́ объясни́ли, что сего́дня суббо́та. Он так смути́лся, что тепе́рь ка́ждый раз, когда́ мы его́ ви́дим, мы говори́м: «Ну что, рабо́таем в суббо́ту?» По-мо́ему, он уже́ уста́л от э́той шу́тки.", translation: "A funny thing happened at work today. A colleague mixed up the days and came to the office on Saturday. He was surprised nobody was there and thought everyone had been fired. He started calling everyone in a panic: 'Where are you all? Why is the office empty?' We explained to him that it's Saturday. He was so embarrassed that now every time we see him we say: 'So, working on Saturday?' I think he's already tired of this joke.", notes: "Перепу́тал = mixed up / confused. Уво́лили = fired / laid off. Подря́д = in a row / one after another. Смути́лся = got embarrassed. Шу́тка = joke."),
]
