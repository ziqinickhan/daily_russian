import SwiftUI

/// Cultural references — books, songs, movies with Russian learning value.
struct CultureView: View {
    @State private var selectedType: ItemType = .books

    enum ItemType: String, CaseIterable {
        case books = "Books"
        case songs = "Songs"
        case movies = "Movies"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Type", selection: $selectedType) {
                ForEach(ItemType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(itemsForType(selectedType)) { item in
                        CulturalItemCard(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Culture")
    }

    private func itemsForType(_ type: ItemType) -> [CulturalItemData] {
        switch type {
        case .books: return sampleBooks
        case .songs: return sampleSongs
        case .movies: return sampleMovies
        }
    }
}

// MARK: - Data Models

struct CulturalItemData: Identifiable {
    let id = UUID()
    let title: String
    let creator: String
    let description: String
    let keyVocab: [String]
}

struct CulturalItemCard: View {
    let item: CulturalItemData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
            Text(item.creator)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(item.description)
                .font(.callout)
                .foregroundStyle(.primary)

            if !item.keyVocab.isEmpty {
                Text("Key vocabulary: \(item.keyVocab.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Sample Data

private let sampleBooks: [CulturalItemData] = [
    CulturalItemData(
        title: "Мастер и Маргарита",
        creator: "Михаил Булгаков",
        description: "A masterpiece of 20th-century Russian literature blending political satire, religion, and magic in Stalin-era Moscow.",
        keyVocab: ["мастер", "роман", "дьявол", "любовь", "Москва"]
    ),
    CulturalItemData(
        title: "Преступление и наказание",
        creator: "Фёдор Достоевский",
        description: "A psychological novel exploring morality and redemption through the eyes of a poor ex-student who commits murder.",
        keyVocab: ["преступление", "наказание", "совесть", "душа", "бедный"]
    )
]

private let sampleSongs: [CulturalItemData] = [
    CulturalItemData(
        title: "Кукушка",
        creator: "Виктор Цой / Кино",
        description: "Iconic Russian rock song about freedom, fate, and the passage of time.",
        keyVocab: ["кукушка", "свобода", "судьба", "время", "песня"]
    )
]

private let sampleMovies: [CulturalItemData] = [
    CulturalItemData(
        title: "Брат",
        creator: "Алексей Балабанов",
        description: "A cult classic about a young man navigating post-Soviet Saint Petersburg's criminal underworld.",
        keyVocab: ["брат", "город", "сила", "правда", "русский"]
    ),
    CulturalItemData(
        title: "Москва слезам не верит",
        creator: "Владимир Меньшов",
        description: "Oscar-winning Soviet melodrama following three women over 20 years in Moscow.",
        keyVocab: ["Москва", "слеза", "верить", "любовь", "жизнь"]
    )
]
