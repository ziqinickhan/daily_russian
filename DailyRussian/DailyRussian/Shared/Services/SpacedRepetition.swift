import Foundation

/// Implements the SM-2 spaced repetition algorithm (SuperMemo 2).
/// Determines when a word should be reviewed next based on recall quality.
enum SpacedRepetition {

    /// Quality ratings for recall.
    /// 0 = complete blackout, 5 = perfect recall.
    typealias Quality = Int

    /// Result of a review: the new interval and ease factor to store.
    struct ReviewResult {
        let interval: Double    // days until next review
        let easeFactor: Double  // new ease factor
        let nextReview: Date    // when to review next
    }

    /// Compute the next review schedule using SM-2.
    ///
    /// - Parameters:
    ///   - quality: How well the user recalled the word (0–5).
    ///   - currentInterval: Current interval in days.
    ///   - currentEaseFactor: Current ease factor (default 2.5).
    ///   - reviewCount: Number of times this word has been reviewed.
    /// - Returns: New interval, ease factor, and next review date.
    static func schedule(
        quality: Quality,
        currentInterval: Double,
        currentEaseFactor: Double = 2.5,
        reviewCount: Int
    ) -> ReviewResult {
        let clampedQuality = max(0, min(5, quality))

        // Compute new ease factor (minimum 1.3)
        let efDelta = 0.1 - Double(5 - clampedQuality) * (0.08 + Double(5 - clampedQuality) * 0.02)
        var newEF = currentEaseFactor + efDelta
        if newEF < 1.3 { newEF = 1.3 }

        let newInterval: Double

        if clampedQuality < 3 {
            // Failed recall — reset
            newInterval = 1.0
        } else {
            switch reviewCount {
            case 0:
                newInterval = 1.0
            case 1:
                newInterval = 6.0
            default:
                newInterval = currentInterval * newEF
            }
        }

        let nextReview = Calendar.current.date(
            byAdding: .day,
            value: Int(ceil(newInterval)),
            to: Date()
        ) ?? Date().addingTimeInterval(newInterval * 86400)

        return ReviewResult(
            interval: newInterval,
            easeFactor: newEF,
            nextReview: nextReview
        )
    }
}
