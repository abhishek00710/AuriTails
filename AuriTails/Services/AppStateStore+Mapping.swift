import CoreData
import Foundation

extension AppStateStore {
    private static let careCircleEncoder = JSONEncoder()
    private static let careCircleDecoder = JSONDecoder()

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
        let pets = decode([PetProfile].self, from: metadata.value(forKey: "petsData") as? Data) ?? [
            PetProfile(
                id: metadata.uuid("petID"),
                name: metadata.string("petName"),
                species: metadata.string("petSpecies"),
                breed: metadata.string("petBreed"),
                ageDescription: metadata.string("petAgeDescription"),
                weightDescription: metadata.string("petWeightDescription"),
                favoriteTreat: metadata.string("petFavoriteTreat"),
                bondStatement: metadata.string("petBondStatement"),
                energySummary: metadata.string("petEnergySummary"),
                photoData: metadata.value(forKey: "petPhotoData") as? Data,
                bondPhotoData: metadata.value(forKey: "bondPhotoData") as? Data
            )
        ]
        let selectedPetID = (metadata.value(forKey: "selectedPetID") as? UUID) ?? pets.first?.id
        let notificationPreferences = NotificationPreferences(
            routinesEnabled: metadata.value(forKey: "routinesNotificationsEnabled") as? Bool ?? true,
            vaccinesEnabled: metadata.value(forKey: "vaccinesNotificationsEnabled") as? Bool ?? true,
            medicationsEnabled: metadata.value(forKey: "medicationsNotificationsEnabled") as? Bool ?? true,
            memoriesEnabled: metadata.value(forKey: "memoriesNotificationsEnabled") as? Bool ?? true,
            routineLeadMinutes: Int(metadata.int32("routineLeadMinutes") == 0 ? 30 : metadata.int32("routineLeadMinutes")),
            vaccineLeadDays: Int(metadata.int32("vaccineLeadDays") == 0 ? 1 : metadata.int32("vaccineLeadDays")),
            medicationLeadMinutes: Int(metadata.int32("medicationLeadMinutes") == 0 ? 30 : metadata.int32("medicationLeadMinutes")),
            memoryLeadDays: Int(metadata.int32("memoryLeadDays") == 0 ? 1 : metadata.int32("memoryLeadDays"))
        )
        let careCircleMembers = decode([CareCircleMember].self, from: metadata.value(forKey: "careCircleMembersData") as? Data) ?? []
        let careActivityEvents = decode([CareActivityEvent].self, from: metadata.value(forKey: "careActivityEventsData") as? Data) ?? []

        let behaviorSnapshots: [BehaviorSnapshot] = fetchSorted(Entity.behaviorSnapshot.name, by: "day", ascending: true, in: context).compactMap { object in
            guard let day = Weekday(rawValue: Int(object.int16("day"))) else { return nil }
            return BehaviorSnapshot(
                id: object.uuid("id"),
                petID: object.value(forKey: "petID") as? UUID,
                day: day,
                energy: object.double("energy"),
                calmness: object.double("calmness"),
                appetite: object.double("appetite"),
                sleepHours: object.double("sleepHours")
            )
        }

        let weightEntries: [WeightEntry] = fetchSorted(Entity.weightEntry.name, by: "loggedAt", ascending: true, in: context).compactMap { object in
            guard let loggedAt = object.value(forKey: "loggedAt") as? Date,
                  let unit = WeightUnit(rawValue: object.string("unit"))
            else { return nil }
            return WeightEntry(
                id: object.uuid("id"),
                petID: object.value(forKey: "petID") as? UUID,
                loggedAt: loggedAt,
                value: unit.fromKilograms(object.double("kilogramsValue")),
                unit: unit,
                note: object.string("note")
            )
        }

        let vaccinations: [VaccineRecord] = fetchSorted(Entity.vaccine.name, by: "sortIndex", ascending: true, in: context).compactMap { object in
            guard let status = VaccineStatus(rawValue: object.string("status")),
                  let lastGiven = object.value(forKey: "lastGiven") as? Date,
                  let nextDue = object.value(forKey: "nextDue") as? Date
            else { return nil }
            return VaccineRecord(
                id: object.uuid("id"),
                petID: object.value(forKey: "petID") as? UUID,
                title: object.string("title"),
                lastGiven: lastGiven,
                nextDue: nextDue,
                status: status,
                note: object.string("note"),
                certificateData: object.value(forKey: "certificateData") as? Data,
                notificationsEnabled: object.value(forKey: "notificationsEnabled") as? Bool ?? true
            )
        }

        let medications: [MedicationRecord] = fetchSorted(Entity.medication.name, by: "sortIndex", ascending: true, in: context).compactMap { object in
            guard let status = MedicationStatus(rawValue: object.string("status")),
                  let tone = PaletteTone(rawValue: object.string("tone")),
                  let nextDose = object.value(forKey: "nextDose") as? Date
            else { return nil }
            return MedicationRecord(
                id: object.uuid("id"),
                petID: object.value(forKey: "petID") as? UUID,
                title: object.string("title"),
                dosage: object.string("dosage"),
                scheduleNote: object.string("scheduleNote"),
                purpose: object.string("purpose"),
                nextDose: nextDose,
                status: status,
                tone: tone,
                notificationsEnabled: object.value(forKey: "notificationsEnabled") as? Bool ?? true
            )
        }

