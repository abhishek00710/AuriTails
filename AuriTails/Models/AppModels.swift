import Foundation

enum RootTab: String, CaseIterable, Identifiable, Codable {
    case dashboard
    case wellness
    case routines
    case memories

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: L10n.tr("Home", default: "Home")
        case .wellness: L10n.tr("Wellness", default: "Wellness")
        case .routines: L10n.tr("Routines", default: "Routines")
        case .memories: L10n.tr("Memories", default: "Memories")
        }
    }

    var symbolName: String {
        switch self {
        case .dashboard: "sparkles.tv"
        case .wellness: "cross.case.fill"
        case .routines: "calendar.badge.clock"
        case .memories: "film.stack.fill"
        }
    }

    func headerTitle(for petName: String) -> String {
        let resolvedPetName = petName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? L10n.tr("your pet", default: "your pet")
        : petName
        switch self {
        case .dashboard:
            return L10n.format("Life with %@", default: "Life with %@", resolvedPetName)
        case .wellness:
            return L10n.tr("Wellness Passport", default: "Wellness Passport")
        case .routines:
            return L10n.tr("Ritual Planner", default: "Ritual Planner")
        case .memories:
            return L10n.tr("Memory Studio", default: "Memory Studio")
        }
    }

    func headerSubtitle(ownerName: String, petName: String) -> String {
        let resolvedOwnerName = ownerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? L10n.tr("you", default: "you")
        : ownerName
        let resolvedPetName = petName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? L10n.tr("your pet", default: "your pet")
        : petName
        switch self {
        case .dashboard:
            return L10n.format(
                "A calmer, more beautiful rhythm for %@ and %@.",
                default: "A calmer, more beautiful rhythm for %@ and %@.",
                resolvedOwnerName,
                resolvedPetName
            )
        case .wellness:
            return L10n.tr("Vaccines, notes, food rituals, and the tiny details that matter.", default: "Vaccines, notes, food rituals, and the tiny details that matter.")
        case .routines:
            return L10n.tr("Shape a week of walks, care, enrichment, and flexible re-schedules.", default: "Shape a week of walks, care, enrichment, and flexible re-schedules.")
        case .memories:
            return L10n.tr("Keep birthdays, gotcha days, and golden-hour moments in one place.", default: "Keep birthdays, gotcha days, and golden-hour moments in one place.")
        }
    }
}

enum AppSheet: Identifiable {
    case ai
    case profile
    case notificationSettings
    case behaviorCheckInEditor(Weekday?)
    case medicationEditor(UUID?)
    case symptomEditor(UUID?)
    case routineEditor(UUID?)
    case memoryEditor(UUID?)
    case vaccineEditor(UUID?)
    case medicalEntryEditor(UUID?)
    case foodPreferenceEditor(UUID?)

    var id: String {
        switch self {
        case .ai:
            return "ai"
        case .profile:
            return "profile"
        case .notificationSettings:
            return "notification-settings"
        case let .behaviorCheckInEditor(day):
            return "behavior-\(day?.rawValue ?? 0)"
        case let .medicationEditor(id):
            return "medication-\(id?.uuidString ?? "new")"
        case let .symptomEditor(id):
            return "symptom-\(id?.uuidString ?? "new")"
        case let .routineEditor(id):
            return "routine-\(id?.uuidString ?? "new")"
        case let .memoryEditor(id):
            return "memory-\(id?.uuidString ?? "new")"
        case let .vaccineEditor(id):
            return "vaccine-\(id?.uuidString ?? "new")"
        case let .medicalEntryEditor(id):
            return "medical-\(id?.uuidString ?? "new")"
        case let .foodPreferenceEditor(id):
            return "food-\(id?.uuidString ?? "new")"
        }
    }
}

struct NotificationPreferences: Codable {
    var routinesEnabled: Bool = true
    var vaccinesEnabled: Bool = true
    var medicationsEnabled: Bool = true
    var memoriesEnabled: Bool = true
    var routineLeadMinutes: Int = 30
    var vaccineLeadDays: Int = 1
    var medicationLeadMinutes: Int = 30
    var memoryLeadDays: Int = 1

