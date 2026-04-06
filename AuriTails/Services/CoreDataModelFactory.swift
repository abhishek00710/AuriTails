import CoreData
import Foundation

enum CoreDataModelFactory {
    static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [
            metadataEntity(),
            behaviorSnapshotEntity(),
            weightEntryEntity(),
            vaccineEntity(),
            medicationEntity(),
            symptomEntity(),
            medicalEntryEntity(),
            foodPreferenceEntity(),
            routineEntity(),
            memoryEntity(),
        ]
        return model
    }

    static func makeLegacyManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "PersistedStateEntity"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let id = attribute(name: "id", type: .stringAttributeType, optional: false)
        let payload = attribute(name: "payload", type: .binaryDataAttributeType, optional: false, externalBinary: true)
        let updatedAt = attribute(name: "updatedAt", type: .dateAttributeType, optional: true)

        entity.properties = [id, payload, updatedAt]
        entity.uniquenessConstraints = [["id"]]
        model.entities = [entity]
        return model
    }

    private static func metadataEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.metadata.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let id = attribute(name: "id", type: .stringAttributeType, optional: false)
        let selectedTab = attribute(name: "selectedTab", type: .stringAttributeType, optional: false)
        let selectedDay = attribute(name: "selectedDay", type: .integer16AttributeType, optional: false)
        let ownerID = attribute(name: "ownerID", type: .UUIDAttributeType, optional: false)
        let ownerName = attribute(name: "ownerName", type: .stringAttributeType, optional: false)
        let ownerHeadline = attribute(name: "ownerHeadline", type: .stringAttributeType, optional: false)
        let ownerLocation = attribute(name: "ownerLocation", type: .stringAttributeType, optional: false)
        let ownerNote = attribute(name: "ownerNote", type: .stringAttributeType, optional: false)
        let petID = attribute(name: "petID", type: .UUIDAttributeType, optional: false)
        let petName = attribute(name: "petName", type: .stringAttributeType, optional: false)
        let petSpecies = attribute(name: "petSpecies", type: .stringAttributeType, optional: false)
        let petBreed = attribute(name: "petBreed", type: .stringAttributeType, optional: false)
        let petAgeDescription = attribute(name: "petAgeDescription", type: .stringAttributeType, optional: false)
        let petWeightDescription = attribute(name: "petWeightDescription", type: .stringAttributeType, optional: false)
        let petFavoriteTreat = attribute(name: "petFavoriteTreat", type: .stringAttributeType, optional: false)
        let petBondStatement = attribute(name: "petBondStatement", type: .stringAttributeType, optional: false)
        let petEnergySummary = attribute(name: "petEnergySummary", type: .stringAttributeType, optional: false)
        let ownerPhotoData = attribute(name: "ownerPhotoData", type: .binaryDataAttributeType, optional: true, externalBinary: true)
        let petPhotoData = attribute(name: "petPhotoData", type: .binaryDataAttributeType, optional: true, externalBinary: true)
        let bondPhotoData = attribute(name: "bondPhotoData", type: .binaryDataAttributeType, optional: true, externalBinary: true)
        let routinesNotificationsEnabled = attribute(name: "routinesNotificationsEnabled", type: .booleanAttributeType, optional: false)
        let vaccinesNotificationsEnabled = attribute(name: "vaccinesNotificationsEnabled", type: .booleanAttributeType, optional: false)
        let medicationsNotificationsEnabled = attribute(name: "medicationsNotificationsEnabled", type: .booleanAttributeType, optional: false)
        let memoriesNotificationsEnabled = attribute(name: "memoriesNotificationsEnabled", type: .booleanAttributeType, optional: false)
        let routineLeadMinutes = attribute(name: "routineLeadMinutes", type: .integer32AttributeType, optional: false)
        let vaccineLeadDays = attribute(name: "vaccineLeadDays", type: .integer32AttributeType, optional: false)
        let medicationLeadMinutes = attribute(name: "medicationLeadMinutes", type: .integer32AttributeType, optional: false)
        let memoryLeadDays = attribute(name: "memoryLeadDays", type: .integer32AttributeType, optional: false)
        let onboardingFocus = attribute(name: "onboardingFocus", type: .stringAttributeType, optional: false)
        let hasCompletedOnboarding = attribute(name: "hasCompletedOnboarding", type: .booleanAttributeType, optional: false)

        entity.properties = [
            id, selectedTab, selectedDay,
            ownerID, ownerName, ownerHeadline, ownerLocation, ownerNote,
            petID, petName, petSpecies, petBreed, petAgeDescription, petWeightDescription, petFavoriteTreat, petBondStatement, petEnergySummary,
            ownerPhotoData, petPhotoData, bondPhotoData,
            routinesNotificationsEnabled, vaccinesNotificationsEnabled, medicationsNotificationsEnabled, memoriesNotificationsEnabled,
            routineLeadMinutes, vaccineLeadDays, medicationLeadMinutes, memoryLeadDays,
            onboardingFocus, hasCompletedOnboarding,
        ]
        entity.uniquenessConstraints = [["id"]]
        entity.indexes = [index(named: "appMetadataIDIndex", property: id)]
        return entity
    }

    private static func behaviorSnapshotEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.behaviorSnapshot.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        let day = attribute(name: "day", type: .integer16AttributeType, optional: false)
        let energy = attribute(name: "energy", type: .doubleAttributeType, optional: false)
        let calmness = attribute(name: "calmness", type: .doubleAttributeType, optional: false)
        let appetite = attribute(name: "appetite", type: .doubleAttributeType, optional: false)
        let sleepHours = attribute(name: "sleepHours", type: .doubleAttributeType, optional: false)
        entity.properties = [day, energy, calmness, appetite, sleepHours]
        entity.uniquenessConstraints = [["day"]]
        entity.indexes = [index(named: "behaviorSnapshotDayIndex", property: day)]
        return entity
    }

    private static func vaccineEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.vaccine.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        let id = attribute(name: "id", type: .UUIDAttributeType, optional: false)
        entity.properties = [
            id,
            attribute(name: "title", type: .stringAttributeType, optional: false),
            attribute(name: "lastGiven", type: .dateAttributeType, optional: false),
            attribute(name: "nextDue", type: .dateAttributeType, optional: false),
            attribute(name: "status", type: .stringAttributeType, optional: false),
            attribute(name: "note", type: .stringAttributeType, optional: false),
            attribute(name: "certificateData", type: .binaryDataAttributeType, optional: true, externalBinary: true),
            attribute(name: "notificationsEnabled", type: .booleanAttributeType, optional: false),
            attribute(name: "sortIndex", type: .integer32AttributeType, optional: false),
        ]
        entity.uniquenessConstraints = [["id"]]
        entity.indexes = [index(named: "vaccineIDIndex", property: id)]
        return entity
    }

    private static func weightEntryEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.weightEntry.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        let id = attribute(name: "id", type: .UUIDAttributeType, optional: false)
        entity.properties = [
            id,
            attribute(name: "loggedAt", type: .dateAttributeType, optional: false),
            attribute(name: "kilogramsValue", type: .doubleAttributeType, optional: false),
            attribute(name: "unit", type: .stringAttributeType, optional: false),
            attribute(name: "note", type: .stringAttributeType, optional: false),
            attribute(name: "sortIndex", type: .integer32AttributeType, optional: false),
        ]
        entity.uniquenessConstraints = [["id"]]
        entity.indexes = [index(named: "weightEntryIDIndex", property: id)]
        return entity
    }

    private static func medicalEntryEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.medicalEntry.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        let id = attribute(name: "id", type: .UUIDAttributeType, optional: false)
        entity.properties = [
            id,
            attribute(name: "title", type: .stringAttributeType, optional: false),
            attribute(name: "date", type: .dateAttributeType, optional: false),
            attribute(name: "summary", type: .stringAttributeType, optional: false),
            attribute(name: "clinician", type: .stringAttributeType, optional: false),
            attribute(name: "tone", type: .stringAttributeType, optional: false),
            attribute(name: "sortIndex", type: .integer32AttributeType, optional: false),
        ]
        entity.uniquenessConstraints = [["id"]]
        entity.indexes = [index(named: "medicalEntryIDIndex", property: id)]
        return entity
    }

    private static func medicationEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.medication.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        let id = attribute(name: "id", type: .UUIDAttributeType, optional: false)
        entity.properties = [
            id,
            attribute(name: "title", type: .stringAttributeType, optional: false),
            attribute(name: "dosage", type: .stringAttributeType, optional: false),
            attribute(name: "scheduleNote", type: .stringAttributeType, optional: false),
            attribute(name: "purpose", type: .stringAttributeType, optional: false),
            attribute(name: "nextDose", type: .dateAttributeType, optional: false),
            attribute(name: "status", type: .stringAttributeType, optional: false),
            attribute(name: "tone", type: .stringAttributeType, optional: false),
            attribute(name: "notificationsEnabled", type: .booleanAttributeType, optional: false),
            attribute(name: "sortIndex", type: .integer32AttributeType, optional: false),
        ]
        entity.uniquenessConstraints = [["id"]]
        entity.indexes = [index(named: "medicationIDIndex", property: id)]
        return entity
    }

    private static func symptomEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.symptom.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        let id = attribute(name: "id", type: .UUIDAttributeType, optional: false)
        entity.properties = [
            id,
            attribute(name: "title", type: .stringAttributeType, optional: false),
            attribute(name: "detail", type: .stringAttributeType, optional: false),
            attribute(name: "observedAt", type: .dateAttributeType, optional: false),
            attribute(name: "severity", type: .stringAttributeType, optional: false),
            attribute(name: "systemImage", type: .stringAttributeType, optional: false),
            attribute(name: "tone", type: .stringAttributeType, optional: false),
            attribute(name: "sortIndex", type: .integer32AttributeType, optional: false),
        ]
        entity.uniquenessConstraints = [["id"]]
        entity.indexes = [index(named: "symptomIDIndex", property: id)]
        return entity
    }

    private static func foodPreferenceEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.foodPreference.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        let id = attribute(name: "id", type: .UUIDAttributeType, optional: false)
        entity.properties = [
            id,
            attribute(name: "title", type: .stringAttributeType, optional: false),
            attribute(name: "detail", type: .stringAttributeType, optional: false),
            attribute(name: "systemImage", type: .stringAttributeType, optional: false),
            attribute(name: "sortIndex", type: .integer32AttributeType, optional: false),
        ]
        entity.uniquenessConstraints = [["id"]]
        entity.indexes = [index(named: "foodPreferenceIDIndex", property: id)]
        return entity
    }

    private static func routineEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.routine.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        let id = attribute(name: "id", type: .UUIDAttributeType, optional: false)
        entity.properties = [
            id,
            attribute(name: "title", type: .stringAttributeType, optional: false),
            attribute(name: "subtitle", type: .stringAttributeType, optional: false),
            attribute(name: "day", type: .integer16AttributeType, optional: false),
            attribute(name: "hour", type: .integer16AttributeType, optional: false),
            attribute(name: "minute", type: .integer16AttributeType, optional: false),
            attribute(name: "durationMinutes", type: .integer32AttributeType, optional: false),
            attribute(name: "systemImage", type: .stringAttributeType, optional: false),
            attribute(name: "category", type: .stringAttributeType, optional: false),
            attribute(name: "tone", type: .stringAttributeType, optional: false),
            attribute(name: "isCompleted", type: .booleanAttributeType, optional: false),
            attribute(name: "notificationsEnabled", type: .booleanAttributeType, optional: false),
            attribute(name: "sortIndex", type: .integer32AttributeType, optional: false),
        ]
        entity.uniquenessConstraints = [["id"]]
        entity.indexes = [index(named: "routineIDIndex", property: id)]
        return entity
    }

    private static func memoryEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = AppStateStore.Entity.memory.name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        let id = attribute(name: "id", type: .UUIDAttributeType, optional: false)
        entity.properties = [
            id,
            attribute(name: "title", type: .stringAttributeType, optional: false),
            attribute(name: "date", type: .dateAttributeType, optional: false),
            attribute(name: "caption", type: .stringAttributeType, optional: false),
            attribute(name: "detail", type: .stringAttributeType, optional: false),
            attribute(name: "photoData", type: .binaryDataAttributeType, optional: true, externalBinary: true),
            attribute(name: "systemImage", type: .stringAttributeType, optional: false),
            attribute(name: "tone", type: .stringAttributeType, optional: false),
            attribute(name: "isAnnualCelebration", type: .booleanAttributeType, optional: false),
            attribute(name: "notificationsEnabled", type: .booleanAttributeType, optional: false),
            attribute(name: "sortIndex", type: .integer32AttributeType, optional: false),
        ]
        entity.uniquenessConstraints = [["id"]]
        entity.indexes = [index(named: "memoryIDIndex", property: id)]
        return entity
    }

    private static func attribute(
        name: String,
        type: NSAttributeType,
        optional: Bool,
        externalBinary: Bool = false
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        attribute.allowsExternalBinaryDataStorage = externalBinary
        return attribute
    }

    private static func index(named name: String, property: NSPropertyDescription) -> NSFetchIndexDescription {
        let element = NSFetchIndexElementDescription(property: property, collationType: .binary)
        return NSFetchIndexDescription(name: name, elements: [element])
    }
}
