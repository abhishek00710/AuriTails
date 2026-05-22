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
    case careCircle
    case notificationSettings
    case legalCenter
    case behaviorCheckInEditor(Weekday?)
    case weightEntryEditor(UUID?)
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
        case .careCircle:
            return "care-circle"
        case .notificationSettings:
            return "notification-settings"
        case .legalCenter:
            return "legal-center"
        case let .behaviorCheckInEditor(day):
            return "behavior-\(day?.rawValue ?? 0)"
        case let .weightEntryEditor(id):
            return "weight-\(id?.uuidString ?? "new")"
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
    case grooming
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
        case .grooming: "comb.fill"
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

enum PetProfileStatus: String, Codable {
    case active
    case archived

    var title: String {
        switch self {
        case .active:
            return L10n.tr("Active", default: "Active")
        case .archived:
            return L10n.tr("Archived", default: "Archived")
        }
    }
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
    var status: PetProfileStatus = .active
    var photoData: Data? = nil
    var bondPhotoData: Data? = nil

    init(
        id: UUID = UUID(),
        name: String,
        species: String,
        breed: String,
        ageDescription: String,
        weightDescription: String,
        favoriteTreat: String,
        bondStatement: String,
        energySummary: String,
        status: PetProfileStatus = .active,
        photoData: Data? = nil,
        bondPhotoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.breed = breed
        self.ageDescription = ageDescription
        self.weightDescription = weightDescription
        self.favoriteTreat = favoriteTreat
        self.bondStatement = bondStatement
        self.energySummary = energySummary
        self.status = status
        self.photoData = photoData
        self.bondPhotoData = bondPhotoData
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        species = try container.decode(String.self, forKey: .species)
        breed = try container.decode(String.self, forKey: .breed)
        ageDescription = try container.decode(String.self, forKey: .ageDescription)
        weightDescription = try container.decode(String.self, forKey: .weightDescription)
        favoriteTreat = try container.decode(String.self, forKey: .favoriteTreat)
        bondStatement = try container.decode(String.self, forKey: .bondStatement)
        energySummary = try container.decode(String.self, forKey: .energySummary)
        status = try container.decodeIfPresent(PetProfileStatus.self, forKey: .status) ?? .active
        photoData = try container.decodeIfPresent(Data.self, forKey: .photoData)
        bondPhotoData = try container.decodeIfPresent(Data.self, forKey: .bondPhotoData)
    }
}

enum CareCircleRole: String, CaseIterable, Codable {
    case owner
    case caregiver

    var title: String {
        switch self {
        case .owner:
            return L10n.tr("Owner", default: "Owner")
        case .caregiver:
            return L10n.tr("Caregiver", default: "Caregiver")
        }
    }
}

enum CareCircleMemberStatus: String, CaseIterable, Codable {
    case invited
    case active

    var title: String {
        switch self {
        case .invited:
            return L10n.tr("Invite sent", default: "Invite sent")
        case .active:
            return L10n.tr("Active", default: "Active")
        }
    }
}

struct CareCircleMember: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var contact: String
    var relationshipLabel: String
    var role: CareCircleRole
    var status: CareCircleMemberStatus
    var note: String
    var invitedAt: Date

    var subtitle: String {
        let pieces = [relationshipLabel, contact].filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return pieces.joined(separator: " • ")
    }

    var invitedLabel: String {
        Self.dateFormatter.string(from: invitedAt)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}

struct CareActivityEvent: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var detail: String
    var createdAt: Date
    var systemImage: String
    var tone: PaletteTone

    var createdLabel: String {
        Self.dateFormatter.localizedString(for: createdAt, relativeTo: .now)
    }

    private static let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}

struct BehaviorSnapshot: Identifiable, Codable {
    var id: UUID = UUID()
    var petID: UUID?
    var day: Weekday
    var energy: Double
    var calmness: Double
    var appetite: Double
    var sleepHours: Double
}

enum WeightUnit: String, CaseIterable, Identifiable, Codable {
    case kilograms
    case pounds

    var id: String { rawValue }

    var title: String {
        switch self {
        case .kilograms: return L10n.tr("Kilograms", default: "Kilograms")
        case .pounds: return L10n.tr("Pounds", default: "Pounds")
        }
    }

    var shortLabel: String {
        switch self {
        case .kilograms: return L10n.tr("kg", default: "kg")
        case .pounds: return L10n.tr("lb", default: "lb")
        }
    }

    func toKilograms(_ value: Double) -> Double {
        switch self {
        case .kilograms: return value
        case .pounds: return value / 2.20462
        }
    }

    func fromKilograms(_ kilograms: Double) -> Double {
        switch self {
        case .kilograms: return kilograms
        case .pounds: return kilograms * 2.20462
        }
    }
}

