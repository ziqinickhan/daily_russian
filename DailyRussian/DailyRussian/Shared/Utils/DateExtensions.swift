import Foundation

extension Date {
    /// Returns true if the date is today (same calendar day).
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Returns true if the date is in the past.
    var isPast: Bool {
        self < Date()
    }

    /// Number of days between self and another date.
    func daysSince(_ other: Date) -> Int {
        Calendar.current.dateComponents([.day], from: other, to: self).day ?? 0
    }
}

extension Int16 {
    var asInt: Int { Int(self) }
}
