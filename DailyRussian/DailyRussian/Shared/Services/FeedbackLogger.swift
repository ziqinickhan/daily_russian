import CoreData
import OSLog

/// Logs user interactions for quality improvement.
/// All data stays local in the user's iCloud — no analytics, no tracking.
struct FeedbackLogger {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: "com.nickhan.DailyRussian", category: "Feedback")

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    enum EventType: String {
        case screenView = "screen_view"
        case reviewComplete = "review_complete"
        case wordLearned = "word_learned"
        case grammarRead = "grammar_read"
        case readingOpened = "reading_opened"
        case aiAsked = "ai_asked"
        case error = "error"
        case appLaunch = "app_launch"
    }

    /// Log a user event.
    func log(
        type: EventType,
        detail: String? = nil,
        metadata: [String: String] = [:]
    ) {
        // Create a background context for thread safety
        let bgContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bgContext.parent = context

        bgContext.perform {
            let event = FeedbackEvent(context: bgContext)
            event.id = UUID()
            event.timestamp = Date()
            event.type = type.rawValue
            event.detail = detail
            event.platform = {
                #if os(iOS)
                return "iOS"
                #elseif os(macOS)
                return "macOS"
                #else
                return "unknown"
                #endif
            }()

            // Store metadata as JSON
            if !metadata.isEmpty, let json = try? JSONEncoder().encode(metadata) {
                event.metadata = String(data: json, encoding: .utf8)
            }

            do {
                try bgContext.save()
                self.logger.debug("Logged: \(type.rawValue)")
            } catch {
                self.logger.error("Failed to log event: \(error.localizedDescription)")
            }
        }
    }
}