    init() {}

    init(
        routinesEnabled: Bool = true,
        vaccinesEnabled: Bool = true,
        medicationsEnabled: Bool = true,
        memoriesEnabled: Bool = true,
        routineLeadMinutes: Int = 30,
        vaccineLeadDays: Int = 1,
        medicationLeadMinutes: Int = 30,
        memoryLeadDays: Int = 1
    ) {
        self.routinesEnabled = routinesEnabled
        self.vaccinesEnabled = vaccinesEnabled
        self.medicationsEnabled = medicationsEnabled
        self.memoriesEnabled = memoriesEnabled
        self.routineLeadMinutes = routineLeadMinutes
        self.vaccineLeadDays = vaccineLeadDays
        self.medicationLeadMinutes = medicationLeadMinutes
        self.memoryLeadDays = memoryLeadDays
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routinesEnabled = try container.decodeIfPresent(Bool.self, forKey: .routinesEnabled) ?? true
        vaccinesEnabled = try container.decodeIfPresent(Bool.self, forKey: .vaccinesEnabled) ?? true
        medicationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .medicationsEnabled) ?? true
        memoriesEnabled = try container.decodeIfPresent(Bool.self, forKey: .memoriesEnabled) ?? true
        routineLeadMinutes = try container.decodeIfPresent(Int.self, forKey: .routineLeadMinutes) ?? 30
        vaccineLeadDays = try container.decodeIfPresent(Int.self, forKey: .vaccineLeadDays) ?? 1
        medicationLeadMinutes = try container.decodeIfPresent(Int.self, forKey: .medicationLeadMinutes) ?? 30
        memoryLeadDays = try container.decodeIfPresent(Int.self, forKey: .memoryLeadDays) ?? 1
    }
}

enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7

    var id: Int { rawValue }

    var shortTitle: String {
        switch self {
        case .monday: L10n.tr("Mon", default: "Mon")
        case .tuesday: L10n.tr("Tue", default: "Tue")
        case .wednesday: L10n.tr("Wed", default: "Wed")
        case .thursday: L10n.tr("Thu", default: "Thu")
        case .friday: L10n.tr("Fri", default: "Fri")
        case .saturday: L10n.tr("Sat", default: "Sat")
        case .sunday: L10n.tr("Sun", default: "Sun")
        }
    }

    var title: String {
        switch self {
        case .monday: L10n.tr("Monday", default: "Monday")
        case .tuesday: L10n.tr("Tuesday", default: "Tuesday")
        case .wednesday: L10n.tr("Wednesday", default: "Wednesday")
        case .thursday: L10n.tr("Thursday", default: "Thursday")
        case .friday: L10n.tr("Friday", default: "Friday")
        case .saturday: L10n.tr("Saturday", default: "Saturday")
        case .sunday: L10n.tr("Sunday", default: "Sunday")
        }
    }

    static var current: Weekday {
        from(date: .now)
    }

    static func from(date: Date) -> Weekday {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        default:
            return .saturday
        }
    }
}

struct ClockTime: Hashable, Comparable, Codable {
    var hour: Int
    var minute: Int

    var label: String {
        Self.formatter.string(from: date)
    }

    func shifted(by minutes: Int) -> ClockTime {
        let total = ((hour * 60 + minute + minutes) % 1_440 + 1_440) % 1_440
        return ClockTime(hour: total / 60, minute: total % 60)
    }

    static func < (lhs: ClockTime, rhs: ClockTime) -> Bool {
        lhs.hour == rhs.hour ? lhs.minute < rhs.minute : lhs.hour < rhs.hour
    }

    private var date: Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.hour = hour
        components.minute = minute
        return components.date ?? .now
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}

enum PaletteTone: String, CaseIterable, Identifiable, Codable {
    case apricot
    case meadow
    case lagoon
    case twilight

    var id: String { rawValue }

    var title: String {
        L10n.tr(rawValue.capitalized, default: rawValue.capitalized)
    }
}

enum RoutineCategory: String, CaseIterable, Identifiable, Codable {
    case walk
    case meal
    case training
    case care
    case play

