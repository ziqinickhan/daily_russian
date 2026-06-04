import SwiftUI
import Combine

/// Shared navigation state — allows cross-section navigation.
final class AppNavigation: ObservableObject {
    /// Set to a word UUID to navigate to Vocabulary and select that word.
    @Published var navigateToVocabWithWord: UUID?

    /// Set alongside navigateToVocabWithWord — the section to return to.
    @Published var previousSection: String = "Dashboard"

    /// Toggle this to trigger a navigation back from Vocabulary.
    @Published var shouldNavigateBack = false
}
