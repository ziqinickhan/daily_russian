import SwiftUI

/// Russian news stories — filterable by topic, hover words for translation.
struct NewsView: View {
    @State private var selectedStoryID: UUID?
    @State private var selectedTags: Set<String> = []
    @State private var translationExpanded = true
    @FocusState private var isSearchFocused: Bool

    private let tts = TTSProvider()

    var allTopics: [String] { Array(Set(stories.map { $0.topic })).sorted() }

    var filteredStories: [NewsStory] {
        if selectedTags.isEmpty { return stories }
        return stories.filter { selectedTags.contains($0.topic) }
    }

    var selectedStory: NewsStory? {
        guard let id = selectedStoryID else { return nil }
        return stories.first { $0.id == id }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left panel: filters + story list
            VStack(spacing: 0) {
                // Topic filter
                FilterRow(title: "Topic", options: allTopics, selected: $selectedTags)
                    .padding(10)

                Divider()

                Text("\(filteredStories.count) stories")
                    .font(.caption).foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                Divider()

                if filteredStories.isEmpty {
                    ContentUnavailableView("No matches", systemImage: "newspaper")
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredStories) { story in
                                storyRow(story)
                                Divider().padding(.leading, 10)
                            }
                        }
                    }
                    .keyboardNavigable(selectedID: $selectedStoryID, itemIDs: filteredStories.map { $0.id })
                }
            }
            .frame(minWidth: 260, idealWidth: 300)

            Divider()

            // Right: full story
            if let story = selectedStory {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(story.headline)
                                .font(.title2).fontWeight(.bold)
                            Text(story.englishHeadline)
                                .font(.subheadline).foregroundStyle(.secondary)
                            TopicBadge(topic: story.topic)
                        }

                        RussianFlowText(text: story.body)
                            .lineSpacing(8)
                            .textSelection(.enabled)

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Vocabulary").font(.headline)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                                ForEach(story.vocabulary, id: \.word) { item in
                                    HStack(alignment: .top, spacing: 4) {
                                        Text(item.word).font(.caption).fontWeight(.medium)
                                        Text("—").font(.caption).foregroundStyle(.secondary)
                                        Text(item.translation).font(.caption).foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))

                        DisclosureGroup("Translation", isExpanded: $translationExpanded) {
                            Text(story.translation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(24)
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
                    Image(systemName: "newspaper").font(.largeTitle).foregroundStyle(.secondary)
                    Text("Select a story").font(.headline)
                    Text("\(stories.count) stories — hover any word to see translation.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("News")
    }

    private func storyRow(_ story: NewsStory) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(story.headline).font(.headline).lineLimit(2)
            Text(story.englishHeadline)
                .font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            TopicBadge(topic: story.topic)
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selectedStoryID == story.id ? Color.accentColor.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { selectedStoryID = story.id; translationExpanded = true }
    }
}

// MARK: - Model

struct NewsStory: Identifiable, Hashable {
    let id = UUID()
    let headline: String
    let englishHeadline: String
    let topic: String
    let body: String
    let translation: String
    let vocabulary: [(word: String, translation: String)]
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: NewsStory, rhs: NewsStory) -> Bool { lhs.id == rhs.id }
}

// MARK: - Stories

