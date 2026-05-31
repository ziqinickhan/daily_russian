import SwiftUI
import CoreData

/// Renders Russian text with interactive words — hover highlights, click shows translation.
struct RussianFlowText: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var navigation: AppNavigation

    let text: String

    private var tokens: [String] {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    // Cache inflected-form lookups
    @State private var formCache: [String: (String, UUID)] = [:]
    @State private var cacheBuilt = false

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                let (word, punct) = splitWordPunct(token)
                if let lookup = lookupAnyForm(word) {
                    HoverableWord(
                        word: word,
                        punct: punct,
                        translation: lookup.translation,
                        wordID: lookup.id
                    )
                } else {
                    Text(word + punct)
                        .font(.body)
                }
            }
        }
        .onAppear { buildFormCache() }
    }

    private func splitWordPunct(_ token: String) -> (word: String, punct: String) {
        let chars = Array(token)
        var start = 0, end = chars.count
        while start < end, !chars[start].isLetter { start += 1 }
        while end > start, !chars[end-1].isLetter { end -= 1 }
        let word = String(chars[start..<end])
        if start == 0 && end == chars.count { return (token, "") }
        return (word, String(chars[end..<chars.count]))
    }

    // MARK: - Inflected form lookup

    private func buildFormCache() {
        guard !cacheBuilt else { return }
        cacheBuilt = true
        let fetch: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        fetch.predicate = NSPredicate(format: "caseForms != nil OR conjugation != nil")
        fetch.fetchLimit = 2000
        guard let results = try? viewContext.fetch(fetch) else { return }

        let stripAccents: (String) -> String = { $0.replacingOccurrences(of: "́", with: "").replacingOccurrences(of: "̀", with: "") }

        for entry in results {
            // Check case forms
            if let json = entry.caseForms,
               let data = json.data(using: .utf8),
               let cases = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
                for (_, form) in cases {
                    let key = stripAccents(form).lowercased()
                    if !key.isEmpty && formCache[key] == nil {
                        formCache[key] = (entry.translation ?? "?", entry.id ?? UUID())
                    }
                }
            }
            // Check conjugations
            if let json = entry.conjugation,
               let data = json.data(using: .utf8),
               let conj = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
                for (_, form) in conj {
                    let key = stripAccents(form).lowercased()
                    if !key.isEmpty && formCache[key] == nil {
                        formCache[key] = (entry.translation ?? "?", entry.id ?? UUID())
                    }
                }
            }
        }
    }

    private func lookupAnyForm(_ word: String) -> (translation: String, id: UUID)? {
        let stripAccents: (String) -> String = { $0.replacingOccurrences(of: "́", with: "").replacingOccurrences(of: "̀", with: "") }
        let clean = stripAccents(word).lowercased()

        // 1. Direct word match (fast, same as before)
        let direct: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        direct.predicate = NSPredicate(format: "word CONTAINS[cd] %@", clean)
        direct.fetchLimit = 5
        if let results = try? viewContext.fetch(direct), !results.isEmpty {
            let exact = results.first {
                stripAccents($0.word ?? "").lowercased() == clean
            }
            let match = exact ?? results.first!
            return (match.translation ?? "?", match.id ?? UUID())
        }

        // 2. Inflected form cache lookup
        if let cached = formCache[clean] {
            return cached
        }

        return nil
    }
}

// MARK: - Hoverable Word (hover highlights, click shows popover)

struct HoverableWord: View {
    @EnvironmentObject private var navigation: AppNavigation

    let word: String
    let punct: String
    let translation: String
    let wordID: UUID

    @State private var isHovering = false
    @State private var showPopover = false
    @State private var dismissWorkItem: DispatchWorkItem?

    var body: some View {
        #if os(macOS)
        Text(word + punct)
            .font(.body)
            .underline(isHovering || showPopover, color: .blue)
            .background(
                (isHovering || showPopover) ? Color.blue.opacity(0.08) : Color.clear,
                in: RoundedRectangle(cornerRadius: 3)
            )
            .onHover { hovering in
                dismissWorkItem?.cancel()
                if hovering {
                    isHovering = true
                    showPopover = true
                } else {
                    isHovering = false
                    // Delay dismissal so user can move mouse to popover
                    let work = DispatchWorkItem {
                        showPopover = false
                    }
                    dismissWorkItem = work
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
                }
            }
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                wordPopover
            }
        #else
        Button {
            // iOS uses tap
        } label: {
            Text(word + punct)
                .font(.body)
                .underline(true, color: .blue.opacity(0.3))
        }
        .buttonStyle(.plain)
        #endif
    }

    private var wordPopover: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(word)
                .font(.headline)
            Text(translation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Button {
                navigation.navigateToVocabWithWord = wordID
                showPopover = false
            } label: {
                Label("View in Vocabulary", systemImage: "arrow.right.circle")
                    .font(.caption)
            }
            .buttonStyle(.borderless)

            Text("Click outside to dismiss")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(minWidth: 220)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(proposal.width ?? 0, subviews: subviews)
        return CGSize(width: proposal.width ?? 0, height: rows.last?.maxY ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for row in arrange(bounds.width, subviews: subviews) {
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + row.y),
                    proposal: .unspecified
                )
            }
        }
    }

    private struct FlowItem { let index: Int; let x: CGFloat; let size: CGSize }
    private struct FlowRow { let items: [FlowItem]; let y: CGFloat; let maxY: CGFloat }

    private func arrange(_ width: CGFloat, subviews: Subviews) -> [FlowRow] {
        var rows: [FlowRow] = []
        var currentItems: [FlowItem] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for (i, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width, !currentItems.isEmpty {
                rows.append(FlowRow(items: currentItems, y: currentY, maxY: currentY + lineHeight))
                currentItems = []
                currentY += lineHeight + spacing
                currentX = 0
                lineHeight = 0
            }
            currentItems.append(FlowItem(index: i, x: currentX, size: size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        if !currentItems.isEmpty {
            rows.append(FlowRow(items: currentItems, y: currentY, maxY: currentY + lineHeight))
        }
        return rows
    }
}
