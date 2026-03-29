import CoreData
import Foundation

enum PersistenceController {
    static func makeContainer(inMemory: Bool) -> NSPersistentContainer {
        let model = CoreDataModelFactory.makeManagedObjectModel()
        let container = NSPersistentContainer(name: "AuriTailsNormalizedState", managedObjectModel: model)
        container.persistentStoreDescriptions = [makeStoreDescription(inMemory: inMemory)]
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load Core Data store: \(error.localizedDescription)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }

    private static func makeStoreDescription(inMemory: Bool) -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription()
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            let directory = applicationSupport.appendingPathComponent("AuriTails", isDirectory: true)
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            description.url = directory.appendingPathComponent("AuriTailsNormalized.sqlite")
        }
        description.type = NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false
        return description
    }
}
