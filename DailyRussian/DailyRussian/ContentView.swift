import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        IOSTabView()
        #elseif os(macOS)
        MacOSSidebarView()
        #else
        Text("Unsupported platform")
        #endif
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
        case grammar = "Grammar"
        case reading = "Reading"
        case news = "News"
        case culture = "Culture"
        case aiChat = "AI Tutor"

        var icon: String {
            switch self {
            case .dashboard: return "chart.bar"
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