private let stories: [NewsStory] = [
    NewsStory(headline: "Но́вый музе́й иску́сства в Москве́", englishHeadline: "New Art Museum in Moscow", topic: "Culture", body: "В Москве́ откры́лся но́вый музе́й совреме́нного иску́сства. Музе́й нахо́дится в це́нтре го́рода, в истори́ческом зда́нии XIX ве́ка. В колле́кции — бо́лее 500 рабо́т ру́сских худо́жников XX и XXI веко́в. На откры́тии бы́ли изве́стные худо́жники, писа́тели и журнали́сты. Дире́ктор музе́я сказа́л, что э́то ва́жное собы́тие для ру́сской культу́ры.", translation: "A new museum of modern art has opened in Moscow. The museum is located in the city center, in a historic 19th-century building. The collection includes more than 500 works by Russian artists of the 20th and 21st centuries.", vocabulary: [("откры́лся","opened"),("нахо́дится","is located"),("худо́жник","artist"),("собы́тие","event")]),
    NewsStory(headline: "Золоты́е меда́ли на чемпиона́те ми́ра", englishHeadline: "Gold Medals at World Championships", topic: "Sports", body: "Росси́йские спортсме́ны завоева́ли пять золоты́х меда́лей на чемпиона́те ми́ра по лёгкой атле́тике. Соревнова́ния проходи́ли в Берли́не. Осо́бенно успе́шно вы́ступили бегуны́ на сре́дние диста́нции. Тре́нер сбо́рной сказа́л журнали́стам, что кома́нда гото́вилась к э́тому старту́ два го́да.", translation: "Russian athletes won five gold medals at the World Athletics Championships. The competition took place in Berlin. Middle-distance runners performed particularly well.", vocabulary: [("завоева́ли","won"),("чемпиона́т ми́ра","world championship"),("лёгкая атле́тика","track and field"),("вы́ступили","performed")]),
    NewsStory(headline: "Неде́ля ру́сской литерату́ры в Петербу́рге", englishHeadline: "Russian Literature Week in Petersburg", topic: "Culture", body: "В Санкт-Петербу́рге стартова́ла ежего́дная неде́ля ру́сской литерату́ры. В програ́мме — встре́чи с писа́телями, чте́ния стихо́в и презента́ции но́вых книг. В э́том году́ осо́бое внима́ние уделя́ется молоды́м а́вторам. Го́сти фестива́ля мо́гут не то́лько послу́шать выступле́ния, но и купи́ть кни́ги с а́втографами.", translation: "The annual Russian Literature Week has begun in Saint Petersburg. The program includes meetings with writers, poetry readings, and presentations of new books. Special attention is given to young authors.", vocabulary: [("стартова́ла","launched"),("ежего́дная","annual"),("встре́чи","meetings"),("внима́ние","attention")]),
    NewsStory(headline: "Анома́льная жара́ в Москве́", englishHeadline: "Heatwave in Moscow", topic: "Weather", body: "В Москве́ установи́лась необы́чно жа́ркая пого́да. Температу́ра достига́ет +32°C, что на 10 гра́дусов вы́ше климати́ческой но́рмы для ма́я. Жи́тели го́рода жа́луются в социа́льных сетя́х. Врачи́ рекомен́дуют пить бо́льше воды́ и избега́ть со́лнца в середи́не дня.", translation: "Unusually hot weather has settled in Moscow. Temperatures are reaching +32°C (90°F), which is 10 degrees above the norm for May. City residents are complaining on social media.", vocabulary: [("жа́луются","complain"),("жара́","heat"),("установи́лась","settled in"),("избега́ть","to avoid")]),
    NewsStory(headline: "Но́вый парк в це́нтре Каза́ни", englishHeadline: "New Park in Central Kazan", topic: "City Life", body: "В це́нтре Каза́ни откры́лся но́вый городско́й парк площа́дью пять гекта́ров. В па́рке есть велодоро́жки, де́тские площа́дки и небольшо́е о́зеро. Ме́стные жи́тели давно́ проси́ли мэ́рию о зелёной зо́не. На откры́тии мэ́р сказа́л, что парк постро́или за два го́да.", translation: "A new city park spanning five hectares has opened in the center of Kazan. The park features bike paths, playgrounds, and a small lake. Local residents had long been asking for a green zone.", vocabulary: [("площа́дью","area of"),("велодоро́жки","bike paths"),("жи́тели","residents"),("мэ́рия","city hall")]),
    NewsStory(headline: "Ру́сский фильм победи́л в Ка́ннах", englishHeadline: "Russian Film Wins at Cannes", topic: "Culture", body: "Фильм ру́сского режиссёра получи́л гла́вный приз на междунаро́дном кинофестива́ле в Ка́ннах. Карти́на расска́зывает о жи́зни обы́чной семьи́ в небольшо́м сиби́рском го́роде. Кри́тики назва́ли фи́льм «глубо́ким и трога́тельным».", translation: "A Russian director's film won the top prize at Cannes. The picture tells the story of an ordinary family in a small Siberian town. Critics called it 'deep and touching.'", vocabulary: [("режиссёр","director"),("гла́вный приз","main prize"),("карти́на","picture/film"),("обы́чный","ordinary")]),
    NewsStory(headline: "Приложе́ние для изуче́ния ру́сского языка́", englishHeadline: "App for Learning Russian", topic: "Tech", body: "Гру́ппа студе́нтов из Новосиби́рска созда́ла моби́льное приложе́ние для изуче́ния ру́сского языка́. В приложе́нии есть слова́рь, упражне́ния, и да́же возмо́жность обща́ться с носи́телем языка́. Разрабо́тчики говоря́т, что приложе́нием уже́ по́льзуются бо́лее 10 ты́сяч челове́к.", translation: "Students from Novosibirsk created a mobile app for learning Russian. The app includes a dictionary, exercises, and even the ability to chat with a native speaker. Over 10,000 people already use it.", vocabulary: [("приложе́ние","app"),("слова́рь","dictionary"),("обща́ться","communicate"),("носи́тель языка́","native speaker")]),
    NewsStory(headline: "Дре́вний го́род найден в Крыму́", englishHeadline: "Ancient City Found in Crimea", topic: "Science", body: "Архео́логи обнаружи́ли дре́вний го́род на ю́жном берегу́ Кры́ма. По слова́м учёных, го́роду бо́лее двух ты́сяч лет. Среди нахо́док — моне́ты, кера́мика и оста́тки кре́постных сте́н. Э́то откры́тие мо́жет измени́ть представле́ние об исто́рии регио́на.", translation: "Archaeologists discovered an ancient city on the southern coast of Crimea. According to scientists, the city is more than two thousand years old. Finds include coins, pottery, and fortress walls.", vocabulary: [("обнару́жили","discovered"),("дре́вний","ancient"),("нахо́дки","finds"),("раско́пки","excavations")]),
]
