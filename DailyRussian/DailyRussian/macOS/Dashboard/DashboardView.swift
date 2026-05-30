import SwiftUI
import CoreData

/// Progress dashboard showing learning stats.
struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WordEntry.dateAdded, ascending: false)]
    )
    private var allWords: FetchedResults<WordEntry>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySession.date, ascending: false)]
    )
    private var sessions: FetchedResults<StudySession>

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Total Words",
                    value: "\(allWords.count)",
                    icon: "text.book.closed",
                    color: .blue
                )
                StatCard(
                    title: "Learned",
                    value: "\(learnedCount)",
                    icon: "checkmark.seal",
                    color: .green
                )
                StatCard(
                    title: "Due for Review",
                    value: "\(dueCount)",
                    icon: "clock",
                    color: dueCount > 0 ? .orange : .gray
                )
                StatCard(
                    title: "Study Sessions",
                    value: "\(sessions.count)",
                    icon: "calendar",
                    color: .purple
                )
            }
            .padding()

            // Study calendar heat map
            StudyCalendarView()
                .padding(.horizontal)

            // Recent sessions
            if !sessions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Sessions")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(sessions.prefix(10)) { session in
                        sessionRow(session)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Dashboard")
    }

    private var learnedCount: Int {
        allWords.filter(\.isLearned).count
    }

    private var dueCount: Int {
        let now = Date()
        return allWords.filter { word in
            guard let nextReview = word.nextReview else { return true }
            return nextReview <= now
        }.count
    }

    private func sessionRow(_ session: StudySession) -> some View {
        HStack {
            Image(systemName: session.platform == "iOS" ? "iphone" : "laptopcomputer")
                .frame(width: 24)
            Text(session.date ?? Date(), style: .date)
            Spacer()
            Text("\(session.wordsReviewed) reviewed")
                .foregroundStyle(.secondary)
            Text("•")
                .foregroundStyle(.secondary)
            Text("\(session.wordsLearned) learned")
                .foregroundStyle(.secondary)
        }
        .font(.callout)
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}
