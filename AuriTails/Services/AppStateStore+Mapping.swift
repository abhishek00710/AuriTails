import CoreData
import Foundation

extension AppStateStore {
    func loadNormalizedState(from context: NSManagedObjectContext) -> PersistedAppState? {
        let metadataRequest = NSFetchRequest<NSManagedObject>(entityName: Entity.metadata.name)
        metadataRequest.fetchLimit = 1

        guard let metadata = try? context.fetch(metadataRequest).first else {
            return nil
        }

        let selectedTab = RootTab(rawValue: metadata.string("selectedTab")) ?? .dashboard
        let selectedDay = Weekday(rawValue: Int(metadata.int16("selectedDay"))) ?? .current
        let owner = OwnerProfile(
            id: metadata.uuid("ownerID"),
            name: metadata.string("ownerName"),
            headline: metadata.string("ownerHeadline"),
            location: metadata.string("ownerLocation"),
            note: metadata.string("ownerNote")
        )
        let pet = PetProfile(
            id: metadata.uuid("petID"),
            name: metadata.string("petName"),
            species: metadata.string("petSpecies"),
            breed: metadata.string("petBreed"),
            ageDescription: metadata.string("petAgeDescription"),
            weightDescription: metadata.string("petWeightDescription"),
            favoriteTreat: metadata.string("petFavoriteTreat"),
            bondStatement: metadata.string("petBondStatement"),
            energySummary: metadata.string("petEnergySummary")
        )
        let notificationPreferences = NotificationPreferences(
            routinesEnabled: metadata.value(forKey: "routinesNotificationsEnabled") as? Bool ?? true,
            vaccinesEnabled: metadata.value(forKey: "vaccinesNotificationsEnabled") as? Bool ?? true,
            memoriesEnabled: metadata.value(forKey: "memoriesNotificationsEnabled") as? Bool ?? true,
            routineLeadMinutes: Int(metadata.int32("routineLeadMinutes") == 0 ? 30 : metadata.int32("routineLeadMinutes")),
            vaccineLeadDays: Int(metadata.int32("vaccineLeadDays") == 0 ? 1 : metadata.int32("vaccineLeadDays")),
            memoryLeadDays: Int(metadata.int32("memoryLeadDays") == 0 ? 1 : metadata.int32("memoryLeadDays"))
        )

        let behaviorSnapshots: [BehaviorSnapshot] = fetchSorted(Entity.behaviorSnapshot.name, by: "day", ascending: true, in: context).compactMap { object in
            guard let day = Weekday(rawValue: Int(object.int16("day"))) else { return nil }
            return BehaviorSnapshot(
                day: day,
                energy: object.double("energy"),
                calmness: object.double("calmness"),
                appetite: object.double("appetite"),
                sleepHours: object.double("sleepHours")
            )
        }

        let vaccinations: [VaccineRecord] = fetchSorted(Entity.vaccine.name, by: "sortIndex", ascending: true, in: context).compactMap { object in
            guard let status = VaccineStatus(rawValue: object.string("status")),
                  let lastGiven = object.value(forKey: "lastGiven") as? Date,
                  let nextDue = object.value(forKey: "nextDue") as? Date
            else { return nil }
            return VaccineRecord(
                id: object.uuid("id"),
                title: object.string("title"),
                lastGiven: lastGiven,
                nextDue: nextDue,
                status: status,
                note: object.string("note"),
                notificationsEnabled: object.value(forKey: "notificationsEnabled") as? Bool ?? true
            )
        }

        let medicalHistory: [MedicalEntry] = fetchSorted(Entity.medicalEntry.name, by: "sortIndex", ascending: true, in: context).compactMap { object in
            guard let tone = PaletteTone(rawValue: object.string("tone")),
                  let date = object.value(forKey: "date") as? Date
            else { return nil }
            return MedicalEntry(
                id: object.uuid("id"),
                title: object.string("title"),
                date: date,
                summary: object.string("summary"),
                clinician: object.string("clinician"),
                tone: tone
            )
        }

        let foodPreferences: [FoodPreference] = fetchSorted(Entity.foodPreference.name, by: "sortIndex", ascending: true, in: context).map { object in
            FoodPreference(
                id: object.uuid("id"),
                title: object.string("title"),
                detail: object.string("detail"),
                systemImage: object.string("systemImage")
            )
        }

        let routines: [RoutineItem] = fetchSorted(Entity.routine.name, by: "sortIndex", ascending: true, in: context).compactMap { object in
            guard let day = Weekday(rawValue: Int(object.int16("day"))),
                  let category = RoutineCategory(rawValue: object.string("category")),
                  let tone = PaletteTone(rawValue: object.string("tone"))
            else { return nil }
            return RoutineItem(
                id: object.uuid("id"),
                title: object.string("title"),
                subtitle: object.string("subtitle"),
                day: day,
                time: ClockTime(hour: Int(object.int16("hour")), minute: Int(object.int16("minute"))),
                durationMinutes: Int(object.int32("durationMinutes")),
                systemImage: object.string("systemImage"),
                category: category,
                tone: tone,
                isCompleted: object.bool("isCompleted"),
                notificationsEnabled: object.value(forKey: "notificationsEnabled") as? Bool ?? true
            )
        }

        let memories: [MemoryMoment] = fetchSorted(Entity.memory.name, by: "sortIndex", ascending: true, in: context).compactMap { object in
            guard let tone = PaletteTone(rawValue: object.string("tone")),
                  let date = object.value(forKey: "date") as? Date
            else { return nil }
            return MemoryMoment(
                id: object.uuid("id"),
                title: object.string("title"),
                date: date,
                caption: object.string("caption"),
                detail: object.string("detail"),
                systemImage: object.string("systemImage"),
                tone: tone,
                isAnnualCelebration: object.bool("isAnnualCelebration"),
                notificationsEnabled: object.value(forKey: "notificationsEnabled") as? Bool ?? true
            )
        }

        return PersistedAppState(
            selectedTab: selectedTab,
            selectedDay: selectedDay,
            owner: owner,
            pet: pet,
            notificationPreferences: notificationPreferences,
            ownerPhotoData: metadata.value(forKey: "ownerPhotoData") as? Data,
            petPhotoData: metadata.value(forKey: "petPhotoData") as? Data,
            bondPhotoData: metadata.value(forKey: "bondPhotoData") as? Data,
            behaviorSnapshots: behaviorSnapshots,
            vaccinations: vaccinations,
            medicalHistory: medicalHistory,
            foodPreferences: foodPreferences,
            routines: routines,
            memories: memories,
            onboardingFocus: OnboardingFocus(rawValue: metadata.string("onboardingFocus")) ?? .dashboard,
            hasCompletedOnboarding: metadata.bool("hasCompletedOnboarding")
        )
    }

