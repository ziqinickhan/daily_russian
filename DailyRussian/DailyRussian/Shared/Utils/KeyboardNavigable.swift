import SwiftUI

/// Adds arrow-key navigation to any list of items with UUID-based selection.
struct KeyboardNavigable: ViewModifier {
    @Binding var selectedID: UUID?
    let itemIDs: [UUID]

    func body(content: Content) -> some View {
        content
            .focusable()
            .onMoveCommand { direction in
                guard !itemIDs.isEmpty else { return }
                let currentIndex: Int
                if let id = selectedID, let idx = itemIDs.firstIndex(of: id) {
                    currentIndex = idx
                } else {
                    currentIndex = direction == .down ? -1 : itemIDs.count
                }
                switch direction {
                case .up:   selectedID = itemIDs[max(0, currentIndex - 1)]
                case .down: selectedID = itemIDs[min(itemIDs.count - 1, currentIndex + 1)]
                default: break
                }
            }
    }
}

extension View {
    func keyboardNavigable(selectedID: Binding<UUID?>, itemIDs: [UUID]) -> some View {
        modifier(KeyboardNavigable(selectedID: selectedID, itemIDs: itemIDs))
    }
}