struct WeightEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var petID: UUID?
    var loggedAt: Date
    var value: Double
    var unit: WeightUnit
    var note: String

    var kilogramsValue: Double {
        unit.toKilograms(value)
    }

    func displayValue(in unit: WeightUnit) -> Double {
        unit.fromKilograms(kilogramsValue)
    }

    var valueLabel: String {
        "\(value.formatted(.number.precision(.fractionLength(1)))) \(unit.shortLabel)"
    }

    var loggedLabel: String {
        Self.dateFormatter.string(from: loggedAt)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}

struct MedicationRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var petID: UUID?
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
        petID: UUID? = nil,
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
        self.petID = petID
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
        petID = try container.decodeIfPresent(UUID.self, forKey: .petID)
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
    var petID: UUID?
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
    var petID: UUID?
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
        petID: UUID? = nil,
        title: String,
        lastGiven: Date,
        nextDue: Date,
        status: VaccineStatus,
        note: String,
        certificateData: Data? = nil,
        notificationsEnabled: Bool = true
    ) {
        self.id = id
        self.petID = petID
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
        petID = try container.decodeIfPresent(UUID.self, forKey: .petID)
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
    var petID: UUID?
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
    var petID: UUID?
    var title: String
    var detail: String
    var systemImage: String
}

struct RoutineItem: Identifiable, Codable {
    var id: UUID = UUID()
    var petID: UUID?
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
        petID: UUID? = nil,
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
        self.petID = petID
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
        petID = try container.decodeIfPresent(UUID.self, forKey: .petID)
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
    var petID: UUID?
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
        petID: UUID? = nil,
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
        self.petID = petID
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
        petID = try container.decodeIfPresent(UUID.self, forKey: .petID)
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

struct AppReviewState: Codable {
    var positiveActionCount: Int
    var delightActionCount: Int
    var lastPromptedActionCount: Int
    var lastPromptedAppVersion: String?

    init(
        positiveActionCount: Int = 0,
        delightActionCount: Int = 0,
        lastPromptedActionCount: Int = 0,
        lastPromptedAppVersion: String? = nil
    ) {
        self.positiveActionCount = positiveActionCount
        self.delightActionCount = delightActionCount
        self.lastPromptedActionCount = lastPromptedActionCount
        self.lastPromptedAppVersion = lastPromptedAppVersion
    }
}

struct PersistedAppState: Codable {
    var selectedTab: RootTab
    var selectedDay: Weekday
    var owner: OwnerProfile
    var pets: [PetProfile]
    var selectedPetID: UUID?
    var notificationPreferences: NotificationPreferences
    var ownerPhotoData: Data?
    var behaviorSnapshots: [BehaviorSnapshot]
    var weightEntries: [WeightEntry]
    var vaccinations: [VaccineRecord]
    var medications: [MedicationRecord]
    var symptoms: [SymptomEntry]
    var medicalHistory: [MedicalEntry]
    var foodPreferences: [FoodPreference]
    var routines: [RoutineItem]
    var memories: [MemoryMoment]
    var careCircleMembers: [CareCircleMember]
    var careActivityEvents: [CareActivityEvent]
    var onboardingFocus: OnboardingFocus
    var hasCompletedOnboarding: Bool
    var appReviewState: AppReviewState

    private enum CodingKeys: String, CodingKey {
        case selectedTab
        case selectedDay
        case owner
        case pets
        case selectedPetID
        case notificationPreferences
        case ownerPhotoData
        case behaviorSnapshots
        case weightEntries
        case vaccinations
        case medications
        case symptoms
        case medicalHistory
        case foodPreferences
        case routines
        case memories
        case careCircleMembers
        case careActivityEvents
        case onboardingFocus
        case hasCompletedOnboarding
        case appReviewState
        case pet
        case petPhotoData
        case bondPhotoData
    }

    init(
        selectedTab: RootTab,
        selectedDay: Weekday,
        owner: OwnerProfile,
        pets: [PetProfile],
        selectedPetID: UUID?,
        notificationPreferences: NotificationPreferences,
        ownerPhotoData: Data?,
        behaviorSnapshots: [BehaviorSnapshot],
        weightEntries: [WeightEntry],
        vaccinations: [VaccineRecord],
        medications: [MedicationRecord],
        symptoms: [SymptomEntry],
        medicalHistory: [MedicalEntry],
        foodPreferences: [FoodPreference],
        routines: [RoutineItem],
        memories: [MemoryMoment],
        careCircleMembers: [CareCircleMember],
        careActivityEvents: [CareActivityEvent],
        onboardingFocus: OnboardingFocus,
        hasCompletedOnboarding: Bool,
        appReviewState: AppReviewState
    ) {
        self.selectedTab = selectedTab
        self.selectedDay = selectedDay
        self.owner = owner
        self.pets = pets
        self.selectedPetID = selectedPetID
        self.notificationPreferences = notificationPreferences
        self.ownerPhotoData = ownerPhotoData
        self.behaviorSnapshots = behaviorSnapshots
        self.weightEntries = weightEntries
        self.vaccinations = vaccinations
        self.medications = medications
        self.symptoms = symptoms
        self.medicalHistory = medicalHistory
        self.foodPreferences = foodPreferences
        self.routines = routines
        self.memories = memories
        self.careCircleMembers = careCircleMembers
        self.careActivityEvents = careActivityEvents
        self.onboardingFocus = onboardingFocus
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.appReviewState = appReviewState
    }

