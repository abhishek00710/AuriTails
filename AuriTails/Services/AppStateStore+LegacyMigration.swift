import CoreData
import Foundation

extension AppStateStore {
    func loadLegacyPayloadState() -> PersistedAppState? {
        let directory = (FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory)
            .appendingPathComponent("AuriTails", isDirectory: true)
        let legacyURL = directory.appendingPathComponent("AuriTailsState.sqlite")
        guard FileManager.default.fileExists(atPath: legacyURL.path) else {
            return nil
        }

        let model = CoreDataModelFactory.makeLegacyManagedObjectModel()
        let container = NSPersistentContainer(name: "AuriTailsLegacyState", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: legacyURL)
        description.type = NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        guard loadError == nil else { return nil }

        let request = NSFetchRequest<NSManagedObject>(entityName: "PersistedStateEntity")
        request.fetchLimit = 1
        guard let object = try? container.viewContext.fetch(request).first,
              let data = object.value(forKey: "payload") as? Data
        else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(PersistedAppState.self, from: data)
    }
}
