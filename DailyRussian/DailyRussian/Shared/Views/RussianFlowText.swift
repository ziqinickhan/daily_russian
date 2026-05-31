import SwiftUI
import CoreData

/// Renders Russian text with hoverable words — hover to see translation from your dictionary.
struct RussianFlowText: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var navigation: AppNavigation

    let text: String
    var showTranslation: Bool = true

    // Extract words (keeping punctuation attached)
    private var tokens: [String] {
        text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                let (word, punct) = splitWordPunct(token)
                if let lookup = lookupWord(word) {
                    HoverableWord(
                        word: word,
                        punct: punct,
                        translation: lookup.translation,
                        isInDict: true,
                        wordID: lookup.id
                    )
                } else {
                    Text(word + punct)
                        .font(.body)
                }
            }
        }
    }

    private func splitWordPunct(_ token: String) -> (word: String, punct: String) {
        // Strip leading/trailing punctuation for dictionary lookup
        let chars = Array(token)
        var start = 0, end = chars.count
        var leading = "", trailing = ""

        while start < end, !chars[start].isLetter {
            leading.append(chars[start])
            start += 1
        }
        while end > start, !chars[end-1].isLetter {
            trailing.insert(chars[end-1], at: trailing.startIndex)
            end -= 1
        }

        let word = String(chars[start..<end])
        if start == 0 && end == chars.count {
            return (token, "")
        }
        return (word, trailing)
    }

    private func lookupWord(_ word: String) -> (translation: String, id: UUID)? {
        let clean = word.lowercased().replacingOccurrences(of: "́", with: "").replacingOccurrences(of: "̀", with: "")
        let fetch: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        fetch.predicate = NSPredicate(format: "word CONTAINS[cd] %@ OR word CONTAINS[cd] %@", clean, word)
        fetch.fetchLimit = 3
        guard let results = try? viewContext.fetch(fetch), !results.isEmpty else { return nil }

        // Best match: exact word match
        let exact = results.first {
            ($0.word ?? "").replacingOccurrences(of: "́", with: "").replacingOccurrences(of: "̀", with: "")
                .lowercased() == clean
        }
        let match = exact ?? results.first!
        return (match.translation ?? "?", match.id ?? UUID())
    }
}

// MARK: - Hoverable Word

struct HoverableWord: View {
    @EnvironmentObject private var navigation: AppNavigation

    let word: String
    let punct: String
    let translation: String
    let isInDict: Bool
    let wordID: UUID

    @State private var isHovering = false

    var body: some View {
        #if os(macOS)
        Text(word + punct)
            .font(.body)
            .underline(isHovering, color: .blue)
            .background(isHovering ? Color.blue.opacity(0.08) : Color.clear, in: RoundedRectangle(cornerRadius: 3))
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) { isHovering = hovering }
            }
            .popover(isPresented: $isHovering, arrowEdge: .bottom) {
                wordPopover
            }
        #else
        // iOS: tap to see
        Button {
            // iOS doesn't have hover; use tap
        } label: {
            Text(word + punct)
                .font(.body)
                .underline(isInDict, color: .blue.opacity(0.3))
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
                isHovering = false
            } label: {
                Label("View in Vocabulary", systemImage: "arrow.right.circle")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .frame(width: 250)
    }
}

// MARK: - Flow Layout

/// Simple flow layout (wraps to next line).
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(proposal.width ?? 0, subviews: subviews)
        let height = rows.last.map { $0.maxY } ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(bounds.width, subviews: subviews)
        for row in rows {
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
            if currentX + size.width > width && !currentItems.isEmpty {
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
