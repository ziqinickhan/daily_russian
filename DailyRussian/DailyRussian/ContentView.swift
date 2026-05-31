import SwiftUI

struct ContentView: View {
    var body: some View {
        Group {
            #if os(iOS)
            IOSTabView()
            #elseif os(macOS)
            MacOSSidebarView()
            #else
            Text("Unsupported platform")
            #endif
        }
        .modifier(SeedOnAppear())
    }
}

// MARK: - Seed On First Appear (safety net)

struct SeedOnAppear: ViewModifier {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var hasChecked = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasChecked else { return }
                hasChecked = true
                // If data didn't get seeded during store load, do it now
                let fetch: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
                fetch.fetchLimit = 1
                let count = (try? viewContext.count(for: fetch)) ?? 0
                if count == 0 {
                    SeedDataProvider(context: viewContext).seedIfNeeded()
                }
            }
    }
}

// MARK: - iOS Layout (Tab-based)

#if os(iOS)
struct IOSTabView: View {
    var body: some View {
        TabView {
            DailyDoseView()
                .tabItem {
                    Label("Learn", systemImage: "text.book.closed")
                }

            ReviewView()
                .tabItem {
                    Label("Review", systemImage: "clock")
                }

            QuickLookView()
                .tabItem {
                    Label("Words", systemImage: "character.book.closed")
                }
        }
    }
}
#endif

// MARK: - macOS Layout (Sidebar)

#if os(macOS)
struct MacOSSidebarView: View {
    enum Section: String, CaseIterable {
        case dashboard = "Dashboard"
        case vocabulary = "Vocabulary"
        case grammar = "Grammar"
        case reading = "Reading"
        case news = "News"
        case culture = "Culture"
        case aiChat = "AI Tutor"

        var icon: String {
            switch self {
            case .dashboard: return "chart.bar"
            case .vocabulary: return "character.book.closed"
            case .grammar: return "book.pages"
            case .reading: return "text.book.closed"
            case .news: return "newspaper"
            case .culture: return "music.note.list"
            case .aiChat: return "bubble.left.and.text.bubble.right"
            }
        }
    }

    @State private var selectedSection: Section = .dashboard

    var body: some View {
        NavigationSplitView {
            List(Section.allCases, id: \.self, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("Daily Russian")
            .frame(minWidth: 180)
        } detail: {
            switch selectedSection {
            case .dashboard:
                DashboardView()
            case .vocabulary:
                VocabularyView()
            case .grammar:
                GrammarView()
            case .reading:
                ReadingView()
            case .news:
                NewsView()
            case .culture:
                CultureView()
            case .aiChat:
                AIChatView()
            }
        }
    }
}
#endif
