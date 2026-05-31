import SwiftUI
import CoreData

/// Grammar reference — category → note → detail. Uses tap gestures to avoid nested List selection conflicts.
struct GrammarView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GrammarNote.dateAdded, ascending: false)]
    )
    private var notes: FetchedResults<GrammarNote>

    @State private var selectedNoteID: UUID?
    @State private var selectedCategory: String?

    var categories: [String] {
        let all = Set(notes.map { $0.category ?? "" })
        return Array(all).sorted()
    }

    var filteredNotes: [GrammarNote] {
        guard let cat = selectedCategory else { return [] }
        return notes.filter { $0.category == cat }
    }

    var selectedNote: GrammarNote? {
        guard let id = selectedNoteID else { return nil }
        return notes.first { $0.id == id }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Category list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(categories, id: \.self) { category in
                        HStack {
                            Label(category, systemImage: iconForCategory(category))
                                .font(.callout)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selectedCategory == category ? Color.accentColor.opacity(0.12) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCategory = category
                            selectedNoteID = nil
                        }
                    }
                }
            }
            .frame(width: 170)

            Divider()

            // Note list
            if let _ = selectedCategory {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredNotes, id: \.id) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title ?? "")
                                    .font(.headline)
                                Text(note.content ?? "")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedNoteID == note.id ? Color.accentColor.opacity(0.1) : Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedNoteID = note.id
                            }
                            Divider()
                        }
                    }
                }
                .frame(width: 250)
            } else {
                ContentUnavailableView("Select a category", systemImage: "sidebar.left")
                    .frame(width: 250)
            }

            Divider()

            // Detail panel
            if let note = selectedNote {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(note.title ?? "")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(note.content ?? "")
                            .font(.body)
                            .textSelection(.enabled)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ContentUnavailableView("Select a note", systemImage: "text.page")
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
        case "adjective", "adjectives": return "paintpalette"
        case "noun", "nouns": return "textformat.abc"
        case "grammar": return "book.pages"
        case "expression": return "bubble.left"
        case "vocabulary": return "character.book.closed"
        case "phrases": return "text.bubble"
        default: return "doc.text"
        }
    }
}
