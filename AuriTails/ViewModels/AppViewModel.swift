import Combine
import SwiftUI

final class AppViewModel: ObservableObject {
    @Published var selectedTab: RootTab = .dashboard
    @Published var selectedDay: Weekday
    @Published var isMenuPresented = false
    @Published var activeSheet: AppSheet?
    @Published var owner: OwnerProfile
    @Published var pet: PetProfile
    @Published var ownerPhotoData: Data?
    @Published var petPhotoData: Data?
    @Published var routines: [RoutineItem]
    @Published var memories: [MemoryMoment]

    let behaviorSnapshots: [BehaviorSnapshot]
    let vaccinations: [VaccineRecord]
    let medicalHistory: [MedicalEntry]
    let foodPreferences: [FoodPreference]

    private let insightEngine: PetInsightEngine

    init(seed: AppSeed, insightEngine: PetInsightEngine = PetInsightEngine()) {
        owner = seed.owner
        pet = seed.pet
        ownerPhotoData = nil
        petPhotoData = nil
        behaviorSnapshots = seed.behaviorSnapshots
        vaccinations = seed.vaccinations
        medicalHistory = seed.medicalHistory
        foodPreferences = seed.foodPreferences
        routines = seed.routines
        memories = seed.memories
        selectedDay = Weekday.current
        self.insightEngine = insightEngine
    }

    static func preview() -> AppViewModel {
        AppViewModel(seed: .preview)
    }

    var insights: [CompanionInsight] {
        insightEngine.generateInsights(
            snapshots: behaviorSnapshots,
            routines: routines,
            foodPreferences: foodPreferences,
            pet: pet
        )
    }

    var selectedDayRoutines: [RoutineItem] {
        routines
            .filter { $0.day == selectedDay }
            .sorted { $0.time < $1.time }
    }

    var todaysRoutines: [RoutineItem] {
        routines
            .filter { $0.day == .current }
            .sorted { $0.time < $1.time }
    }

    var featuredMemories: [MemoryMoment] {
        memories.sorted {
            ($0.daysUntilNextCelebration ?? .max) < ($1.daysUntilNextCelebration ?? .max)
        }
    }

    var nextCelebration: MemoryMoment? {
        featuredMemories.first { $0.daysUntilNextCelebration != nil }
    }

    var weeklyCompletionRatio: Double {
        guard !routines.isEmpty else { return 0 }
        return Double(routines.filter(\.isCompleted).count) / Double(routines.count)
    }

    var bondScore: Int {
        let calm = behaviorSnapshots.map(\.calmness).average
        let appetite = behaviorSnapshots.map(\.appetite).average
        let completion = weeklyCompletionRatio
        let score = (calm * 34) + (appetite * 28) + (completion * 38)
        return Int(score.rounded())
    }

    var upcomingWellnessNote: String {
        vaccinations.first(where: { $0.status == "Watch" })?.note ?? "No urgent health paperwork waiting."
    }

    func toggleMenu() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
            isMenuPresented.toggle()
        }
    }

    func closeMenu() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
            isMenuPresented = false
        }
    }

    func selectTab(_ tab: RootTab) {
        withAnimation(.spring(response: 0.36, dampingFraction: 0.9)) {
            selectedTab = tab
            isMenuPresented = false
        }
    }

    func openAI() {
        closeMenu()
        activeSheet = .ai
    }

    func openProfile() {
        closeMenu()
        activeSheet = .profile
    }

    func updateProfile(owner: OwnerProfile, pet: PetProfile, ownerPhotoData: Data?, petPhotoData: Data?) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
            self.owner = owner
            self.pet = pet
            self.ownerPhotoData = ownerPhotoData
            self.petPhotoData = petPhotoData
        }
    }

    func toggleRoutine(_ routineID: UUID) {
        guard let index = routines.firstIndex(where: { $0.id == routineID }) else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            routines[index].isCompleted.toggle()
        }
    }

    func shiftRoutine(_ routineID: UUID, by minutes: Int) {
        guard let index = routines.firstIndex(where: { $0.id == routineID }) else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            routines[index].time = routines[index].time.shifted(by: minutes)
        }
    }

    func rescheduleRoutine(_ routineID: UUID, to day: Weekday) {
        guard let index = routines.firstIndex(where: { $0.id == routineID }) else { return }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            routines[index].day = day
            selectedDay = day
        }
    }
}

private extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
