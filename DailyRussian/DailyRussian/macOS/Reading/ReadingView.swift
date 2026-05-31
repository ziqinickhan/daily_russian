import SwiftUI

/// Reading practice — passage list, hover-to-translate words, tap to select.
struct ReadingView: View {
    @State private var selectedTextID: UUID?

    private let tts = TTSProvider()

    var selectedText: ReadingText? {
        guard let id = selectedTextID else { return nil }
        return texts.first { $0.id == id }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Passage list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(texts) { text in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(text.title)
                                .font(.headline)
                            Text(text.source)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                Text(text.difficulty)
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.15), in: Capsule())
                                if text.isDialogue {
                                    Text("dialogue")
                                        .font(.caption2)
                                        .foregroundStyle(.blue)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1), in: Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selectedTextID == text.id ? Color.accentColor.opacity(0.1) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTextID = text.id
                        }
                        Divider()
                    }
                }
            }
            .frame(width: 220)
            .navigationTitle("Reading")

            Divider()

            // Detail panel
            if let text = selectedText {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        RussianFlowText(text: text.body)
                            .lineSpacing(8)
                            .textSelection(.enabled)

                        Divider()

                        DisclosureGroup("Show full translation") {
                            Text(text.translation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }

                        if let notes = text.notes {
                            Text("Notes")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.orange)
                            Text(notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
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
                    Image(systemName: "book")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Select a passage")
                        .font(.headline)
                    Text("Hover over any Russian word to see its translation.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Model

struct ReadingText: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let source: String
    let difficulty: String
    let body: String
    let translation: String
    let notes: String?
    let isDialogue: Bool

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ReadingText, rhs: ReadingText) -> Bool { lhs.id == rhs.id }
}

// MARK: - Texts

private let texts: [ReadingText] = [
    ReadingText(title: "Знакомство", source: "Meeting someone new", difficulty: "Beginner", body: """
    — Приве́т! Как тебя́ зову́т?
    — Меня́ зову́т А́нна. А тебя́?
    — Меня́ зову́т Макси́м. О́чень прия́тно.
    — Взаи́мно. Отку́да ты?
    — Я из Москвы́. А ты?
    — Я из Санкт-Петербу́рга.
    — Кру́то! Я всегда́ хоте́л побыва́ть в Пи́тере.
    """, translation: """
    "Hi! What's your name?" "My name is Anna. And yours?" "My name is Maxim. Nice to meet you." "Likewise. Where are you from?" "I'm from Moscow. And you?" "I'm from Saint Petersburg." "Cool! I've always wanted to visit Petersburg."
    """, notes: "Пи́тер = informal name for Saint Petersburg.", isDialogue: true),

    ReadingText(title: "В кафе́", source: "Ordering coffee", difficulty: "Beginner", body: """
    — Здра́вствуйте! Что бу́дете зака́зывать?
    — Мне, пожа́луйста, капучи́но и круасса́н.
    — Большо́й и́ли ма́ленький?
    — Ма́ленький, спаси́бо.
    — Что-нибу́дь ещё?
    — Нет, э́то всё. Ско́лько с меня́?
    — Четы́реста пятьдеся́т рубле́й.
    — Вот, возьми́те. Спаси́бо!
    """, translation: """
    "What will you order?" "Cappuccino and a croissant, please." "Large or small?" "Small, thank you." "Anything else?" "No, that's all. How much?" "450 rubles." "Here you go. Thanks!"
    """, notes: "Ско́лько с меня́? = how much do I owe?", isDialogue: true),

    ReadingText(title: "На у́лице", source: "Asking for directions", difficulty: "Beginner", body: """
    — Извини́те, вы не зна́ете, где метро́?
    — Да, коне́чно! Иди́те пря́мо, пото́м поверни́те нале́во. Метро́ бу́дет на углу́.
    — Э́то далеко́?
    — Нет, мину́т пять пешко́м.
    — Спаси́бо большо́е!
    — Не за что!
    """, translation: """
    "Excuse me, do you know where the metro is?" "Yes! Go straight, then turn left. The metro will be on the corner." "Is it far?" "No, about five minutes on foot." "Thank you!" "You're welcome!"
    """, notes: "Вы не зна́ете = polite softener.", isDialogue: true),

    ReadingText(title: "В магази́не", source: "At the grocery store", difficulty: "Beginner", body: """
    Я зашёл в магази́н купи́ть хлеб и молоко́. В магази́не бы́ло мно́го люде́й. Я взял корзи́ну и пошёл по отде́лам. Снача́ла я вы́брал хлеб — чёрный, как обы́чно. Пото́м я нашёл молоко́, но оста́лась то́лько одна́ буты́лка. На ка́ссе де́вушка спроси́ла: «Паке́т ну́жен?» Я сказа́л: «Да, пожа́луйста». В ито́ге я заплати́л сто пятьдеся́т рубле́й.
    """, translation: """
    I stopped by the store to buy bread and milk. The store was crowded. I grabbed a basket and went through the aisles. First I picked bread — black, as usual. Then I found milk, but only one bottle was left. At the register, the cashier asked: "Need a bag?" I said: "Yes, please." In total, I paid 150 rubles.
    """, notes: "Зашёл = dropped in (perfective). Корзи́ну = basket (Accusative).", isDialogue: false),

    ReadingText(title: "Разгово́р по телефо́ну", source: "Phone conversation", difficulty: "Intermediate", body: """
    — Алло́!
    — Приве́т, Ле́на! Э́то Ди́ма. Ты сейча́с свобо́дна?
    — Ой, приве́т! Да, а что?
    — Ду́маю пойти́ в кино́ сего́дня ве́чером. Не хо́чешь со мно́й?
    — С удово́льствием! А что идёт?
    — Како́й-то но́вый фи́льм. Говоря́т, интере́сный.
    — Хорошо́. Во ско́лько и где встре́тимся?
    — Дава́й в шесть у метро́.
    — Договори́лись! До встре́чи!
    """, translation: """
    "Hi, Lena! It's Dima. Are you free right now?" "Oh, hi! Yeah, what's up?" "Thinking of going to the movies tonight. Want to come?" "With pleasure! What's playing?" "Some new film. They say it's interesting." "Okay. When and where?" "Let's say six at the metro." "Deal! See you!"
    """, notes: "Дава́й в шесть = Let's at six (dropping verb). Договори́лись! = Deal!", isDialogue: true),

    ReadingText(title: "У врача́", source: "At the doctor", difficulty: "Intermediate", body: """
    Пацие́нт зашёл в кабине́т и се́л на сту́л. Врач спроси́ла: «На что жа́луетесь?» Пацие́нт отве́тил: «У меня́ боли́т горло́ и температу́ра уже́ три дня». Врач осмотре́ла го́рло и сказа́ла: «Э́то анги́на. Я вы́пишу антибио́тики. Принима́йте их три ра́за в день по́сле еды́. И бо́льше пейте тёплое». Пацие́нт поблагодари́л и ушёл в апте́ку.
    """, translation: """
    The patient entered the office. The doctor asked: "What are your complaints?" The patient said: "My throat hurts and I've had a temperature for three days." The doctor examined the throat: "It's tonsillitis. I'll prescribe antibiotics. Take them three times a day after meals. And drink more warm liquids." The patient thanked her and went to the pharmacy.
    """, notes: "На что жа́луетесь? = standard doctor question. Анги́на = tonsillitis.", isDialogue: false),

    ReadingText(title: "Пла́ны на вы́ходные", source: "Weekend plans", difficulty: "Intermediate", body: """
    Вчера́ мы с дру́гом обсужда́ли пла́ны на вы́ходные. Он предложи́л пое́хать за́ город — там у его́ роди́телей есть да́ча. Я никогда́ не́ был на да́че зимо́й, поэ́тому согласи́лся. Мы реши́ли вы́ехать в суббо́ту у́тром, что́бы не стоя́ть в про́бках. Друг сказа́л, что мы бу́дем жа́рить шашлы́к и па́риться в ба́не. Звучи́т отли́чно! Я уже́ купи́л тёплые ве́щи — обеща́ют ми́нус пятна́дцать.
    """, translation: """
    Yesterday my friend and I were discussing weekend plans. He suggested going out of town — his parents have a dacha there. I've never been to a dacha in winter, so I agreed. We decided to leave Saturday morning to avoid traffic. My friend said we'll grill shashlik and use the banya. Sounds great! I already bought warm clothes — they're forecasting minus fifteen.
    """, notes: "Да́ча = Russian country house. Шашлы́к = BBQ. Ба́ня = sauna. Про́бки = traffic jams.", isDialogue: false),

    ReadingText(title: "В соцсетя́х", source: "Social media chat", difficulty: "Intermediate", body: """
    Смотре́л вчера́ ле́нту в телегра́ме — така́я тоска́. Одни́ но́вости про поли́тику и́ли рекла́ма. Реши́л отпи́сываться от полови́ны кана́лов. А пото́м наткну́лся на прико́льный кана́л про ру́сскую ку́хню. Там ба́бушка гото́вит и расска́зывает. Я да́же реце́пт сохрани́л — хочу́ попро́бовать сде́лать пельме́ни. Правда, те́сто у меня́ никогда́ не получа́ется как на́до. Мо́жет, ты поможешь? Ты же ма́стер по пельме́ням!
    """, translation: """
    Was scrolling through my Telegram feed yesterday — so boring. Just political news or ads. Decided to unsubscribe from half the channels. Then I stumbled on a funny channel about Russian cooking. This grandma cooks and tells stories. I even saved a recipe — want to try making pelmeni. Though my dough never turns out right. Maybe you can help? You're the pelmeni master after all!
    """, notes: "Ле́нта = social feed. Тоска́ = boredom. Наткну́лся = stumbled upon. Ты же ма́стер = you ARE a master (же = after all).", isDialogue: false),
]