    func upsertMetadata(_ state: PersistedAppState, in context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSManagedObject>(entityName: Entity.metadata.name)
        request.fetchLimit = 1
        let object = (try? context.fetch(request).first) ?? NSEntityDescription.insertNewObject(forEntityName: Entity.metadata.name, into: context)

        object.setValue("primary", forKey: "id")
        object.setValue(state.selectedTab.rawValue, forKey: "selectedTab")
        object.setValue(Int16(state.selectedDay.rawValue), forKey: "selectedDay")
        object.setValue(state.owner.id, forKey: "ownerID")
        object.setValue(state.owner.name, forKey: "ownerName")
        object.setValue(state.owner.headline, forKey: "ownerHeadline")
        object.setValue(state.owner.location, forKey: "ownerLocation")
        object.setValue(state.owner.note, forKey: "ownerNote")
        object.setValue(state.pet.id, forKey: "petID")
        object.setValue(state.pet.name, forKey: "petName")
        object.setValue(state.pet.species, forKey: "petSpecies")
        object.setValue(state.pet.breed, forKey: "petBreed")
        object.setValue(state.pet.ageDescription, forKey: "petAgeDescription")
        object.setValue(state.pet.weightDescription, forKey: "petWeightDescription")
        object.setValue(state.pet.favoriteTreat, forKey: "petFavoriteTreat")
        object.setValue(state.pet.bondStatement, forKey: "petBondStatement")
        object.setValue(state.pet.energySummary, forKey: "petEnergySummary")
        object.setValue(state.ownerPhotoData, forKey: "ownerPhotoData")
        object.setValue(state.petPhotoData, forKey: "petPhotoData")
        object.setValue(state.bondPhotoData, forKey: "bondPhotoData")
        object.setValue(state.notificationPreferences.routinesEnabled, forKey: "routinesNotificationsEnabled")
        object.setValue(state.notificationPreferences.vaccinesEnabled, forKey: "vaccinesNotificationsEnabled")
        object.setValue(state.notificationPreferences.memoriesEnabled, forKey: "memoriesNotificationsEnabled")
        object.setValue(Int32(state.notificationPreferences.routineLeadMinutes), forKey: "routineLeadMinutes")
        object.setValue(Int32(state.notificationPreferences.vaccineLeadDays), forKey: "vaccineLeadDays")
        object.setValue(Int32(state.notificationPreferences.memoryLeadDays), forKey: "memoryLeadDays")
        object.setValue(state.onboardingFocus.rawValue, forKey: "onboardingFocus")
        object.setValue(state.hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
    }

    func replaceAll(entityName: String, in context: NSManagedObjectContext, populate: (() -> NSManagedObject) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? context.execute(delete)
        populate {
            NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        }
    }

    func fetchSorted(_ entityName: String, by key: String, ascending: Bool, in context: NSManagedObjectContext) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        return (try? context.fetch(request)) ?? []
    }
}

private extension NSManagedObject {
    func string(_ key: String) -> String {
        value(forKey: key) as? String ?? ""
    }

    func uuid(_ key: String) -> UUID {
        value(forKey: key) as? UUID ?? UUID()
    }

    func int16(_ key: String) -> Int16 {
        value(forKey: key) as? Int16 ?? 0
    }

    func int32(_ key: String) -> Int32 {
        value(forKey: key) as? Int32 ?? 0
    }

    func double(_ key: String) -> Double {
        value(forKey: key) as? Double ?? 0
    }

    func bool(_ key: String) -> Bool {
        value(forKey: key) as? Bool ?? false
    }
}