    var id: String { rawValue }

    var title: String {
        L10n.tr(rawValue.capitalized, default: rawValue.capitalized)
    }

    var symbolName: String {
        switch self {
        case .walk: "figure.walk"
        case .meal: "fork.knife"
        case .training: "brain.head.profile"
        case .care: "heart.text.square.fill"
        case .play: "tennisball.fill"
        }
    }
}

enum InsightPriority: String, Codable {
    case steady
    case watch
    case celebrate
}

enum VaccineStatus: String, CaseIterable, Identifiable, Codable {
    case covered
    case onTrack
    case watch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .covered: L10n.tr("Covered", default: "Covered")
        case .onTrack: L10n.tr("On track", default: "On track")
        case .watch: L10n.tr("Watch", default: "Watch")
        }
    }
}

enum MedicationStatus: String, CaseIterable, Identifiable, Codable {
    case active
    case watch
    case paused

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active: L10n.tr("Active", default: "Active")
        case .watch: L10n.tr("Watch", default: "Watch")
        case .paused: L10n.tr("Paused", default: "Paused")
        }
    }
}

enum SymptomSeverity: String, CaseIterable, Identifiable, Codable {
    case mild
    case moderate
    case urgent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mild: L10n.tr("Mild", default: "Mild")
        case .moderate: L10n.tr("Moderate", default: "Moderate")
        case .urgent: L10n.tr("Urgent", default: "Urgent")
        }
    }
}

enum OnboardingFocus: String, CaseIterable, Identifiable, Codable {
    case wellness
    case routines
    case memories
    case dashboard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wellness: L10n.tr("Wellness first", default: "Wellness first")
        case .routines: L10n.tr("Routines first", default: "Routines first")
        case .memories: L10n.tr("Memories first", default: "Memories first")
        case .dashboard: L10n.tr("Everything together", default: "Everything together")
        }
    }

    var detail: String {
        switch self {
        case .wellness:
            return L10n.tr("Keep vaccines, food notes, and vet context easy to update.", default: "Keep vaccines, food notes, and vet context easy to update.")
        case .routines:
            return L10n.tr("Start with a flexible week planner that actually adapts.", default: "Start with a flexible week planner that actually adapts.")
        case .memories:
            return L10n.tr("Turn birthdays and milestones into a living story.", default: "Turn birthdays and milestones into a living story.")
        case .dashboard:
            return L10n.tr("See wellness, routines, and memories in one bond-centered home.", default: "See wellness, routines, and memories in one bond-centered home.")
        }
    }

    var systemImage: String {
        switch self {
        case .wellness: "cross.case.fill"
        case .routines: "calendar.badge.clock"
        case .memories: "film.stack.fill"
        case .dashboard: "sparkles.tv"
        }
    }

    var preferredTab: RootTab {
        switch self {
        case .wellness:
            return .wellness
        case .routines:
            return .routines
        case .memories:
            return .memories
        case .dashboard:
            return .dashboard
        }
    }
}

struct OwnerProfile: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var headline: String
    var location: String
    var note: String
}

struct PetProfile: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var species: String
    var breed: String
    var ageDescription: String
    var weightDescription: String
    var favoriteTreat: String
    var bondStatement: String
    var energySummary: String
}

struct BehaviorSnapshot: Identifiable, Codable {
    var id: Weekday { day }
    var day: Weekday
    var energy: Double
    var calmness: Double
    var appetite: Double
    var sleepHours: Double
}

struct MedicationRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var dosage: String
    var scheduleNote: String
    var purpose: String
    var nextDose: Date
    var status: MedicationStatus
    var tone: PaletteTone
    var notificationsEnabled: Bool = true

    var nextDoseLabel: String {
        Self.dateFormatter.string(from: nextDose)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d • h:mm a"
        return formatter
    }()

    init(
        id: UUID = UUID(),
        title: String,
        dosage: String,
        scheduleNote: String,
        purpose: String,
        nextDose: Date,
        status: MedicationStatus,
        tone: PaletteTone,
        notificationsEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.dosage = dosage
        self.scheduleNote = scheduleNote
        self.purpose = purpose
        self.nextDose = nextDose
        self.status = status
        self.tone = tone
        self.notificationsEnabled = notificationsEnabled
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        dosage = try container.decode(String.self, forKey: .dosage)
        scheduleNote = try container.decode(String.self, forKey: .scheduleNote)
        purpose = try container.decode(String.self, forKey: .purpose)
        nextDose = try container.decode(Date.self, forKey: .nextDose)
        status = try container.decode(MedicationStatus.self, forKey: .status)
        tone = try container.decode(PaletteTone.self, forKey: .tone)
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
    }
}