        let symptoms: [SymptomEntry] = fetchSorted(Entity.symptom.name, by: "sortIndex", ascending: true, in: context).compactMap { object in
            guard let severity = SymptomSeverity(rawValue: object.string("severity")),
                  let tone = PaletteTone(rawValue: object.string("tone")),
                  let observedAt = object.value(forKey: "observedAt") as? Date
            else { return nil }
            return SymptomEntry(
                id: object.uuid("id"),
                petID: object.value(forKey: "petID") as? UUID,
                title: object.string("title"),
                detail: object.string("detail"),
                observedAt: observedAt,
                severity: severity,
                systemImage: object.string("systemImage"),
                tone: tone
            )
        }

        let medicalHistory: [MedicalEntry] = fetchSorted(Entity.medicalEntry.name, by: "sortIndex", ascending: true, in: context).compactMap { object in
            guard let tone = PaletteTone(rawValue: object.string("tone")),
                  let date = object.value(forKey: "date") as? Date
            else { return nil }
            return MedicalEntry(
                id: object.uuid("id"),
                petID: object.value(forKey: "petID") as? UUID,
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
                petID: object.value(forKey: "petID") as? UUID,
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
                petID: object.value(forKey: "petID") as? UUID,
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
                petID: object.value(forKey: "petID") as? UUID,
                title: object.string("title"),
                date: date,
                caption: object.string("caption"),
                detail: object.string("detail"),
                photoData: object.value(forKey: "photoData") as? Data,
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
            pets: pets,
            selectedPetID: selectedPetID,
            notificationPreferences: notificationPreferences,
            ownerPhotoData: metadata.value(forKey: "ownerPhotoData") as? Data,
            behaviorSnapshots: behaviorSnapshots,
            weightEntries: weightEntries,
            vaccinations: vaccinations,
            medications: medications,
            symptoms: symptoms,
            medicalHistory: medicalHistory,
            foodPreferences: foodPreferences,
            routines: routines,
            memories: memories,
            careCircleMembers: careCircleMembers,
            careActivityEvents: careActivityEvents,
            onboardingFocus: OnboardingFocus(rawValue: metadata.string("onboardingFocus")) ?? .dashboard,
            hasCompletedOnboarding: metadata.bool("hasCompletedOnboarding"),
            appReviewState: AppReviewState()
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
        object.setValue(state.selectedPet.id, forKey: "petID")
        object.setValue(state.selectedPet.name, forKey: "petName")
        object.setValue(state.selectedPet.species, forKey: "petSpecies")
        object.setValue(state.selectedPet.breed, forKey: "petBreed")
        object.setValue(state.selectedPet.ageDescription, forKey: "petAgeDescription")
        object.setValue(state.selectedPet.weightDescription, forKey: "petWeightDescription")
        object.setValue(state.selectedPet.favoriteTreat, forKey: "petFavoriteTreat")
        object.setValue(state.selectedPet.bondStatement, forKey: "petBondStatement")
        object.setValue(state.selectedPet.energySummary, forKey: "petEnergySummary")
        object.setValue(state.ownerPhotoData, forKey: "ownerPhotoData")
        object.setValue(state.selectedPet.photoData, forKey: "petPhotoData")
        object.setValue(state.selectedPet.bondPhotoData, forKey: "bondPhotoData")
        object.setValue(encode(state.pets), forKey: "petsData")
        object.setValue(state.selectedPetID, forKey: "selectedPetID")
        object.setValue(encode(state.careCircleMembers), forKey: "careCircleMembersData")
        object.setValue(encode(state.careActivityEvents), forKey: "careActivityEventsData")
        object.setValue(state.notificationPreferences.routinesEnabled, forKey: "routinesNotificationsEnabled")
        object.setValue(state.notificationPreferences.vaccinesEnabled, forKey: "vaccinesNotificationsEnabled")
        object.setValue(state.notificationPreferences.medicationsEnabled, forKey: "medicationsNotificationsEnabled")
        object.setValue(state.notificationPreferences.memoriesEnabled, forKey: "memoriesNotificationsEnabled")
        object.setValue(Int32(state.notificationPreferences.routineLeadMinutes), forKey: "routineLeadMinutes")
        object.setValue(Int32(state.notificationPreferences.vaccineLeadDays), forKey: "vaccineLeadDays")
        object.setValue(Int32(state.notificationPreferences.medicationLeadMinutes), forKey: "medicationLeadMinutes")
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

    private func encode<T: Encodable>(_ value: T) -> Data? {
        try? Self.careCircleEncoder.encode(value)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data?) -> T? {
        guard let data else { return nil }
        return try? Self.careCircleDecoder.decode(type, from: data)
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
