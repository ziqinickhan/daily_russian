import SwiftUI
import CoreData

/// iOS-adapted grammar reference — searchable, filterable list, tap for detail.
struct IOSGrammarView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GrammarNote.category, ascending: true),
            NSSortDescriptor(keyPath: \GrammarNote.title, ascending: true)
        ]
    )
    private var notes: FetchedResults<GrammarNote>

    @State private var searchText = ""
    @State private var selectedTag: String? = nil

    var tags: [(String, Int)] {
        var counts: [String: Int] = [:]
        for n in notes { counts[n.category ?? "?", default: 0] += 1 }
        return [("All", notes.count)] + counts.sorted(by: { $0.0 < $1.0 }).map { ($0.0, $0.1) }
    }

    var filteredNotes: [GrammarNote] {
        notes.filter { note in
            if !searchText.isEmpty {
                guard (note.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                      (note.content ?? "").localizedCaseInsensitiveContains(searchText)
                else { return false }
            }
            if let tag = selectedTag, tag != "All", note.category != tag { return false }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tag filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.0) { tag, count in
                            Button {
                                selectedTag = (tag == "All") ? nil : tag
                            } label: {
                                HStack(spacing: 3) {
                                    Text(tag).font(.caption)
                                    Text("\(count)").font(.caption2).foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(
                                    (selectedTag == tag || (tag == "All" && selectedTag == nil))
                                    ? Color.accentColor : Color.gray.opacity(0.12)
                                )
                                .foregroundStyle(
                                    (selectedTag == tag || (tag == "All" && selectedTag == nil))
                                    ? .white : .primary
                                )
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                // Note list
                List {
                    ForEach(filteredNotes, id: \.id) { note in
                        NavigationLink {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(note.title ?? "").font(.title2).fontWeight(.bold)
                                        Spacer()
                                    }
                                    Text(note.content ?? "").font(.body)
                                }
                                .padding()
                            }
                            .navigationTitle(note.title ?? "")
                            .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title ?? "").font(.headline)
                                Text(firstLine(of: note.content ?? ""))
                                    .font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Grammar")
            .searchable(text: $searchText, prompt: "Search grammar...")
        }
    }

    private func firstLine(of text: String) -> String {
        text.components(separatedBy: .newlines).first { !$0.isEmpty && !$0.hasPrefix("**") } ?? text
    }
}