struct SymptomEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var detail: String
    var observedAt: Date
    var severity: SymptomSeverity
    var systemImage: String
    var tone: PaletteTone

    var observedLabel: String {
        Self.dateFormatter.string(from: observedAt)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        return formatter
    }()
}

struct VaccineRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var lastGiven: Date
    var nextDue: Date
    var status: VaccineStatus
    var note: String
    var certificateData: Data?
    var notificationsEnabled: Bool = true

    var lastGivenLabel: String {
        Self.dateFormatter.string(from: lastGiven)
    }

    var nextDueLabel: String {
        Self.dateFormatter.string(from: nextDue)
    }

    init(
        id: UUID = UUID(),
        title: String,
        lastGiven: Date,
        nextDue: Date,
        status: VaccineStatus,
        note: String,
        certificateData: Data? = nil,
        notificationsEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.lastGiven = lastGiven
        self.nextDue = nextDue
        self.status = status
        self.note = note
        self.certificateData = certificateData
        self.notificationsEnabled = notificationsEnabled
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        lastGiven = try container.decode(Date.self, forKey: .lastGiven)
        nextDue = try container.decode(Date.self, forKey: .nextDue)
        status = try container.decode(VaccineStatus.self, forKey: .status)
        note = try container.decode(String.self, forKey: .note)
        certificateData = try container.decodeIfPresent(Data.self, forKey: .certificateData)
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
    }
}

struct MedicalEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var summary: String
    var clinician: String
    var tone: PaletteTone

    var dateLabel: String {
        Self.dateFormatter.string(from: date)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}

struct FoodPreference: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var detail: String
    var systemImage: String
}

struct RoutineItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var subtitle: String
    var day: Weekday
    var time: ClockTime
    var durationMinutes: Int
    var systemImage: String
    var category: RoutineCategory
    var tone: PaletteTone
    var isCompleted: Bool
    var notificationsEnabled: Bool = true

    var durationLabel: String {
        L10n.format("%d min", default: "%d min", durationMinutes)
    }

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        day: Weekday,
        time: ClockTime,
        durationMinutes: Int,
        systemImage: String,
        category: RoutineCategory,
        tone: PaletteTone,
        isCompleted: Bool,
        notificationsEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.day = day
        self.time = time
        self.durationMinutes = durationMinutes
        self.systemImage = systemImage
        self.category = category
        self.tone = tone
        self.isCompleted = isCompleted
        self.notificationsEnabled = notificationsEnabled
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        day = try container.decode(Weekday.self, forKey: .day)
        time = try container.decode(ClockTime.self, forKey: .time)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        systemImage = try container.decode(String.self, forKey: .systemImage)
        category = try container.decode(RoutineCategory.self, forKey: .category)
        tone = try container.decode(PaletteTone.self, forKey: .tone)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
    }
}

