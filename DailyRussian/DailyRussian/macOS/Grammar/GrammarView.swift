import SwiftUI
import CoreData

/// Grammar reference — flat list of all notes with tag pills, tap for detail.
struct GrammarView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GrammarNote.category, ascending: true),
            NSSortDescriptor(keyPath: \GrammarNote.title, ascending: true)
        ]
    )
    private var notes: FetchedResults<GrammarNote>

    @State private var selectedNoteID: UUID?

    var selectedNote: GrammarNote? {
        guard let id = selectedNoteID else { return nil }
        return notes.first { $0.id == id }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Flat list of all notes
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(notes, id: \.id) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(note.title ?? "")
                                    .font(.headline)
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
                        .background(
                            selectedNoteID == note.id
                                ? Color.accentColor.opacity(0.1)
                                : Color.clear
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { selectedNoteID = note.id }
                        Divider().padding(.leading, 12)
                    }
                }
            }
            .frame(minWidth: 280, idealWidth: 320)

            Divider()

            // Detail panel
            if let note = selectedNote {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(note.title ?? "")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            TagBadge(category: note.category ?? "")
                        }

                        // Render content with markdown-like formatting
                        renderContent(note.content ?? "")
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "book.pages")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Select a grammar note")
                        .font(.headline)
                    Text("All 45 notes are shown on the left — tap any to read.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Grammar")
    }

    private func firstLine(of text: String) -> String {
        text.components(separatedBy: .newlines).first { !$0.isEmpty && !$0.hasPrefix("**") } ?? text
    }

    @ViewBuilder
    private func renderContent(_ text: String) -> some View {
        let lines = text.components(separatedBy: "\n")
        ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                Spacer().frame(height: 4)
            } else if trimmed.hasPrefix("**") && trimmed.hasSuffix(":**") {
                Text(trimmed.replacingOccurrences(of: "**", with: ""))
                    .font(.headline)
                    .padding(.top, 8)
            } else if trimmed.hasPrefix("💡") {
                HStack(alignment: .top, spacing: 6) {
                    Text("💡").font(.callout)
                    Text(String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces))
                        .font(.callout)
                        .italic()
                        .foregroundStyle(.orange)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            } else if trimmed.hasPrefix("•") {
                HStack(alignment: .top, spacing: 8) {
                    Text("•").font(.body).foregroundStyle(.secondary)
                    Text(String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces))
                        .font(.body)
                }
            } else if trimmed.hasPrefix("1.") || trimmed.hasPrefix("2.") || trimmed.hasPrefix("3.") || trimmed.hasPrefix("4.") {
                HStack(alignment: .top, spacing: 8) {
                    Text(String(trimmed.prefix(2))).font(.body).foregroundStyle(.secondary)
                    Text(String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces))
                        .font(.body)
                }
            } else {
                Text(trimmed)
                    .font(.body)
            }
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
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
