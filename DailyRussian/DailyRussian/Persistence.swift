import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Seed a sample word for previews
        let sampleWord = WordEntry(context: viewContext)
        sampleWord.id = UUID()
        sampleWord.word = "привет"
        sampleWord.translation = "hello"
        sampleWord.partOfSpeech = "interjection"
        sampleWord.difficulty = 1
        sampleWord.dateAdded = Date()
        sampleWord.isLearned = false
        sampleWord.reviewCount = 0
        sampleWord.reviewInterval = 0
        sampleWord.easeFactor = 2.5

        do {
            try viewContext.save()
        } catch {
            fatalError("Preview setup error: \(error)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "DailyRussian")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { [container] _, error in
            if let error = error as NSError? {
                print("Persistent store load error: \(error.localizedDescription)")
            } else {
                // Seed initial vocabulary and grammar on first launch
                let ctx = container.viewContext
                DispatchQueue.main.async {
                    SeedDataProvider(context: ctx).seedIfNeeded()
                }
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// Convenience logger using the shared view context.
    var feedbackLogger: FeedbackLogger {
        FeedbackLogger(context: container.viewContext)
    }
}
