import CoreData

final class PersistenceController {
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
        container = NSPersistentContainer(name: "DailyRussian")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Store in Application Support
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory, in: .userDomainMask
            ).first!
            try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
            let storeURL = appSupport.appendingPathComponent("DailyRussian.sqlite")

            let description = NSPersistentStoreDescription(url: storeURL)
            // Enable lightweight migration for model changes
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                // If migration fails or store is corrupt, delete and recreate
                print("Store load failed: \(error.localizedDescription) — recreating...")
                self.destroyStore()
                self.container.loadPersistentStores { _, retryError in
                    if let retryError = retryError {
                        print("Retry also failed: \(retryError.localizedDescription)")
                    } else {
                        print("Store recreated successfully")
                        SeedDataProvider(context: self.container.viewContext).seedIfNeeded()
                    }
                }
            } else {
                print("Store loaded successfully")
                SeedDataProvider(context: self.container.viewContext).seedIfNeeded()
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var feedbackLogger: FeedbackLogger {
        FeedbackLogger(context: container.viewContext)
    }

    /// Re-run seeding (resets all data).
    func reseed() {
        let ctx = container.viewContext
        ctx.perform {
            let entities = ["WordEntry", "PhraseEntry", "GrammarNote", "StudySession", "CulturalItem", "FeedbackEvent"]
            for entity in entities {
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                let delete = NSBatchDeleteRequest(fetchRequest: fetch)
                _ = try? ctx.execute(delete)
            }
            try? ctx.save()
            SeedDataProvider(context: ctx).seedIfNeeded()
        }
    }

    private func destroyStore() {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else { return }
        let baseURL = storeURL.deletingLastPathComponent()
        let storeName = storeURL.deletingPathExtension().lastPathComponent
        let files = try? FileManager.default.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil)
        files?.filter { $0.lastPathComponent.contains(storeName) }.forEach {
            try? FileManager.default.removeItem(at: $0)
        }
    }
}