    init(seed: AppSeed) {
        selectedTab = .dashboard
        selectedDay = .current
        owner = seed.owner
        pets = seed.pets
        selectedPetID = seed.selectedPetID
        notificationPreferences = NotificationPreferences()
        ownerPhotoData = nil
        behaviorSnapshots = seed.behaviorSnapshots
        weightEntries = seed.weightEntries
        vaccinations = seed.vaccinations
        medications = seed.medications
        symptoms = seed.symptoms
        medicalHistory = seed.medicalHistory
        foodPreferences = seed.foodPreferences
        routines = seed.routines
        memories = seed.memories
        careCircleMembers = seed.careCircleMembers
        careActivityEvents = seed.careActivityEvents
        onboardingFocus = .dashboard
        hasCompletedOnboarding = false
        appReviewState = AppReviewState()
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedTab = try container.decode(RootTab.self, forKey: .selectedTab)
        selectedDay = try container.decode(Weekday.self, forKey: .selectedDay)
        owner = try container.decode(OwnerProfile.self, forKey: .owner)
        notificationPreferences = try container.decodeIfPresent(NotificationPreferences.self, forKey: .notificationPreferences) ?? NotificationPreferences()
        ownerPhotoData = try container.decodeIfPresent(Data.self, forKey: .ownerPhotoData)
        let legacyPetPhotoData = try container.decodeIfPresent(Data.self, forKey: .petPhotoData)
        let legacyBondPhotoData = try container.decodeIfPresent(Data.self, forKey: .bondPhotoData)
        if let decodedPets = try container.decodeIfPresent([PetProfile].self, forKey: .pets), !decodedPets.isEmpty {
            pets = decodedPets
        } else {
            let legacyPet = try container.decode(PetProfile.self, forKey: .pet)
            pets = [
                PetProfile(
                    id: legacyPet.id,
                    name: legacyPet.name,
                    species: legacyPet.species,
                    breed: legacyPet.breed,
                    ageDescription: legacyPet.ageDescription,
                    weightDescription: legacyPet.weightDescription,
                    favoriteTreat: legacyPet.favoriteTreat,
                    bondStatement: legacyPet.bondStatement,
                    energySummary: legacyPet.energySummary,
                    photoData: legacyPet.photoData ?? legacyPetPhotoData,
                    bondPhotoData: legacyPet.bondPhotoData ?? legacyBondPhotoData
                )
            ]
        }
        selectedPetID = try container.decodeIfPresent(UUID.self, forKey: .selectedPetID) ?? pets.first?.id
        behaviorSnapshots = try container.decode([BehaviorSnapshot].self, forKey: .behaviorSnapshots)
        weightEntries = try container.decodeIfPresent([WeightEntry].self, forKey: .weightEntries) ?? []
        vaccinations = try container.decode([VaccineRecord].self, forKey: .vaccinations)
        medications = try container.decodeIfPresent([MedicationRecord].self, forKey: .medications) ?? []
        symptoms = try container.decodeIfPresent([SymptomEntry].self, forKey: .symptoms) ?? []
        medicalHistory = try container.decode([MedicalEntry].self, forKey: .medicalHistory)
        foodPreferences = try container.decode([FoodPreference].self, forKey: .foodPreferences)
        routines = try container.decode([RoutineItem].self, forKey: .routines)
        memories = try container.decode([MemoryMoment].self, forKey: .memories)
        careCircleMembers = try container.decodeIfPresent([CareCircleMember].self, forKey: .careCircleMembers) ?? []
        careActivityEvents = try container.decodeIfPresent([CareActivityEvent].self, forKey: .careActivityEvents) ?? []
        onboardingFocus = try container.decodeIfPresent(OnboardingFocus.self, forKey: .onboardingFocus) ?? .dashboard
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        appReviewState = try container.decodeIfPresent(AppReviewState.self, forKey: .appReviewState) ?? AppReviewState()
        self = normalizedForMultiPet()
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedTab, forKey: .selectedTab)
        try container.encode(selectedDay, forKey: .selectedDay)
        try container.encode(owner, forKey: .owner)
        try container.encode(pets, forKey: .pets)
        try container.encodeIfPresent(selectedPetID, forKey: .selectedPetID)
        try container.encode(notificationPreferences, forKey: .notificationPreferences)
        try container.encodeIfPresent(ownerPhotoData, forKey: .ownerPhotoData)
        try container.encode(behaviorSnapshots, forKey: .behaviorSnapshots)
        try container.encode(weightEntries, forKey: .weightEntries)
        try container.encode(vaccinations, forKey: .vaccinations)
        try container.encode(medications, forKey: .medications)
        try container.encode(symptoms, forKey: .symptoms)
        try container.encode(medicalHistory, forKey: .medicalHistory)
        try container.encode(foodPreferences, forKey: .foodPreferences)
        try container.encode(routines, forKey: .routines)
        try container.encode(memories, forKey: .memories)
        try container.encode(careCircleMembers, forKey: .careCircleMembers)
        try container.encode(careActivityEvents, forKey: .careActivityEvents)
        try container.encode(onboardingFocus, forKey: .onboardingFocus)
        try container.encode(hasCompletedOnboarding, forKey: .hasCompletedOnboarding)
        try container.encode(appReviewState, forKey: .appReviewState)
    }

