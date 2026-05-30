import SwiftUI
import CoreData

/// Grammar reference — category list → note list → note detail.
/// Designed to live inside the parent NavigationSplitView detail pane.
struct GrammarView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GrammarNote.dateAdded, ascending: false)]
    )
    private var notes: FetchedResults<GrammarNote>

    @State private var selectedNote: GrammarNote?
    @State private var selectedCategory: String?

    var categories: [String] {
        let all = Set(notes.map { $0.category ?? "" })
        return Array(all).sorted()
    }

    var filteredNotes: [GrammarNote] {
        guard let category = selectedCategory else { return [] }
        return notes.filter { $0.category == category }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Category list
            List(categories, id: \.self, selection: $selectedCategory) { category in
                Label(category, systemImage: iconForCategory(category))
                    .tag(category as String?)
            }
            .frame(width: 180)
            .listStyle(.sidebar)

            Divider()

            // Note list for selected category
            if let _ = selectedCategory {
                List(filteredNotes, selection: $selectedNote) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title ?? "")
                            .font(.headline)
                        Text(note.content ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                    .tag(note as GrammarNote?)
                }
                .frame(width: 250)
            } else {
                ContentUnavailableView(
                    "Select a category",
                    systemImage: "sidebar.left"
                )
                .frame(width: 250)
            }

            Divider()

            // Note detail
            if let note = selectedNote {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(note.title ?? "")
                            .font(.title)
                            .fontWeight(.bold)
                        Text(note.content ?? "")
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ContentUnavailableView(
                    "Select a note",
                    systemImage: "text.page"
                )
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Grammar")
    }

    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "case", "cases": return "rectangle.3.group"
        case "verb", "verbs": return "arrow.triangle.branch"
        case "preposition", "prepositions": return "arrow.up.and.down"
        case "aspect", "aspects": return "circle.lefthalf.filled"
        default: return "book.pages"
        }
    }
}
