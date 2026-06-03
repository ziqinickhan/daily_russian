import SwiftUI
import CoreData

/// Grammar reference — searchable, filterable flat list with tag pills, tap for detail.
struct GrammarView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GrammarNote.category, ascending: true),
            NSSortDescriptor(keyPath: \GrammarNote.title, ascending: true)
        ]
    )
    private var allNotes: FetchedResults<GrammarNote>

    @State private var selectedNoteID: UUID?
    @State private var searchText = ""
    @State private var selectedTag: String? = nil

    // Distinct tags with counts
    var tags: [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for n in allNotes { counts[n.category ?? "?", default: 0] += 1 }
        return [("All", allNotes.count)] + counts.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) }
    }

    var filteredNotes: [GrammarNote] {
        var result = Array(allNotes)
        if !searchText.isEmpty {
            result = result.filter {
                ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.content ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        if let tag = selectedTag, tag != "All" {
            result = result.filter { $0.category == tag }
        }
        return result
    }

    var selectedNote: GrammarNote? {
        guard let id = selectedNoteID else { return nil }
        return allNotes.first { $0.id == id }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Note list with search + filter
            VStack(spacing: 0) {
                // Search bar
                TextField("Search grammar notes...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)

                // Tag filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.name) { tag in
                            Button {
                                selectedTag = (tag.name == "All") ? nil : tag.name
                                selectedNoteID = nil
                            } label: {
                                HStack(spacing: 3) {
                                    Text(tag.name)
                                        .font(.caption)
                                    Text("\(tag.count)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    (selectedTag == tag.name || (tag.name == "All" && selectedTag == nil))
                                        ? tagColor(tag.name)
                                        : Color.gray.opacity(0.12)
                                )
                                .foregroundStyle(
                                    (selectedTag == tag.name || (tag.name == "All" && selectedTag == nil))
                                        ? .white
                                        : .primary
                                )
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.bottom, 8)

                Divider()

                // Note list
                if filteredNotes.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass").font(.largeTitle).foregroundStyle(.secondary)
                        Text("No notes match").font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredNotes, id: \.id) { note in
                                noteRow(note)
                                Divider().padding(.leading, 12)
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 300, idealWidth: 340)

            Divider()

            // Detail panel
            if let note = selectedNote {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(note.title ?? "").font(.title2).fontWeight(.bold)
                            Spacer()
                            TagBadge(category: note.category ?? "")
                        }
                        renderContent(note.content ?? "")
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "book.pages").font(.largeTitle).foregroundStyle(.secondary)
                    Text("Select a grammar note").font(.headline)
                    Text("\(allNotes.count) notes — search, filter by tag, or scroll to browse.").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Grammar")
    }

    private func noteRow(_ note: GrammarNote) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.title ?? "").font(.headline)
                Spacer()
                TagBadge(category: note.category ?? "")
            }
            Text(firstLine(of: note.content ?? ""))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selectedNoteID == note.id ? Color.accentColor.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { selectedNoteID = note.id }
    }

    private func firstLine(of text: String) -> String {
        text.components(separatedBy: .newlines)
            .first { !$0.isEmpty && !$0.hasPrefix("**") } ?? text
    }

    @ViewBuilder
    private func renderContent(_ text: String) -> some View {
        ForEach(Array(text.components(separatedBy: "\n").enumerated()), id: \.offset) { _, line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                Spacer().frame(height: 4)
            } else if trimmed.hasPrefix("**"), trimmed.hasSuffix(":**") {
                Text(trimmed.replacingOccurrences(of: "**", with: ""))
                    .font(.headline).padding(.top, 8)
            } else if trimmed.hasPrefix("💡") {
                HStack(alignment: .top, spacing: 6) {
                    Text("💡").font(.callout)
                    Text(String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces))
                        .font(.callout).italic().foregroundStyle(.orange)
                }
                .padding(.vertical, 4).padding(.horizontal, 10)
                .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            } else if trimmed.hasPrefix("•") {
                HStack(alignment: .top, spacing: 8) {
                    Text("•").font(.body).foregroundStyle(.secondary)
                    Text(String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces)).font(.body)
                }
            } else {
                Text(trimmed).font(.body)
            }
        }
    }

    private func tagColor(_ name: String) -> Color {
        switch name.lowercased() {
        case "case", "cases": return .purple
        case "verb", "verbs": return .blue
        case "grammar": return .indigo
        case "preposition", "prepositions": return .teal
        case "adjective", "adjectives": return .pink
        case "noun", "nouns": return .orange
        case "expression": return .green
        case "vocabulary": return .cyan
        case "phrases": return .mint
        default: return .accentColor
        }
    }
}

// MARK: - Tag Badge

struct TagBadge: View {
    let category: String
    var color: Color {
        switch category.lowercased() {
        case "case", "cases": return .purple
        case "verb", "verbs": return .blue
        case "grammar": return .indigo
        case "preposition", "prepositions": return .teal
        case "adjective", "adjectives": return .pink
        case "noun", "nouns": return .orange
        case "expression": return .green
        case "vocabulary": return .cyan
        case "phrases": return .mint
        default: return .gray
        }
    }

    var body: some View {
        Text(category.lowercased())
            .font(.caption2).fontWeight(.medium)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.12)).foregroundStyle(color)
            .clipShape(Capsule())
    }
}
