import SwiftUI

/// Russian news stories for reading practice with hover-to-translate words.
struct NewsView: View {
    @State private var selectedStory: NewsStory?

    private let tts = TTSProvider()

    var body: some View {
        HStack(spacing: 0) {
            // Story list
            List(stories, selection: $selectedStory) { story in
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.headline)
                        .font(.headline)
                        .lineLimit(2)
                    HStack {
                        Text(story.date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(story.topic)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.15), in: Capsule())
                    }
                }
                .padding(.vertical, 4)
                .tag(story as NewsStory?)
            }
            .frame(width: 220)
            .listStyle(.sidebar)
            .navigationTitle("News")

            Divider()

            // Story detail — full story on right
            if let story = selectedStory {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(story.headline)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack {
                            Text(story.date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("·")
                                .foregroundStyle(.secondary)
                            Text(story.topic)
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }

                        // Russian text with hover translation
                        RussianFlowText(text: story.body)
                            .lineSpacing(8)
                            .textSelection(.enabled)

                        Divider()

                        // Key vocabulary
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Vocabulary")
                                .font(.headline)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                                ForEach(story.vocabulary, id: \.word) { item in
                                    HStack(alignment: .top, spacing: 4) {
                                        Text(item.word)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Text("—")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(item.translation)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))

                        // Translation
                        DisclosureGroup("Show full translation") {
                            Text(story.translation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .toolbar {
                    ToolbarItem {
                        Button { tts.speak(story.body) } label: {
                            Image(systemName: "speaker.wave.2")
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "newspaper")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Select a story")
                        .font(.headline)
                    Text("Hover over any word to see its translation. Click 'View in Vocabulary' to study it deeper.")
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

struct NewsStory: Identifiable, Hashable {
    let id = UUID()
    let headline: String
    let date: String
    let topic: String
    let body: String
    let translation: String
    let vocabulary: [(word: String, translation: String)]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: NewsStory, rhs: NewsStory) -> Bool { lhs.id == rhs.id }
}

// MARK: - Stories

private let stories: [NewsStory] = [
    NewsStory(headline: "В Росси́и откры́лся но́вый музе́й совреме́нного иску́сства", date: "2026-05-28", topic: "Culture", body: """
    В Москве́ откры́лся но́вый музе́й совреме́нного иску́сства. Музе́й нахо́дится в це́нтре го́рода, в истори́ческом зда́нии XIX ве́ка. В колле́кции — бо́лее 500 рабо́т ру́сских худо́жников XX и XXI веко́в. На откры́тии бы́ли изве́стные худо́жники, писа́тели и журнали́сты. Дире́ктор музе́я сказа́л, что э́то ва́жное собы́тие для ру́сской культу́ры.
    """, translation: """
    A new museum of modern art has opened in Moscow. The museum is located in the city center, in a historic 19th-century building. The collection includes more than 500 works by Russian artists of the 20th and 21st centuries. Famous artists, writers, and journalists attended the opening. The museum director said this is an important event for Russian culture.
    """, vocabulary: [("откры́лся", "opened (reflexive)"), ("нахо́дится", "is located"), ("истори́ческое зда́ние", "historic building"), ("худо́жник", "artist"), ("собы́тие", "event"), ("совреме́нное иску́сство", "modern art")]),

    NewsStory(headline: "Золоты́е меда́ли ру́сских спортсме́нов на чемпиона́те ми́ра", date: "2026-05-25", topic: "Sports", body: """
    Росси́йские спортсме́ны завоева́ли пять золоты́х меда́лей на чемпиона́те ми́ра по лёгкой атле́тике. Соревнова́ния проходи́ли в Берли́не с 20 по 24 ма́я. Осо́бенно успе́шно вы́ступили бегуны́ на сре́дние диста́нции. Тре́нер сбо́рной сказа́л журнали́стам, что кома́нда гото́вилась к э́тому старту́ два го́да.
    """, translation: """
    Russian athletes won five gold medals at the World Athletics Championships. The competition took place in Berlin from May 20 to 24. Middle-distance runners performed particularly well. The national team coach told journalists that the team had been preparing for this event for two years.
    """, vocabulary: [("завоева́ли", "won / conquered"), ("чемпиона́т ми́ра", "world championship"), ("лёгкая атле́тика", "track and field"), ("вы́ступили", "performed"), ("гото́вилась", "prepared (reflexive)"), ("меда́ль", "medal")]),

    NewsStory(headline: "В Санкт-Петербу́рге начала́сь неде́ля ру́сской литерату́ры", date: "2026-05-22", topic: "Literature", body: """
    В Санкт-Петербу́рге стартова́ла ежего́дная неде́ля ру́сской литерату́ры. В програ́мме — встре́чи с писа́телями, чте́ния стихо́в и презента́ции но́вых книг. В э́том году́ осо́бое внима́ние уделя́ется молоды́м а́вторам. Го́сти фестива́ля мо́гут не то́лько послу́шать выступле́ния, но и купи́ть кни́ги с а́втографами.
    """, translation: """
    The annual Russian Literature Week has begun in Saint Petersburg. The program includes meetings with writers, poetry readings, and presentations of new books. This year, special attention is being given to young authors. Festival guests can not only listen to presentations but also buy signed books.
    """, vocabulary: [("стартова́ла", "started / launched"), ("ежего́дная", "annual"), ("встре́чи", "meetings"), ("внима́ние", "attention"), ("а́втограф", "autograph"), ("молоды́е а́вторы", "young authors")]),

    NewsStory(headline: "Москвичи́ жа́луются на жару́: температу́ра вы́ше но́рмы", date: "2026-05-20", topic: "Weather", body: """
    В Москве́ установи́лась необы́чно жа́ркая пого́да. Температу́ра достига́ет +32°C, что на 10 гра́дусов вы́ше климати́ческой но́рмы для ма́я. Жи́тели го́рода жа́луются в социа́льных сетя́х. Врачи́ рекомен́дуют пить бо́льше воды́ и избега́ть со́лнца в середи́не дня. Синопти́ки обеща́ют, что жара́ спадёт к выходны́м.
    """, translation: """
    Unusually hot weather has settled in Moscow. Temperatures are reaching +32°C (90°F), which is 10 degrees above the climate norm for May. City residents are complaining on social media. Doctors recommend drinking more water and avoiding the sun in the middle of the day. Forecasters promise the heat will ease by the weekend.
    """, vocabulary: [("жа́луются", "complain (reflexive)"), ("жара́", "heat"), ("установи́лась", "settled in"), ("избега́ть", "to avoid"), ("синопти́к", "weather forecaster")]),

    NewsStory(headline: "Но́вый парк откры́лся в центре Каза́ни", date: "2026-05-18", topic: "City Life", body: """
    В це́нтре Каза́ни откры́лся но́вый городско́й парк площа́дью пять гекта́ров. В па́рке есть велодоро́жки, де́тские площа́дки и небольшо́е о́зеро. Ме́стные жи́тели давно́ проси́ли мэ́рию о зелёной зо́не. На откры́тии мэ́р сказа́л, что парк постро́или за два го́да и на э́то потра́тили 200 миллио́нов рубле́й. Сейча́с в па́рке уже́ гуля́ют се́мьи с детьми́.
    """, translation: """
    A new city park spanning five hectares has opened in the center of Kazan. The park features bike paths, playgrounds, and a small lake. Local residents had long been asking the city hall for a green zone. At the opening, the mayor said the park was built in two years at a cost of 200 million rubles. Families with children are already strolling in the park.
    """, vocabulary: [("площа́дью", "with an area of"), ("велодоро́жки", "bike paths"), ("жи́тели", "residents"), ("мэ́рия", "city hall"), ("постро́или", "built (perfective)")]),

    NewsStory(headline: "Ру́сский фильм получи́л приз на междунаро́дном фестива́ле", date: "2026-05-15", topic: "Cinema", body: """
    Фильм ру́сского режиссёра получи́л гла́вный приз на междунаро́дном кинофестива́ле в Ка́ннах. Карти́на расска́зывает о жи́зни обы́чной семьи́ в небольшо́м сиби́рском го́роде. Кри́тики назва́ли фи́льм «глубо́ким и трога́тельным». Режиссёр поблагодари́л съёмочную гру́ппу и сказа́л, что э́та побе́да — результа́т пяти́ лет рабо́ты.
    """, translation: """
    A film by a Russian director has won the top prize at the Cannes International Film Festival. The picture tells the story of an ordinary family in a small Siberian town. Critics called the film "deep and touching." The director thanked the film crew and said this victory is the result of five years of work.
    """, vocabulary: [("режиссёр", "director"), ("гла́вный приз", "main prize"), ("карти́на", "picture / film"), ("обы́чный", "ordinary"), ("поблагодари́л", "thanked (perfective)")]),

    NewsStory(headline: "Студе́нты созда́ли приложе́ние для изуче́ния ру́сского языка́", date: "2026-05-12", topic: "Tech", body: """
    Гру́ппа студе́нтов из Новосиби́рска созда́ла моби́льное приложе́ние для изуче́ния ру́сского языка́. В приложе́нии есть слова́рь, упражне́ния, и да́же возмо́жность обща́ться с носи́телем языка́. Разрабо́тчики говор́ят, что приложе́нием уже́ по́льзуются бо́лее 10 ты́сяч челове́к. В бу́дущем они́ плани́руют доба́вить ещё и други́е языки́.
    """, translation: """
    A group of students from Novosibirsk has created a mobile app for learning Russian. The app includes a dictionary, exercises, and even the ability to chat with a native speaker. The developers say more than 10,000 people are already using the app. In the future, they plan to add other languages as well.
    """, vocabulary: [("приложе́ние", "app / application"), ("слова́рь", "dictionary"), ("обща́ться", "to communicate"), ("носи́тель языка́", "native speaker"), ("разрабо́тчик", "developer"), ("по́льзуются", "use (reflexive)")]),

    NewsStory(headline: "Архео́логи нашли́ дре́вний го́род в Крыму́", date: "2026-05-08", topic: "Science", body: """
    Архео́логи обнаружи́ли дре́вний го́род на ю́жном берегу́ Кры́ма. По слова́м учёных, го́роду бо́лее двух ты́сяч лет. Среди нахо́док — моне́ты, кера́мика и оста́тки кре́постных сте́н. Э́то откры́тие мо́жет измени́ть представле́ние об исто́рии регио́на. Раско́пки бу́дут продолжа́ться до конца́ ле́та.
    """, translation: """
    Archaeologists have discovered an ancient city on the southern coast of Crimea. According to scientists, the city is more than two thousand years old. Among the finds are coins, pottery, and remains of fortress walls. This discovery could change our understanding of the region's history. Excavations will continue until the end of summer.
    """, vocabulary: [("обнару́жили", "discovered"), ("дре́вний", "ancient"), ("нахо́дки", "finds / discoveries"), ("кре́постные сте́ны", "fortress walls"), ("представле́ние", "understanding / idea"), ("раско́пки", "excavations")]),
]
