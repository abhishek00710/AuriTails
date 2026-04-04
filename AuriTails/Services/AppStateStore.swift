import CoreData
import Foundation

final class AppStateStore {
    fileprivate let container: NSPersistentContainer
    fileprivate let inMemory: Bool

    init(inMemory: Bool = false) {
        self.inMemory = inMemory
        container = PersistenceController.makeContainer(inMemory: inMemory)
    }

    func load() -> PersistedAppState? {
        let context = container.viewContext

        if let state = loadNormalizedState(from: context) {
            return state
        }

        guard !inMemory, let legacyState = loadLegacyPayloadState() else {
            return nil
        }

        save(legacyState)
        return legacyState
    }

    func save(_ state: PersistedAppState) {
        let context = container.viewContext

        context.performAndWait {
            upsertMetadata(state, in: context)
            replaceAll(entityName: Entity.behaviorSnapshot.name, in: context) { insert in
                for snapshot in state.behaviorSnapshots {
                    let object = insert()
                    object.setValue(Int16(snapshot.day.rawValue), forKey: "day")
                    object.setValue(snapshot.energy, forKey: "energy")
                    object.setValue(snapshot.calmness, forKey: "calmness")
                    object.setValue(snapshot.appetite, forKey: "appetite")
                    object.setValue(snapshot.sleepHours, forKey: "sleepHours")
                }
            }
            replaceAll(entityName: Entity.vaccine.name, in: context) { insert in
                for (index, vaccine) in state.vaccinations.enumerated() {
                    let object = insert()
                    object.setValue(vaccine.id, forKey: "id")
                    object.setValue(vaccine.title, forKey: "title")
                    object.setValue(vaccine.lastGiven, forKey: "lastGiven")
                    object.setValue(vaccine.nextDue, forKey: "nextDue")
                    object.setValue(vaccine.status.rawValue, forKey: "status")
                    object.setValue(vaccine.note, forKey: "note")
                    object.setValue(vaccine.notificationsEnabled, forKey: "notificationsEnabled")
                    object.setValue(Int32(index), forKey: "sortIndex")
                }
            }
            replaceAll(entityName: Entity.medicalEntry.name, in: context) { insert in
                for (index, entry) in state.medicalHistory.enumerated() {
                    let object = insert()
                    object.setValue(entry.id, forKey: "id")
                    object.setValue(entry.title, forKey: "title")
                    object.setValue(entry.date, forKey: "date")
                    object.setValue(entry.summary, forKey: "summary")
                    object.setValue(entry.clinician, forKey: "clinician")
                    object.setValue(entry.tone.rawValue, forKey: "tone")
                    object.setValue(Int32(index), forKey: "sortIndex")
                }
            }
            replaceAll(entityName: Entity.foodPreference.name, in: context) { insert in
                for (index, preference) in state.foodPreferences.enumerated() {
                    let object = insert()
                    object.setValue(preference.id, forKey: "id")
                    object.setValue(preference.title, forKey: "title")
                    object.setValue(preference.detail, forKey: "detail")
                    object.setValue(preference.systemImage, forKey: "systemImage")
                    object.setValue(Int32(index), forKey: "sortIndex")
                }
            }
            replaceAll(entityName: Entity.routine.name, in: context) { insert in
                for (index, routine) in state.routines.enumerated() {
                    let object = insert()
                    object.setValue(routine.id, forKey: "id")
                    object.setValue(routine.title, forKey: "title")
                    object.setValue(routine.subtitle, forKey: "subtitle")
                    object.setValue(Int16(routine.day.rawValue), forKey: "day")
                    object.setValue(Int16(routine.time.hour), forKey: "hour")
                    object.setValue(Int16(routine.time.minute), forKey: "minute")
                    object.setValue(Int32(routine.durationMinutes), forKey: "durationMinutes")
                    object.setValue(routine.systemImage, forKey: "systemImage")
                    object.setValue(routine.category.rawValue, forKey: "category")
                    object.setValue(routine.tone.rawValue, forKey: "tone")
                    object.setValue(routine.isCompleted, forKey: "isCompleted")
                    object.setValue(routine.notificationsEnabled, forKey: "notificationsEnabled")
                    object.setValue(Int32(index), forKey: "sortIndex")
                }
            }
            replaceAll(entityName: Entity.memory.name, in: context) { insert in
                for (index, memory) in state.memories.enumerated() {
                    let object = insert()
                    object.setValue(memory.id, forKey: "id")
                    object.setValue(memory.title, forKey: "title")
                    object.setValue(memory.date, forKey: "date")
                    object.setValue(memory.caption, forKey: "caption")
                    object.setValue(memory.detail, forKey: "detail")
                    object.setValue(memory.photoData, forKey: "photoData")
                    object.setValue(memory.systemImage, forKey: "systemImage")
                    object.setValue(memory.tone.rawValue, forKey: "tone")
                    object.setValue(memory.isAnnualCelebration, forKey: "isAnnualCelebration")
                    object.setValue(memory.notificationsEnabled, forKey: "notificationsEnabled")
                    object.setValue(Int32(index), forKey: "sortIndex")
                }
            }

            if context.hasChanges {
                try? context.save()
            }
        }
    }
}

extension AppStateStore {
    enum Entity: CaseIterable {
        case metadata
        case behaviorSnapshot
        case vaccine
        case medicalEntry
        case foodPreference
        case routine
        case memory

        var name: String {
            switch self {
            case .metadata: "AppMetadataEntity"
            case .behaviorSnapshot: "BehaviorSnapshotEntity"
            case .vaccine: "VaccineRecordEntity"
            case .medicalEntry: "MedicalEntryEntity"
            case .foodPreference: "FoodPreferenceEntity"
            case .routine: "RoutineItemEntity"
            case .memory: "MemoryMomentEntity"
            }
        }
    }
}