    var primaryPetID: UUID {
        let activePetID = pets.first(where: { $0.status == .active })?.id
        return selectedPetID ?? activePetID ?? pets.first?.id ?? UUID()
    }

    var selectedPet: PetProfile {
        if let selectedPetID, let pet = pets.first(where: { $0.id == selectedPetID && $0.status == .active }) {
            return pet
        }
        return pets.first(where: { $0.status == .active }) ?? pets.first ?? PetProfile(
            name: "",
            species: "",
            breed: "",
            ageDescription: "",
            weightDescription: "",
            favoriteTreat: "",
            bondStatement: "",
            energySummary: ""
        )
    }

    func normalizedForMultiPet() -> PersistedAppState {
        var normalized = self
        if normalized.pets.isEmpty {
            normalized.pets = [
                PetProfile(
                    name: "",
                    species: "",
                    breed: "",
                    ageDescription: "",
                    weightDescription: "",
                    favoriteTreat: "",
                    bondStatement: "",
                    energySummary: ""
                )
            ]
        }

        let activePetID = normalized.pets.first(where: { $0.status == .active })?.id
        let fallbackPetID = normalized.selectedPetID.flatMap { selectedID in
            normalized.pets.first(where: { $0.id == selectedID && $0.status == .active })?.id
        } ?? activePetID ?? normalized.pets.first?.id
        normalized.selectedPetID = fallbackPetID
        guard let fallbackPetID else { return normalized }

        normalized.behaviorSnapshots = normalized.behaviorSnapshots.map {
            var snapshot = $0
            snapshot.petID = snapshot.petID ?? fallbackPetID
            return snapshot
        }
        normalized.weightEntries = normalized.weightEntries.map {
            var entry = $0
            entry.petID = entry.petID ?? fallbackPetID
            return entry
        }
        normalized.vaccinations = normalized.vaccinations.map {
            var vaccine = $0
            vaccine.petID = vaccine.petID ?? fallbackPetID
            return vaccine
        }
        normalized.medications = normalized.medications.map {
            var medication = $0
            medication.petID = medication.petID ?? fallbackPetID
            return medication
        }
        normalized.symptoms = normalized.symptoms.map {
            var symptom = $0
            symptom.petID = symptom.petID ?? fallbackPetID
            return symptom
        }
        normalized.medicalHistory = normalized.medicalHistory.map {
            var entry = $0
            entry.petID = entry.petID ?? fallbackPetID
            return entry
        }
        normalized.foodPreferences = normalized.foodPreferences.map {
            var preference = $0
            preference.petID = preference.petID ?? fallbackPetID
            return preference
        }
        normalized.routines = normalized.routines.map {
            var routine = $0
            routine.petID = routine.petID ?? fallbackPetID
            return routine
        }
        normalized.memories = normalized.memories.map {
            var memory = $0
            memory.petID = memory.petID ?? fallbackPetID
            return memory
        }
        return normalized
    }
}

struct AppSeed {
    let owner: OwnerProfile
    let pets: [PetProfile]
    let selectedPetID: UUID?
    let behaviorSnapshots: [BehaviorSnapshot]
    let weightEntries: [WeightEntry]
    let vaccinations: [VaccineRecord]
    let medications: [MedicationRecord]
    let symptoms: [SymptomEntry]
    let medicalHistory: [MedicalEntry]
    let foodPreferences: [FoodPreference]
    let routines: [RoutineItem]
    let memories: [MemoryMoment]
    let careCircleMembers: [CareCircleMember]
    let careActivityEvents: [CareActivityEvent]

