import Foundation

enum RootTab: String, CaseIterable, Identifiable {
    case dashboard
    case wellness
    case routines
    case memories

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Home"
        case .wellness: "Wellness"
        case .routines: "Routines"
        case .memories: "Memories"
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
        switch self {
        case .dashboard:
            return "Life with \(petName)"
        case .wellness:
            return "Wellness Passport"
        case .routines:
            return "Ritual Planner"
        case .memories:
            return "Memory Studio"
        }
    }

    func headerSubtitle(ownerName: String, petName: String) -> String {
        switch self {
        case .dashboard:
            return "A calmer, more beautiful rhythm for \(ownerName) and \(petName)."
        case .wellness:
            return "Vaccines, notes, food rituals, and the tiny details that matter."
        case .routines:
            return "Shape a week of walks, care, enrichment, and flexible re-schedules."
        case .memories:
            return "Keep birthdays, gotcha days, and golden-hour moments in one place."
        }
    }
}

enum AppSheet: String, Identifiable {
    case ai
    case profile

    var id: String { rawValue }
}

enum Weekday: Int, CaseIterable, Identifiable {
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
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        case .sunday: "Sun"
        }
    }

    var title: String {
        switch self {
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        case .sunday: "Sunday"
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

struct ClockTime: Hashable, Comparable {
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

enum PaletteTone: String, CaseIterable, Identifiable {
    case apricot
    case meadow
    case lagoon
    case twilight

    var id: String { rawValue }
}

enum RoutineCategory: String {
    case walk
    case meal
    case training
    case care
    case play
}

enum InsightPriority: String {
    case steady
    case watch
    case celebrate
}

struct OwnerProfile: Identifiable {
    let id = UUID()
    var name: String
    var headline: String
    var location: String
    var note: String
}

struct PetProfile: Identifiable {
    let id = UUID()
    var name: String
    var species: String
    var breed: String
    var ageDescription: String
    var weightDescription: String
    var favoriteTreat: String
    var bondStatement: String
    var energySummary: String
}

struct BehaviorSnapshot: Identifiable {
    var id: Weekday { day }
    let day: Weekday
    let energy: Double
    let calmness: Double
    let appetite: Double
    let sleepHours: Double
}

struct VaccineRecord: Identifiable {
    let id = UUID()
    let title: String
    let lastGiven: String
    let nextDue: String
    let status: String
    let note: String
}

struct MedicalEntry: Identifiable {
    let id = UUID()
    let title: String
    let dateLabel: String
    let summary: String
    let clinician: String
    let tone: PaletteTone
}

struct FoodPreference: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

struct RoutineItem: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    var day: Weekday
    var time: ClockTime
    let durationMinutes: Int
    let systemImage: String
    let category: RoutineCategory
    let tone: PaletteTone
    var isCompleted: Bool

    var durationLabel: String {
        "\(durationMinutes) min"
    }
}

struct MemoryMoment: Identifiable {
    let id = UUID()
    let title: String
    let dateLabel: String
    let caption: String
    let detail: String
    let systemImage: String
    let tone: PaletteTone
    let daysUntilNextCelebration: Int?
}

struct CompanionInsight: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let suggestedAction: String
    let priority: InsightPriority
    let systemImage: String
}

struct AppSeed {
    let owner: OwnerProfile
    let pet: PetProfile
    let behaviorSnapshots: [BehaviorSnapshot]
    let vaccinations: [VaccineRecord]
    let medicalHistory: [MedicalEntry]
    let foodPreferences: [FoodPreference]
    let routines: [RoutineItem]
    let memories: [MemoryMoment]

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
            BehaviorSnapshot(day: .tuesday, energy: 0.88, calmness: 0.7, appetite: 0.9, sleepHours: 11.3),
            BehaviorSnapshot(day: .wednesday, energy: 0.79, calmness: 0.85, appetite: 0.96, sleepHours: 12.4),
            BehaviorSnapshot(day: .thursday, energy: 0.91, calmness: 0.68, appetite: 0.89, sleepHours: 10.9),
            BehaviorSnapshot(day: .friday, energy: 0.75, calmness: 0.88, appetite: 0.97, sleepHours: 12.7),
            BehaviorSnapshot(day: .saturday, energy: 0.93, calmness: 0.73, appetite: 0.92, sleepHours: 11.2),
            BehaviorSnapshot(day: .sunday, energy: 0.74, calmness: 0.9, appetite: 0.98, sleepHours: 13.0),
        ],
        vaccinations: [
            VaccineRecord(title: "Rabies", lastGiven: "Jan 12, 2025", nextDue: "Jan 12, 2028", status: "Covered", note: "Three-year booster complete."),
            VaccineRecord(title: "DHPP", lastGiven: "Feb 08, 2026", nextDue: "Feb 08, 2027", status: "On track", note: "Annual booster logged with no reactions."),
            VaccineRecord(title: "Bordetella", lastGiven: "Mar 02, 2026", nextDue: "Sep 02, 2026", status: "Watch", note: "Needed before boarding and social daycare."),
            VaccineRecord(title: "Leptospirosis", lastGiven: "Feb 08, 2026", nextDue: "Feb 08, 2027", status: "On track", note: "Tracked because of weekend trail exposure."),
        ],
        medicalHistory: [
            MedicalEntry(
                title: "Annual wellness exam",
                dateLabel: "Feb 8, 2026",
                summary: "Heart, joints, and coat all looked strong. Vet suggested keeping recovery days after intense play.",
                clinician: "Dr. Rivera",
                tone: .lagoon
            ),
            MedicalEntry(
                title: "Seasonal allergy flare",
                dateLabel: "Nov 3, 2025",
                summary: "Mild paw licking after park grass exposure. Added oat rinse and a post-walk wipe routine.",
                clinician: "Dr. Rivera",
                tone: .apricot
            ),
            MedicalEntry(
                title: "Dental polish visit",
                dateLabel: "Jul 18, 2025",
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
                dateLabel: "April 18",
                caption: "The day Sol fell asleep in Maya’s lap on the way home.",
                detail: "A quiet car ride turned into the first of a hundred tiny rituals. This anniversary is 21 days away.",
                systemImage: "heart.circle.fill",
                tone: .apricot,
                daysUntilNextCelebration: 21
            ),
            MemoryMoment(
                title: "Birthday picnic",
                dateLabel: "May 9",
                caption: "Blueberries, a tiny hat, and wind at Crissy Field.",
                detail: "Build this into a yearly slideshow with old clips, vet growth notes, and favorite treats.",
                systemImage: "birthday.cake.fill",
                tone: .lagoon,
                daysUntilNextCelebration: 42
            ),
            MemoryMoment(
                title: "The first beach sprint",
                dateLabel: "August 14, 2025",
                caption: "Seven perfect minutes of fearless zoomies by the water.",
                detail: "AuriTails turns moments like this into calm, cinematic keepsakes instead of burying them in the camera roll.",
                systemImage: "sparkles.rectangle.stack.fill",
                tone: .twilight,
                daysUntilNextCelebration: nil
            ),
            MemoryMoment(
                title: "Brave at the dentist",
                dateLabel: "July 18, 2025",
                caption: "Still asked politely for yogurt drops after the appointment.",
                detail: "Medical milestones should feel human too. This one lives next to the clinical notes and the happy photo.",
                systemImage: "cross.vial.fill",
                tone: .meadow,
                daysUntilNextCelebration: nil
            ),
            MemoryMoment(
                title: "Rainy window nap",
                dateLabel: "December 3, 2025",
                caption: "The first day Sol chose the travel blanket all on his own.",
                detail: "A simple home ritual that now marks whenever the family needs a low-stimulation reset evening.",
                systemImage: "cloud.drizzle.fill",
                tone: .lagoon,
                daysUntilNextCelebration: nil
            ),
        ]
    )
}
