import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let sampleWord = WordEntry(context: viewContext)
        sampleWord.id = UUID()
        sampleWord.word = "приве́т"
        sampleWord.translation = "hello"
        sampleWord.partOfSpeech = "interjection"
        sampleWord.difficulty = 1
        sampleWord.dateAdded = Date()
        sampleWord.reviewCount = 0
        sampleWord.reviewInterval = 0
        sampleWord.easeFactor = 2.5
        try? viewContext.save()
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Use local store first (CloudKit needs iCloud container configured in dev portal).
        // To enable sync later: switch to NSPersistentCloudKitContainer.
        let storeURL: URL
        if inMemory {
            storeURL = URL(fileURLWithPath: "/dev/null")
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            storeURL = appSupport.appendingPathComponent("DailyRussian.sqlite")
            // Ensure directory exists
            try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }

        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container = NSPersistentContainer(name: "DailyRussian")
        container.persistentStoreDescriptions = [storeDescription]

        container.loadPersistentStores { [container] _, error in
            if let error = error {
                print("Store load error: \(error.localizedDescription)")
            } else {
                print("Store loaded at: \(storeURL.path)")
                let ctx = container.viewContext
                SeedDataProvider(context: ctx).seedIfNeeded()
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var feedbackLogger: FeedbackLogger {
        FeedbackLogger(context: container.viewContext)
    }

    /// Re-run seeding (resets all data).
    func reseed() {
        let entities = ["WordEntry", "PhraseEntry", "GrammarNote", "StudySession", "CulturalItem", "FeedbackEvent"]
        let ctx = container.viewContext
        ctx.perform {
            for entity in entities {
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                let delete = NSBatchDeleteRequest(fetchRequest: fetch)
                _ = try? ctx.execute(delete)
            }
            try? ctx.save()
            SeedDataProvider(context: ctx).seedIfNeeded()
        }
    }
}
