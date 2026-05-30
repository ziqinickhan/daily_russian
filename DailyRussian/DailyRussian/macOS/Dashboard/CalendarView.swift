import SwiftUI
import CoreData

/// Study calendar showing daily activity as a heat map.
struct StudyCalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySession.date, ascending: true)]
    )
    private var sessions: FetchedResults<StudySession>

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Study Calendar")
                    .font(.headline)
                Spacer()
                Text("Last 12 weeks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Day-of-week headers
            HStack(spacing: 4) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInLast12Weeks(), id: \.self) { day in
                    if let day = day {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(colorForDay(day))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                if calendar.isDateInToday(day) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color.accentColor, lineWidth: 1.5)
                                }
                            }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.quaternary)
                        .frame(width: 12, height: 12)
                    Text("None")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 12, height: 12)
                    Text("Light")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green.opacity(0.7))
                        .frame(width: 12, height: 12)
                    Text("Medium")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    Text("Intense")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Streak info
            streakView
        }
        .padding()
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Streak

    private var streakView: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text("Current streak:")
                .font(.subheadline)
            Text("\(currentStreak) days")
                .font(.subheadline)
                .fontWeight(.bold)
            Spacer()
            Text("Best: \(bestStreak) days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var currentStreak: Int {
        var streak = 0
        var date = Date()
        let activeDays = Set(sessions.compactMap { session in
            session.date.map { calendar.startOfDay(for: $0) }
        })
        while activeDays.contains(calendar.startOfDay(for: date)) {
            streak += 1
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }

    private var bestStreak: Int {
        let activeDays = Set(sessions.compactMap { session in
            session.date.map { calendar.startOfDay(for: $0) }
        }).sorted()
        guard !activeDays.isEmpty else { return 0 }
        var best = 1, current = 1
        for i in 1..<activeDays.count {
            let daysBetween = calendar.dateComponents([.day], from: activeDays[i-1], to: activeDays[i]).day ?? 2
            if daysBetween == 1 {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }
        return best
    }

    // MARK: - Calendar Helpers

    private func daysInLast12Weeks() -> [Date?] {
        let end = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: -84, to: end) else { return [] }
        // Pad to start on Monday
        let weekday = calendar.component(.weekday, from: start)
        let mondayOffset = (weekday + 5) % 7 // Monday = 0
        var days: [Date?] = Array(repeating: nil, count: mondayOffset)
        var current = start
        while current <= end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return days
    }

    private func colorForDay(_ day: Date) -> Color {
        let dayStart = calendar.startOfDay(for: day)
        let count = sessions.filter {
            guard let d = $0.date else { return false }
            return calendar.startOfDay(for: d) == dayStart
        }.count

        switch count {
        case 0: return Color.gray.opacity(0.15)
        case 1: return .green.opacity(0.3)
        case 2: return .green.opacity(0.5)
        case 3...4: return .green.opacity(0.7)
        default: return .green
        }
    }
}
