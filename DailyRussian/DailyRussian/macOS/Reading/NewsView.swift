import SwiftUI

/// Russian news stories for reading practice.
/// Uses curated short stories with vocabulary extraction.
struct NewsView: View {
    @State private var selectedStory: NewsStory?

    private let tts = TTSProvider()

    var body: some View {
        HStack(spacing: 0) {
            // Story list
            List(newsStories, selection: $selectedStory) { story in
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.headline)
                        .font(.headline)
                        .lineLimit(2)
                    Text(story.date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(story.topic)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
                .padding(.vertical, 4)
                .tag(story as NewsStory?)
            }
            .frame(width: 220)
            .listStyle(.sidebar)

            Divider()

            // Story detail
            if let story = selectedStory {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(story.headline)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(story.body)
                            .font(.body)
                            .lineSpacing(8)
                            .textSelection(.enabled)

                        Divider()

                        // Key vocabulary
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Vocabulary")
                                .font(.headline)

                            ForEach(story.vocabulary, id: \.word) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Text(item.word)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(width: 100, alignment: .leading)

                                    Text("—")

                                    Text(item.translation)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))

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
                        Button {
                            tts.speak(story.body)
                        } label: {
                            Image(systemName: "speaker.wave.2")
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "Select a story",
                    systemImage: "newspaper"
                )
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("News")
    }
}

// MARK: - News Story Model

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

// MARK: - Sample News Stories

private let newsStories: [NewsStory] = [
    NewsStory(
        headline: "В Росси́и откры́лся но́вый музе́й совреме́нного иску́сства",
        date: "2026-05-28",
        topic: "Culture",
        body: """
        В Москве́ откры́лся но́вый музе́й совреме́нного иску́сства. Музе́й нахо́дится в це́нтре го́рода, в исто́рическом зда́нии XIX ве́ка. В колле́кции — бо́лее 500 рабо́т ру́сских худо́жников XX и XXI веко́в. На откры́тии бы́ли изве́стные худо́жники, писа́тели и журнали́сты. Дире́ктор музе́я сказа́л, что э́то ва́жное собы́тие для ру́сской культу́ры.
        """,
        translation: """
        A new museum of modern art has opened in Moscow. The museum is located in the city center, in a historic 19th-century building. The collection includes more than 500 works by Russian artists of the 20th and 21st centuries. Famous artists, writers, and journalists attended the opening. The museum director said this is an important event for Russian culture.
        """,
        vocabulary: [
            ("откры́лся", "opened (reflexive)"),
            ("музе́й", "museum"),
            ("совреме́нное иску́сство", "modern art"),
            ("нахо́дится", "is located"),
            ("истори́ческое зда́ние", "historic building"),
            ("худо́жник", "artist"),
            ("собы́тие", "event"),
        ]
    ),
    NewsStory(
        headline: "Золоты́е меда́ли ру́сских спортсме́нов на чемпиона́те ми́ра",
        date: "2026-05-25",
        topic: "Sports",
        body: """
        Росси́йские спортсме́ны завоева́ли пять золоты́х меда́лей на чемпиона́те ми́ра по лёгкой атле́тике. Соревнова́ния проходи́ли в Берли́не с 20 по 24 ма́я. Осо́бенно успе́шно вы́ступили бегуны́ на сре́дние диста́нции. Тре́нер сбо́рной сказа́л журнали́стам, что кома́нда гото́вилась к э́тому старту́ два го́да.
        """,
        translation: """
        Russian athletes won five gold medals at the World Athletics Championships. The competition took place in Berlin from May 20 to 24. Middle-distance runners performed particularly well. The national team coach told journalists that the team had been preparing for this event for two years.
        """,
        vocabulary: [
            ("завоева́ли", "won / conquered"),
            ("золоты́е меда́ли", "gold medals"),
            ("чемпиона́т ми́ра", "world championship"),
            ("лёгкая атле́тика", "track and field"),
            ("вы́ступили", "performed"),
            ("гото́вилась", "prepared (reflexive)"),
        ]
    ),
    NewsStory(
        headline: "В Санкт-Петербу́рге начала́сь неде́ля ру́сской литерату́ры",
        date: "2026-05-22",
        topic: "Literature",
        body: """
        В Санкт-Петербу́рге стартова́ла ежего́дная неде́ля ру́сской литерату́ры. В програ́мме — встре́чи с писа́телями, чте́ния стихо́в и презента́ции но́вых книг. В э́том году́ осо́бое внима́ние уделя́ется молоды́м а́вторам. Го́сти фестива́ля мо́гут не то́лько послу́шать выступле́ния, но и купи́ть кни́ги с а́втографами.
        """,
        translation: """
        The annual Russian Literature Week has begun in Saint Petersburg. The program includes meetings with writers, poetry readings, and presentations of new books. This year, special attention is being given to young authors. Festival guests can not only listen to presentations but also buy signed books.
        """,
        vocabulary: [
            ("стартова́ла", "started / launched"),
            ("ежего́дная", "annual"),
            ("встре́чи", "meetings"),
            ("чте́ния", "readings"),
            ("внима́ние", "attention"),
            ("а́втор", "author"),
            ("а́втограф", "autograph / signature"),
        ]
    ),
    NewsStory(
        headline: "Москвичи́ жа́луются на жару́: температу́ра вы́ше но́рмы",
        date: "2026-05-20",
        topic: "Weather",
        body: """
        В Москве́ установи́лась необы́чно жа́ркая пого́да. Температу́ра достига́ет +32°C, что на 10 гра́дусов вы́ше климати́ческой но́рмы для ма́я. Жи́тели го́рода жа́луются в социа́льных сетя́х. Врачи́ рекомен́дуют пить бо́льше воды́ и избега́ть со́лнца в середи́не дня. Синопти́ки обеща́ют, что жара́ спадёт к выходны́м.
        """,
        translation: """
        Unusually hot weather has settled in Moscow. Temperatures are reaching +32°C (90°F), which is 10 degrees above the climate norm for May. City residents are complaining on social media. Doctors recommend drinking more water and avoiding the sun in the middle of the day. Forecasters promise the heat will ease by the weekend.
        """,
        vocabulary: [
            ("жа́луются", "complain (reflexive)"),
            ("жара́", "heat"),
            ("установи́лась", "settled in / established itself"),
            ("достига́ет", "reaches"),
            ("врач", "doctor"),
            ("избега́ть", "to avoid"),
            ("синопти́к", "weather forecaster"),
        ]
    ),
]