struct MemoryMoment: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var caption: String
    var detail: String
    var photoData: Data?
    var systemImage: String
    var tone: PaletteTone
    var isAnnualCelebration: Bool
    var notificationsEnabled: Bool = true

    var dateLabel: String {
        if isAnnualCelebration {
            return Self.annualDateFormatter.string(from: date)
        }
        return Self.fullDateFormatter.string(from: date)
    }

    var daysUntilNextCelebration: Int? {
        guard isAnnualCelebration else { return nil }

        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let now = calendar.startOfDay(for: .now)

        var nextComponents = calendar.dateComponents([.year], from: now)
        nextComponents.month = month
        nextComponents.day = day

        guard var nextCelebration = calendar.date(from: nextComponents) else { return nil }
        if nextCelebration < now {
            nextCelebration = calendar.date(byAdding: .year, value: 1, to: nextCelebration) ?? nextCelebration
        }

        return calendar.dateComponents([.day], from: now, to: nextCelebration).day
    }

    private static let annualDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()

    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        caption: String,
        detail: String,
        photoData: Data? = nil,
        systemImage: String,
        tone: PaletteTone,
        isAnnualCelebration: Bool,
        notificationsEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.caption = caption
        self.detail = detail
        self.photoData = photoData
        self.systemImage = systemImage
        self.tone = tone
        self.isAnnualCelebration = isAnnualCelebration
        self.notificationsEnabled = notificationsEnabled
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
        caption = try container.decode(String.self, forKey: .caption)
        detail = try container.decode(String.self, forKey: .detail)
        photoData = try container.decodeIfPresent(Data.self, forKey: .photoData)
        systemImage = try container.decode(String.self, forKey: .systemImage)
        tone = try container.decode(PaletteTone.self, forKey: .tone)
        isAnnualCelebration = try container.decode(Bool.self, forKey: .isAnnualCelebration)
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
    }
}

struct CompanionInsight: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let suggestedAction: String
    let priority: InsightPriority
    let systemImage: String
}

struct PersistedAppState: Codable {
    var selectedTab: RootTab
    var selectedDay: Weekday
    var owner: OwnerProfile
    var pet: PetProfile
    var notificationPreferences: NotificationPreferences
    var ownerPhotoData: Data?
    var petPhotoData: Data?
    var bondPhotoData: Data?
    var behaviorSnapshots: [BehaviorSnapshot]
    var vaccinations: [VaccineRecord]
    var medications: [MedicationRecord]
    var symptoms: [SymptomEntry]
    var medicalHistory: [MedicalEntry]
    var foodPreferences: [FoodPreference]
    var routines: [RoutineItem]
    var memories: [MemoryMoment]
    var onboardingFocus: OnboardingFocus
    var hasCompletedOnboarding: Bool

    init(
        selectedTab: RootTab,
        selectedDay: Weekday,
        owner: OwnerProfile,
        pet: PetProfile,
        notificationPreferences: NotificationPreferences,
        ownerPhotoData: Data?,
        petPhotoData: Data?,
        bondPhotoData: Data?,
        behaviorSnapshots: [BehaviorSnapshot],
        vaccinations: [VaccineRecord],
        medications: [MedicationRecord],
        symptoms: [SymptomEntry],
        medicalHistory: [MedicalEntry],
        foodPreferences: [FoodPreference],
        routines: [RoutineItem],
        memories: [MemoryMoment],
        onboardingFocus: OnboardingFocus,
        hasCompletedOnboarding: Bool
    ) {
        self.selectedTab = selectedTab
        self.selectedDay = selectedDay
        self.owner = owner
        self.pet = pet
        self.notificationPreferences = notificationPreferences
        self.ownerPhotoData = ownerPhotoData
        self.petPhotoData = petPhotoData
        self.bondPhotoData = bondPhotoData
        self.behaviorSnapshots = behaviorSnapshots
        self.vaccinations = vaccinations
        self.medications = medications
        self.symptoms = symptoms
        self.medicalHistory = medicalHistory
        self.foodPreferences = foodPreferences
        self.routines = routines
        self.memories = memories
        self.onboardingFocus = onboardingFocus
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    init(seed: AppSeed) {
        selectedTab = .dashboard
        selectedDay = .current
        owner = seed.owner
        pet = seed.pet
        notificationPreferences = NotificationPreferences()
        ownerPhotoData = nil
        petPhotoData = nil
        bondPhotoData = nil
        behaviorSnapshots = seed.behaviorSnapshots
        vaccinations = seed.vaccinations
        medications = seed.medications
        symptoms = seed.symptoms
        medicalHistory = seed.medicalHistory
        foodPreferences = seed.foodPreferences
        routines = seed.routines
        memories = seed.memories
        onboardingFocus = .dashboard
        hasCompletedOnboarding = false
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedTab = try container.decode(RootTab.self, forKey: .selectedTab)
        selectedDay = try container.decode(Weekday.self, forKey: .selectedDay)
        owner = try container.decode(OwnerProfile.self, forKey: .owner)
        pet = try container.decode(PetProfile.self, forKey: .pet)
        notificationPreferences = try container.decodeIfPresent(NotificationPreferences.self, forKey: .notificationPreferences) ?? NotificationPreferences()
        ownerPhotoData = try container.decodeIfPresent(Data.self, forKey: .ownerPhotoData)
        petPhotoData = try container.decodeIfPresent(Data.self, forKey: .petPhotoData)
        bondPhotoData = try container.decodeIfPresent(Data.self, forKey: .bondPhotoData)
        behaviorSnapshots = try container.decode([BehaviorSnapshot].self, forKey: .behaviorSnapshots)
        vaccinations = try container.decode([VaccineRecord].self, forKey: .vaccinations)
        medications = try container.decodeIfPresent([MedicationRecord].self, forKey: .medications) ?? []
        symptoms = try container.decodeIfPresent([SymptomEntry].self, forKey: .symptoms) ?? []
        medicalHistory = try container.decode([MedicalEntry].self, forKey: .medicalHistory)
        foodPreferences = try container.decode([FoodPreference].self, forKey: .foodPreferences)
        routines = try container.decode([RoutineItem].self, forKey: .routines)
        memories = try container.decode([MemoryMoment].self, forKey: .memories)
        onboardingFocus = try container.decodeIfPresent(OnboardingFocus.self, forKey: .onboardingFocus) ?? .dashboard
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
    }
}

struct AppSeed {
    let owner: OwnerProfile
    let pet: PetProfile
    let behaviorSnapshots: [BehaviorSnapshot]
    let vaccinations: [VaccineRecord]
    let medications: [MedicationRecord]
    let symptoms: [SymptomEntry]
    let medicalHistory: [MedicalEntry]
    let foodPreferences: [FoodPreference]
    let routines: [RoutineItem]
    let memories: [MemoryMoment]