    static let empty = AppSeed(
        owner: OwnerProfile(
            name: "",
            headline: "",
            location: "",
            note: ""
        ),
        pets: [
            PetProfile(
                name: "",
                species: "",
                breed: "",
                ageDescription: "",
                weightDescription: "",
                favoriteTreat: "",
                bondStatement: "",
                energySummary: ""
            )
        ],
        selectedPetID: nil,
        behaviorSnapshots: [],
        weightEntries: [],
        vaccinations: [],
        medications: [],
        symptoms: [],
        medicalHistory: [],
        foodPreferences: [],
        routines: [],
        memories: [],
        careCircleMembers: [],
        careActivityEvents: []
    )

    static let previewSolID = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
    static let previewLumiID = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!

    static let preview = AppSeed(
        owner: OwnerProfile(
            name: "Maya",
            headline: "Golden-hour hikes, calm evenings, and a camera roll full of Sol.",
            location: "San Francisco, CA",
            note: "Pet parent who loves soft routines, travel notes, and keeping every memory."
        ),
        pets: [
            PetProfile(
                id: previewSolID,
                name: "Sol",
                species: "Dog",
                breed: "Nova Scotia Duck Tolling Retriever",
                ageDescription: "3 years old",
                weightDescription: "19.4 kg",
                favoriteTreat: "Blueberry yogurt drops",
                bondStatement: "The most peaceful evenings happen after sniff walks and slower dinners.",
                energySummary: "Best energy when play is paired with a quiet recovery block afterward."
            ),
            PetProfile(
                id: previewLumiID,
                name: "Lumi",
                species: "Cat",
                breed: "Silver tabby domestic shorthair",
                ageDescription: "1 year old",
                weightDescription: "5.1 kg",
                favoriteTreat: "Freeze-dried minnows",
                bondStatement: "Confidence grows fastest when play starts small and ends with one safe cuddle stop.",
                energySummary: "Curious all day, but rests best after short bursts instead of one long outing."
            )
        ],
        selectedPetID: previewSolID,
        behaviorSnapshots: [
            BehaviorSnapshot(petID: previewSolID, day: .monday, energy: 0.82, calmness: 0.78, appetite: 0.94, sleepHours: 12.0),
            BehaviorSnapshot(petID: previewSolID, day: .tuesday, energy: 0.88, calmness: 0.70, appetite: 0.90, sleepHours: 11.3),
            BehaviorSnapshot(petID: previewSolID, day: .wednesday, energy: 0.79, calmness: 0.85, appetite: 0.96, sleepHours: 12.4),
            BehaviorSnapshot(petID: previewSolID, day: .thursday, energy: 0.91, calmness: 0.68, appetite: 0.89, sleepHours: 10.9),
            BehaviorSnapshot(petID: previewSolID, day: .friday, energy: 0.75, calmness: 0.88, appetite: 0.97, sleepHours: 12.7),
            BehaviorSnapshot(petID: previewSolID, day: .saturday, energy: 0.93, calmness: 0.73, appetite: 0.92, sleepHours: 11.2),
            BehaviorSnapshot(petID: previewSolID, day: .sunday, energy: 0.74, calmness: 0.90, appetite: 0.98, sleepHours: 13.0),
            BehaviorSnapshot(petID: previewLumiID, day: .monday, energy: 0.64, calmness: 0.82, appetite: 0.88, sleepHours: 14.1),
            BehaviorSnapshot(petID: previewLumiID, day: .tuesday, energy: 0.71, calmness: 0.76, appetite: 0.91, sleepHours: 13.8),
            BehaviorSnapshot(petID: previewLumiID, day: .wednesday, energy: 0.69, calmness: 0.86, appetite: 0.94, sleepHours: 14.4),
            BehaviorSnapshot(petID: previewLumiID, day: .thursday, energy: 0.78, calmness: 0.70, appetite: 0.87, sleepHours: 13.2),
            BehaviorSnapshot(petID: previewLumiID, day: .friday, energy: 0.66, calmness: 0.89, appetite: 0.95, sleepHours: 14.7),
            BehaviorSnapshot(petID: previewLumiID, day: .saturday, energy: 0.82, calmness: 0.74, appetite: 0.90, sleepHours: 13.5),
            BehaviorSnapshot(petID: previewLumiID, day: .sunday, energy: 0.61, calmness: 0.92, appetite: 0.96, sleepHours: 15.0),
        ],
        weightEntries: [
            WeightEntry(petID: previewSolID, loggedAt: date(2026, 2, 12), value: 19.8, unit: .kilograms, note: "Post-winter checkup baseline."),
            WeightEntry(petID: previewSolID, loggedAt: date(2026, 2, 26), value: 19.6, unit: .kilograms, note: "A touch leaner after trail-heavy weeks."),
            WeightEntry(petID: previewSolID, loggedAt: date(2026, 3, 12), value: 19.5, unit: .kilograms, note: "Holding steady with calmer evenings."),
            WeightEntry(petID: previewSolID, loggedAt: date(2026, 3, 28), value: 19.4, unit: .kilograms, note: "Current passport weight."),
            WeightEntry(petID: previewLumiID, loggedAt: date(2026, 2, 10), value: 5.3, unit: .kilograms, note: "Young-dog baseline after adoption paperwork."),
            WeightEntry(petID: previewLumiID, loggedAt: date(2026, 2, 24), value: 5.2, unit: .kilograms, note: "Settling into smaller portions and more sniff breaks."),
            WeightEntry(petID: previewLumiID, loggedAt: date(2026, 3, 10), value: 5.1, unit: .kilograms, note: "Steady after switching to puzzle-feeder dinners."),
            WeightEntry(petID: previewLumiID, loggedAt: date(2026, 3, 26), value: 5.1, unit: .kilograms, note: "Holding well with training treat adjustments."),
        ],
        vaccinations: [
            VaccineRecord(title: "Rabies", lastGiven: date(2025, 1, 12), nextDue: date(2028, 1, 12), status: .covered, note: "Three-year booster complete."),
            VaccineRecord(title: "DHPP", lastGiven: date(2026, 2, 8), nextDue: date(2027, 2, 8), status: .onTrack, note: "Annual booster logged with no reactions."),
            VaccineRecord(title: "Bordetella", lastGiven: date(2026, 3, 2), nextDue: date(2026, 9, 2), status: .watch, note: "Needed before boarding and social daycare."),
            VaccineRecord(title: "Leptospirosis", lastGiven: date(2026, 2, 8), nextDue: date(2027, 2, 8), status: .onTrack, note: "Tracked because of weekend trail exposure."),
            VaccineRecord(petID: previewLumiID, title: "Rabies", lastGiven: date(2026, 1, 19), nextDue: date(2029, 1, 19), status: .covered, note: "Three-year certificate imported from adoption folder."),
            VaccineRecord(petID: previewLumiID, title: "DAPP", lastGiven: date(2026, 2, 14), nextDue: date(2027, 2, 14), status: .onTrack, note: "No reaction, but kept the evening quiet."),
            VaccineRecord(petID: previewLumiID, title: "Bordetella", lastGiven: date(2026, 3, 12), nextDue: date(2026, 9, 12), status: .watch, note: "Required before small-dog daycare trial."),
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
            MedicationRecord(
                petID: previewLumiID,
                title: "Probiotic sprinkle",
                dosage: "1 small scoop",
                scheduleNote: "Breakfast during food transitions",
                purpose: "Keeps Lumi's digestion steadier when trying new toppers.",
                nextDose: dateTime(2026, 4, 7, 7, 45),
                status: .active,
                tone: .lagoon
            ),
            MedicationRecord(
                petID: previewLumiID,
                title: "Calming chew",
                dosage: "1/2 chew",
                scheduleNote: "Before busy visitor evenings",
                purpose: "Supports confidence while social greetings are still being practiced.",
                nextDose: dateTime(2026, 4, 8, 17, 45),
                status: .watch,
                tone: .twilight
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
            SymptomEntry(
                petID: previewLumiID,
                title: "Reverse sneeze spell",
                detail: "Brief episode after dusty sidewalk sniffing, settled with calm holding and water.",
                observedAt: dateTime(2026, 4, 4, 16, 35),
                severity: .mild,
                systemImage: "wind",
                tone: .lagoon
            ),
            SymptomEntry(
                petID: previewLumiID,
                title: "Nervous tummy",
                detail: "Soft stool after a high-noise afternoon. Improved after bland dinner and extra rest.",
                observedAt: dateTime(2026, 4, 1, 20, 20),
                severity: .moderate,
                systemImage: "stethoscope",
                tone: .apricot
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
            MedicalEntry(
                petID: previewLumiID,
                title: "New pet intake exam",
                date: date(2026, 1, 19),
                summary: "Healthy baseline. Vet recommended confidence-building routines and careful weight tracking.",
                clinician: "Dr. Sen",
                tone: .lagoon
            ),
            MedicalEntry(
                petID: previewLumiID,
                title: "Sensitive stomach consult",
                date: date(2026, 3, 7),
                summary: "No urgent findings. Suggested slow topper introductions and probiotic support during changes.",
                clinician: "Dr. Sen",
                tone: .apricot
            ),
        ],
        foodPreferences: [
            FoodPreference(title: "Main bowl", detail: "Salmon kibble with pumpkin topper.", systemImage: "fork.knife.circle.fill"),
            FoodPreference(title: "Sensitive note", detail: "Chicken-heavy treats can soften appetite the next day.", systemImage: "exclamationmark.triangle.fill"),
            FoodPreference(title: "Hydration ritual", detail: "Warm bone broth splash at dinner.", systemImage: "drop.fill"),
            FoodPreference(title: "Favorite enrichment", detail: "Frozen lick mat after bath nights.", systemImage: "sparkles"),
            FoodPreference(petID: previewLumiID, title: "Tiny bowl", detail: "Small-breed kibble softened with warm water.", systemImage: "fork.knife.circle.fill"),
            FoodPreference(petID: previewLumiID, title: "Confidence treat", detail: "Minnow bits for new surfaces and polite greetings.", systemImage: "sparkles"),
            FoodPreference(petID: previewLumiID, title: "Slow change rule", detail: "New toppers get introduced over three meals.", systemImage: "clock.badge.checkmark.fill"),
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
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000009")!, title: "Paw rinse ritual", subtitle: "Warm towel wipe, paw check, and balm after grass-heavy walks.", day: .tuesday, time: ClockTime(hour: 20, minute: 10), durationMinutes: 12, systemImage: "drop.fill", category: .care, tone: .meadow, isCompleted: true),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000010")!, title: "Calm crate wind-down", subtitle: "Low lights, chew mat, and one quiet cue before bedtime.", day: .wednesday, time: ClockTime(hour: 21, minute: 15), durationMinutes: 20, systemImage: "bed.double.fill", category: .training, tone: .twilight, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000011")!, title: "Sunday meal prep", subtitle: "Portion toppers, refill treat pouch, and prep broth cubes.", day: .sunday, time: ClockTime(hour: 10, minute: 30), durationMinutes: 25, systemImage: "takeoutbag.and.cup.and.straw.fill", category: .meal, tone: .lagoon, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000012")!, title: "Friday coat check", subtitle: "Quick brush, ear peek, and tick check before weekend trails.", day: .friday, time: ClockTime(hour: 18, minute: 20), durationMinutes: 14, systemImage: "comb.fill", category: .care, tone: .meadow, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000013")!, title: "Evening decompression mat", subtitle: "Ten quiet minutes on the mat after dinner and street noise.", day: .friday, time: ClockTime(hour: 20, minute: 30), durationMinutes: 10, systemImage: "rectangle.inset.filled.and.person.filled", category: .training, tone: .twilight, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "BBBBBBBB-CCCC-DDDD-EEEE-000000000001")!, petID: previewLumiID, title: "Tiny confidence walk", subtitle: "Short loop with choice-led sniff stops and one new surface.", day: .monday, time: ClockTime(hour: 7, minute: 20), durationMinutes: 18, systemImage: "figure.walk.motion", category: .walk, tone: .apricot, isCompleted: true),
            RoutineItem(id: UUID(uuidString: "BBBBBBBB-CCCC-DDDD-EEEE-000000000002")!, petID: previewLumiID, title: "Puzzle breakfast", subtitle: "Softened kibble in the slow puzzle tray.", day: .tuesday, time: ClockTime(hour: 8, minute: 0), durationMinutes: 16, systemImage: "puzzlepiece.extension.fill", category: .meal, tone: .lagoon, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "BBBBBBBB-CCCC-DDDD-EEEE-000000000003")!, petID: previewLumiID, title: "Harness happy reps", subtitle: "Three tiny sessions with treats before clipping the harness.", day: .wednesday, time: ClockTime(hour: 18, minute: 10), durationMinutes: 12, systemImage: "checkmark.seal.fill", category: .training, tone: .meadow, isCompleted: true),
            RoutineItem(id: UUID(uuidString: "BBBBBBBB-CCCC-DDDD-EEEE-000000000004")!, petID: previewLumiID, title: "Friday balcony sniff", subtitle: "Low-stimulation fresh-air pause before visitor sounds start.", day: .friday, time: ClockTime(hour: 17, minute: 10), durationMinutes: 15, systemImage: "leaf.fill", category: .care, tone: .meadow, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "BBBBBBBB-CCCC-DDDD-EEEE-000000000005")!, petID: previewLumiID, title: "Visitor greeting script", subtitle: "Mat, treat scatter, and one calm hello before cuddles.", day: .friday, time: ClockTime(hour: 19, minute: 0), durationMinutes: 20, systemImage: "person.2.fill", category: .training, tone: .twilight, isCompleted: false),
            RoutineItem(id: UUID(uuidString: "BBBBBBBB-CCCC-DDDD-EEEE-000000000006")!, petID: previewLumiID, title: "Sunday blanket reset", subtitle: "Wash travel blanket and refill the tiny treat pouch.", day: .sunday, time: ClockTime(hour: 11, minute: 15), durationMinutes: 22, systemImage: "washer.fill", category: .care, tone: .lagoon, isCompleted: false),
        ],
        memories: [
            MemoryMoment(
                petID: previewSolID,
                title: "Gotcha Day",
                date: date(2021, 4, 18),
                caption: "The day Sol fell asleep in Maya’s lap on the way home.",
                detail: "A quiet car ride turned into the first of a hundred tiny rituals. This anniversary is 21 days away.",
                systemImage: "heart.circle.fill",
                tone: .apricot,
                isAnnualCelebration: true
            ),
            MemoryMoment(
                petID: previewSolID,
                title: "Birthday picnic",
                date: date(2021, 5, 9),
                caption: "Blueberries, a tiny hat, and wind at Crissy Field.",
                detail: "Build this into a yearly slideshow with old clips, vet growth notes, and favorite treats.",
                systemImage: "birthday.cake.fill",
                tone: .lagoon,
                isAnnualCelebration: true
            ),
            MemoryMoment(
                petID: previewSolID,
                title: "The first beach sprint",
                date: date(2025, 8, 14),
                caption: "Seven perfect minutes of fearless zoomies by the water.",
                detail: "AuriTails turns moments like this into calm, cinematic keepsakes instead of burying them in the camera roll.",
                systemImage: "sparkles.rectangle.stack.fill",
                tone: .twilight,
                isAnnualCelebration: false
            ),
            MemoryMoment(
                petID: previewSolID,
                title: "Brave at the dentist",
                date: date(2025, 7, 18),
                caption: "Still asked politely for yogurt drops after the appointment.",
                detail: "Medical milestones should feel human too. This one lives next to the clinical notes and the happy photo.",
                systemImage: "cross.vial.fill",
                tone: .meadow,
                isAnnualCelebration: false
            ),
            MemoryMoment(
                petID: previewSolID,
                title: "Rainy window nap",
                date: date(2025, 12, 3),
                caption: "The first day Sol chose the travel blanket all on his own.",
                detail: "A simple home ritual that now marks whenever the family needs a low-stimulation reset evening.",
                systemImage: "cloud.drizzle.fill",
                tone: .lagoon,
                isAnnualCelebration: false
            ),
            MemoryMoment(
                petID: previewLumiID,
                title: "Lumi's first brave step",
                date: date(2026, 1, 22),
                caption: "One paw onto the lobby tile, then a proud look back.",
                detail: "A tiny confidence moment that became the first marker in Lumi's relationship story.",
                systemImage: "pawprint.circle.fill",
                tone: .meadow,
                isAnnualCelebration: false
            ),
            MemoryMoment(
                petID: previewLumiID,
                title: "Pocket picnic",
                date: date(2026, 3, 16),
                caption: "A sunny bench, minnow treats, and a blanket that made the city feel smaller.",
                detail: "Short outings are still outings. Lumi's best memories happen when the world is introduced gently.",
                systemImage: "sun.max.circle.fill",
                tone: .apricot,
                isAnnualCelebration: false
            ),
            MemoryMoment(
                petID: previewLumiID,
                title: "Adoption day",
                date: date(2026, 1, 19),
                caption: "The day Lumi came home wrapped in the blue travel blanket.",
                detail: "A yearly celebration for the tiny cat who made every routine feel more intentional.",
                systemImage: "heart.circle.fill",
                tone: .twilight,
                isAnnualCelebration: true
            ),
        ],
        careCircleMembers: [
            CareCircleMember(
                name: "Arjun",
                contact: "arjun@auritails.demo",
                relationshipLabel: "Weekend walker",
                role: .caregiver,
                status: .active,
                note: "Usually handles Saturday trail loops and pickup after daycare.",
                invitedAt: date(2026, 3, 20)
            ),
            CareCircleMember(
                name: "Ria",
                contact: "ria@auritails.demo",
                relationshipLabel: "Vet-day backup",
                role: .caregiver,
                status: .invited,
                note: "Ready to help with appointments and evening medication check-ins.",
                invitedAt: date(2026, 4, 2)
            ),
        ],
        careActivityEvents: [
            CareActivityEvent(
                title: "Arjun completed the harbor trail loop",
                detail: "Saturday walk was marked done, and Sol came back calm enough for an easy evening.",
                createdAt: dateTime(2026, 4, 4, 11, 20),
                systemImage: "figure.walk.motion",
                tone: .lagoon
            ),
            CareActivityEvent(
                title: "Ria was invited to Sol's circle",
                detail: "Invite prepared for vet-day backup and medication support.",
                createdAt: dateTime(2026, 4, 2, 9, 15),
                systemImage: "person.badge.plus",
                tone: .twilight
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
