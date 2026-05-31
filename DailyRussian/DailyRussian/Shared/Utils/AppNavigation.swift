import SwiftUI
import Combine

/// Shared navigation state — allows cross-section navigation (e.g., "jump to vocabulary with this word").
final class AppNavigation: ObservableObject {
    @Published var navigateToVocabWithWord: UUID?
}