    static let empty = AppSeed(
        owner: OwnerProfile(
            name: "",
            headline: "",
            location: "",
            note: ""
        ),
        pet: PetProfile(
            name: "",
            species: "",
            breed: "",
            ageDescription: "",
            weightDescription: "",
            favoriteTreat: "",
            bondStatement: "",
            energySummary: ""
        ),
        behaviorSnapshots: [],
        vaccinations: [],
        medications: [],
        symptoms: [],
        medicalHistory: [],
        foodPreferences: [],
        routines: [],
        memories: []
    )

    static let preview = AppSeed(
        owner: OwnerProfile(
            name: "Maya",
            headline: "Golden-hour hikes, calm evenings, and a camera roll full of Sol.",
            location: "San Francisco, CA",
            note: "Pet parent who loves soft routines, travel notes, and keeping every memory."
        ),
        pet: PetProfile(
            name: "Sol",
            species: "Dog",
            breed: "Nova Scotia Duck Tolling Retriever",
            ageDescription: "3 years old",
            weightDescription: "19.4 kg",
            favoriteTreat: "Blueberry yogurt drops",
            bondStatement: "The most peaceful evenings happen after sniff walks and slower dinners.",
            energySummary: "Best energy when play is paired with a quiet recovery block afterward."
        ),
        behaviorSnapshots: [
            BehaviorSnapshot(day: .monday, energy: 0.82, calmness: 0.78, appetite: 0.94, sleepHours: 12.0),
            BehaviorSnapshot(day: .tuesday, energy: 0.88, calmness: 0.70, appetite: 0.90, sleepHours: 11.3),
            BehaviorSnapshot(day: .wednesday, energy: 0.79, calmness: 0.85, appetite: 0.96, sleepHours: 12.4),
            BehaviorSnapshot(day: .thursday, energy: 0.91, calmness: 0.68, appetite: 0.89, sleepHours: 10.9),
            BehaviorSnapshot(day: .friday, energy: 0.75, calmness: 0.88, appetite: 0.97, sleepHours: 12.7),
            BehaviorSnapshot(day: .saturday, energy: 0.93, calmness: 0.73, appetite: 0.92, sleepHours: 11.2),
            BehaviorSnapshot(day: .sunday, energy: 0.74, calmness: 0.90, appetite: 0.98, sleepHours: 13.0),
        ],
        vaccinations: [
            VaccineRecord(title: "Rabies", lastGiven: date(2025, 1, 12), nextDue: date(2028, 1, 12), status: .covered, note: "Three-year booster complete."),
            VaccineRecord(title: "DHPP", lastGiven: date(2026, 2, 8), nextDue: date(2027, 2, 8), status: .onTrack, note: "Annual booster logged with no reactions."),
            VaccineRecord(title: "Bordetella", lastGiven: date(2026, 3, 2), nextDue: date(2026, 9, 2), status: .watch, note: "Needed before boarding and social daycare."),
            VaccineRecord(title: "Leptospirosis", lastGiven: date(2026, 2, 8), nextDue: date(2027, 2, 8), status: .onTrack, note: "Tracked because of weekend trail exposure."),
        ],
        medications: [
            MedicationRecord(
                title: "Seasonal allergy chew",
                dosage: "1 soft chew",
                scheduleNote: "Evenings with dinner during flare weeks",
                purpose: "Keeps paw licking and redness more settled after park days.",
                nextDose: dateTime(2026, 4, 6, 18, 30),
                status: .active,
                tone: .meadow
            ),
            MedicationRecord(
                title: "Joint support oil",
                dosage: "2 pumps",
                scheduleNote: "Morning bowl after long trail weekends",
                purpose: "Helps recovery when activity volume spikes.",
                nextDose: dateTime(2026, 4, 7, 8, 0),
                status: .watch,
                tone: .lagoon
            ),
        ],
        symptoms: [
            SymptomEntry(
                title: "Paw licking",
                detail: "Mild licking after grass-heavy park loop, settled after rinse and rest.",
                observedAt: dateTime(2026, 4, 3, 20, 10),
                severity: .mild,
                systemImage: "pawprint.fill",
                tone: .apricot
            ),
            SymptomEntry(
                title: "Soft appetite dip",
                detail: "Ate slower than usual after a high-stimulation day, but finished dinner with broth.",
                observedAt: dateTime(2026, 4, 2, 19, 0),
                severity: .moderate,
                systemImage: "fork.knife.circle.fill",
                tone: .twilight
            ),
        ],
        medicalHistory: [
            MedicalEntry(
                title: "Annual wellness exam",
                date: date(2026, 2, 8),
                summary: "Heart, joints, and coat all looked strong. Vet suggested keeping recovery days after intense play.",
                clinician: "Dr. Rivera",
                tone: .lagoon
            ),
            MedicalEntry(
                title: "Seasonal allergy flare",
                date: date(2025, 11, 3),
                summary: "Mild paw licking after park grass exposure. Added oat rinse and a post-walk wipe routine.",
                clinician: "Dr. Rivera",
                tone: .apricot
            ),
            MedicalEntry(
                title: "Dental polish visit",
                date: date(2025, 7, 18),
                summary: "No extractions needed. Recommended frozen chew sessions twice weekly.",
                clinician: "Pacific Pet Dental",
                tone: .meadow
            ),
        ],
        foodPreferences: [
            FoodPreference(title: "Main bowl", detail: "Salmon kibble with pumpkin topper.", systemImage: "fork.knife.circle.fill"),
            FoodPreference(title: "Sensitive note", detail: "Chicken-heavy treats can soften appetite the next day.", systemImage: "exclamationmark.triangle.fill"),
            FoodPreference(title: "Hydration ritual", detail: "Warm bone broth splash at dinner.", systemImage: "drop.fill"),
            FoodPreference(title: "Favorite enrichment", detail: "Frozen lick mat after bath nights.", systemImage: "sparkles"),
        ],
        routines: [
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000001")!, title: "Sunrise sniff walk", subtitle: "Leash-led decompression route by the marina.", day: .monday, time: ClockTime(hour: 6, minute: 45), durationMinutes: 35, systemImage: "sunrise.fill", category: .walk, tone: .apricot, isCompleted: true),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000002")!, title: "Dinner + supplements", subtitle: "Pumpkin topper, joint chew, slow feeder.", day: .monday, time: ClockTime(hour: 18, minute: 15), durationMinutes: 20, systemImage: "carrot.fill", category: .meal, tone: .lagoon, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000003")!, title: "Nose-work set", subtitle: "Three scent boxes and one hidden favorite toy.", day: .tuesday, time: ClockTime(hour: 19, minute: 30), durationMinutes: 25, systemImage: "brain.head.profile", category: .training, tone: .twilight, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000004")!, title: "Midweek brush-out", subtitle: "Coat care and paw balm before bed.", day: .wednesday, time: ClockTime(hour: 20, minute: 0), durationMinutes: 18, systemImage: "comb.fill", category: .care, tone: .meadow, isCompleted: true),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000005")!, title: "Harbor fetch block", subtitle: "Controlled sprint bursts with cool-down walk.", day: .thursday, time: ClockTime(hour: 17, minute: 40), durationMinutes: 40, systemImage: "figure.run.circle.fill", category: .play, tone: .apricot, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000006")!, title: "Quiet cafe settle", subtitle: "Mat place-training and people-watching.", day: .friday, time: ClockTime(hour: 8, minute: 10), durationMinutes: 30, systemImage: "cup.and.saucer.fill", category: .training, tone: .lagoon, isCompleted: true),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000007")!, title: "Hill trail loop", subtitle: "Longline walk with recovery stretch after.", day: .saturday, time: ClockTime(hour: 9, minute: 0), durationMinutes: 75, systemImage: "mountain.2.fill", category: .walk, tone: .meadow, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000008")!, title: "Soft Sunday reset", subtitle: "Light groom, broth bowl, and nap soundtrack.", day: .sunday, time: ClockTime(hour: 17, minute: 30), durationMinutes: 30, systemImage: "moon.stars.fill", category: .care, tone: .twilight, isCompleted: false),
        ],
        memories: [
            MemoryMoment(
                title: "Gotcha Day",
                date: date(2021, 4, 18),
                caption: "The day Sol fell asleep in Maya’s lap on the way home.",
                detail: "A quiet car ride turned into the first of a hundred tiny rituals. This anniversary is 21 days away.",
                systemImage: "heart.circle.fill",
                tone: .apricot,
                isAnnualCelebration: true
            ),
            MemoryMoment(
                title: "Birthday picnic",
                date: date(2021, 5, 9),
                caption: "Blueberries, a tiny hat, and wind at Crissy Field.",
                detail: "Build this into a yearly slideshow with old clips, vet growth notes, and favorite treats.",
                systemImage: "birthday.cake.fill",
                tone: .lagoon,
                isAnnualCelebration: true
            ),
            MemoryMoment(
                title: "The first beach sprint",
                date: date(2025, 8, 14),
                caption: "Seven perfect minutes of fearless zoomies by the water.",
                detail: "AuriTails turns moments like this into calm, cinematic keepsakes instead of burying them in the camera roll.",
                systemImage: "sparkles.rectangle.stack.fill",
                tone: .twilight,
                isAnnualCelebration: false
            ),
            MemoryMoment(
                title: "Brave at the dentist",
                date: date(2025, 7, 18),
                caption: "Still asked politely for yogurt drops after the appointment.",
                detail: "Medical milestones should feel human too. This one lives next to the clinical notes and the happy photo.",
                systemImage: "cross.vial.fill",
                tone: .meadow,
                isAnnualCelebration: false
            ),
            MemoryMoment(
                title: "Rainy window nap",
                date: date(2025, 12, 3),
                caption: "The first day Sol chose the travel blanket all on his own.",
                detail: "A simple home ritual that now marks whenever the family needs a low-stimulation reset evening.",
                systemImage: "cloud.drizzle.fill",
                tone: .lagoon,
                isAnnualCelebration: false
            ),
        ]
    )

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = year
        components.month = month
        components.day = day
        return components.date ?? .now
    }

    private static func dateTime(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return components.date ?? .now
    }
}
