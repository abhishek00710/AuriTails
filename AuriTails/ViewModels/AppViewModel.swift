import Combine
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var selectedTab: RootTab { didSet { persist() } }
    @Published var selectedDay: Weekday { didSet { persist() } }
    @Published var isMenuPresented = false
    @Published var activeSheet: AppSheet?
    @Published var owner: OwnerProfile { didSet { persist() } }
    @Published var pet: PetProfile { didSet { persist() } }
    @Published var notificationPreferences: NotificationPreferences { didSet { persist() } }
    @Published var ownerPhotoData: Data? { didSet { persist() } }
    @Published var petPhotoData: Data? { didSet { persist() } }
    @Published var bondPhotoData: Data? { didSet { persist() } }
    @Published var behaviorSnapshots: [BehaviorSnapshot] { didSet { persist() } }
    @Published var vaccinations: [VaccineRecord] { didSet { persist() } }
    @Published var medicalHistory: [MedicalEntry] { didSet { persist() } }
    @Published var foodPreferences: [FoodPreference] { didSet { persist() } }
    @Published var routines: [RoutineItem] { didSet { persist() } }
    @Published var memories: [MemoryMoment] { didSet { persist() } }
    @Published var onboardingFocus: OnboardingFocus { didSet { persist() } }
    @Published var hasCompletedOnboarding: Bool { didSet { persist() } }

    private let store: AppStateStore
    private let insightEngine: PetInsightEngine
    private let notificationScheduler: NotificationScheduler

    init(
        seed: AppSeed,
        store: AppStateStore = AppStateStore(),
        insightEngine: PetInsightEngine? = nil,
        notificationScheduler: NotificationScheduler = NotificationScheduler(),
        prefersPersistedState: Bool = true
    ) {
        let initialState = prefersPersistedState ? (store.load() ?? PersistedAppState(seed: seed)) : PersistedAppState(seed: seed)

        selectedTab = initialState.selectedTab
        selectedDay = initialState.selectedDay
        owner = initialState.owner
        pet = initialState.pet
        notificationPreferences = initialState.notificationPreferences
        ownerPhotoData = initialState.ownerPhotoData
        petPhotoData = initialState.petPhotoData
        bondPhotoData = initialState.bondPhotoData
        behaviorSnapshots = initialState.behaviorSnapshots
        vaccinations = initialState.vaccinations
        medicalHistory = initialState.medicalHistory
        foodPreferences = initialState.foodPreferences
        routines = initialState.routines
        memories = initialState.memories
        onboardingFocus = initialState.onboardingFocus
        hasCompletedOnboarding = initialState.hasCompletedOnboarding
        self.store = store
        self.insightEngine = insightEngine ?? PetInsightEngine()
        self.notificationScheduler = notificationScheduler

        Task {
            await notificationScheduler.requestAuthorizationIfNeeded()
            await notificationScheduler.refreshNotifications(for: snapshotState())
        }
    }

    @MainActor static func preview() async -> AppViewModel {
        let store = await MainActor.run { AppStateStore(inMemory: true) }
        return AppViewModel(
            seed: .preview,
            store: store,
            prefersPersistedState: false
        )
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
        memories.sorted { lhs, rhs in
            let lhsCelebration = lhs.daysUntilNextCelebration ?? .max
            let rhsCelebration = rhs.daysUntilNextCelebration ?? .max

            if lhsCelebration != rhsCelebration {
                return lhsCelebration < rhsCelebration
            }

            return lhs.date > rhs.date
        }
    }

    var memoryTimeline: [MemoryMoment] {
        memories.sorted { lhs, rhs in
            if lhs.isAnnualCelebration != rhs.isAnnualCelebration {
                return lhs.isAnnualCelebration && !rhs.isAnnualCelebration
            }

            if let lhsCelebration = lhs.daysUntilNextCelebration,
               let rhsCelebration = rhs.daysUntilNextCelebration,
               lhsCelebration != rhsCelebration
            {
                return lhsCelebration < rhsCelebration
            }

            return lhs.date > rhs.date
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
        upcomingWellnessRecord?.note ?? "No urgent health paperwork waiting."
    }

    var upcomingWellnessTitle: String {
        upcomingWellnessRecord?.title ?? "All clear"
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

    func selectDay(_ day: Weekday) {
        selectedDay = day
    }

    func openAI() {
        closeMenu()
        activeSheet = .ai
    }

    func openProfile() {
        closeMenu()
        activeSheet = .profile
    }

    func openNotificationSettings() {
        closeMenu()
        activeSheet = .notificationSettings
    }

    func openRoutineEditor(_ routineID: UUID? = nil) {
        activeSheet = .routineEditor(routineID)
    }

    func openMemoryEditor(_ memoryID: UUID? = nil) {
        activeSheet = .memoryEditor(memoryID)
    }

    func openVaccineEditor(_ vaccineID: UUID? = nil) {
        activeSheet = .vaccineEditor(vaccineID)
    }

    func openMedicalEntryEditor(_ entryID: UUID? = nil) {
        activeSheet = .medicalEntryEditor(entryID)
    }

    func openFoodPreferenceEditor(_ preferenceID: UUID? = nil) {
        activeSheet = .foodPreferenceEditor(preferenceID)
    }

    func updateProfile(owner: OwnerProfile, pet: PetProfile, ownerPhotoData: Data?, petPhotoData: Data?, bondPhotoData: Data?) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
            self.owner = owner
            self.pet = pet
            self.ownerPhotoData = ownerPhotoData
            self.petPhotoData = petPhotoData
            self.bondPhotoData = bondPhotoData
        }
    }

    func completeOnboarding(owner: OwnerProfile, pet: PetProfile, focus: OnboardingFocus) {
        onboardingFocus = focus
        updateProfile(
            owner: owner,
            pet: pet,
            ownerPhotoData: ownerPhotoData,
            petPhotoData: petPhotoData,
            bondPhotoData: bondPhotoData
        )
        selectedTab = focus.preferredTab
        hasCompletedOnboarding = true
    }

    func toggleRoutine(_ routineID: UUID) {
        guard let index = routines.firstIndex(where: { $0.id == routineID }) else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            routines[index].isCompleted.toggle()
        }
    }

    func toggleRoutineNotifications(_ routineID: UUID) {
        guard let index = routines.firstIndex(where: { $0.id == routineID }) else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            routines[index].notificationsEnabled.toggle()
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
            sortRoutines()
        }
    }

    func routine(for id: UUID?) -> RoutineItem? {
        guard let id else { return nil }
        return routines.first(where: { $0.id == id })
    }

    func saveRoutine(_ routine: RoutineItem) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            if let index = routines.firstIndex(where: { $0.id == routine.id }) {
                routines[index] = routine
            } else {
                routines.append(routine)
            }
            sortRoutines()
            selectedDay = routine.day
        }
    }

    func deleteRoutine(_ routineID: UUID) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            routines.removeAll { $0.id == routineID }
        }
    }

    func memory(for id: UUID?) -> MemoryMoment? {
        guard let id else { return nil }
        return memories.first(where: { $0.id == id })
    }

    func saveMemory(_ memory: MemoryMoment) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            if let index = memories.firstIndex(where: { $0.id == memory.id }) {
                memories[index] = memory
            } else {
                memories.append(memory)
            }
            sortMemories()
        }
    }

    func toggleMemoryNotifications(_ memoryID: UUID) {
        guard let index = memories.firstIndex(where: { $0.id == memoryID }) else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            memories[index].notificationsEnabled.toggle()
        }
    }

    func deleteMemory(_ memoryID: UUID) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            memories.removeAll { $0.id == memoryID }
        }
    }

    func vaccine(for id: UUID?) -> VaccineRecord? {
        guard let id else { return nil }
        return vaccinations.first(where: { $0.id == id })
    }

    func saveVaccine(_ vaccine: VaccineRecord) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            if let index = vaccinations.firstIndex(where: { $0.id == vaccine.id }) {
                vaccinations[index] = vaccine
            } else {
                vaccinations.append(vaccine)
            }
            vaccinations.sort { $0.nextDue < $1.nextDue }
        }
    }

    func toggleVaccineNotifications(_ vaccineID: UUID) {
        guard let index = vaccinations.firstIndex(where: { $0.id == vaccineID }) else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            vaccinations[index].notificationsEnabled.toggle()
        }
    }

    func deleteVaccine(_ vaccineID: UUID) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            vaccinations.removeAll { $0.id == vaccineID }
        }
    }

    func medicalEntry(for id: UUID?) -> MedicalEntry? {
        guard let id else { return nil }
        return medicalHistory.first(where: { $0.id == id })
    }

    func saveMedicalEntry(_ entry: MedicalEntry) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            if let index = medicalHistory.firstIndex(where: { $0.id == entry.id }) {
                medicalHistory[index] = entry
            } else {
                medicalHistory.append(entry)
            }
            medicalHistory.sort { $0.date > $1.date }
        }
    }

    func deleteMedicalEntry(_ entryID: UUID) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            medicalHistory.removeAll { $0.id == entryID }
        }
    }

    func foodPreference(for id: UUID?) -> FoodPreference? {
        guard let id else { return nil }
        return foodPreferences.first(where: { $0.id == id })
    }

    func saveFoodPreference(_ preference: FoodPreference) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            if let index = foodPreferences.firstIndex(where: { $0.id == preference.id }) {
                foodPreferences[index] = preference
            } else {
                foodPreferences.append(preference)
            }
            foodPreferences.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }

    func deleteFoodPreference(_ preferenceID: UUID) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            foodPreferences.removeAll { $0.id == preferenceID }
        }
    }

    private var upcomingWellnessRecord: VaccineRecord? {
        vaccinations.sorted { lhs, rhs in
            let lhsRank = priority(for: lhs.status)
            let rhsRank = priority(for: rhs.status)

            if lhsRank != rhsRank {
                return lhsRank < rhsRank
            }
            return lhs.nextDue < rhs.nextDue
        }.first
    }

    private func priority(for status: VaccineStatus) -> Int {
        switch status {
        case .watch: 0
        case .onTrack: 1
        case .covered: 2
        }
    }

    private func sortRoutines() {
        routines.sort {
            if $0.day.rawValue != $1.day.rawValue {
                return $0.day.rawValue < $1.day.rawValue
            }
            return $0.time < $1.time
        }
    }

    private func sortMemories() {
        memories.sort { lhs, rhs in
            if lhs.isAnnualCelebration != rhs.isAnnualCelebration {
                return lhs.isAnnualCelebration && !rhs.isAnnualCelebration
            }

            if let lhsCelebration = lhs.daysUntilNextCelebration,
               let rhsCelebration = rhs.daysUntilNextCelebration,
               lhsCelebration != rhsCelebration
            {
                return lhsCelebration < rhsCelebration
            }

            return lhs.date > rhs.date
        }
    }

    private func persist() {
        let state = snapshotState()
        store.save(state)
        Task {
            await notificationScheduler.refreshNotifications(for: state)
        }
    }

    private func snapshotState() -> PersistedAppState {
        PersistedAppState(
            selectedTab: selectedTab,
            selectedDay: selectedDay,
            owner: owner,
            pet: pet,
            notificationPreferences: notificationPreferences,
            ownerPhotoData: ownerPhotoData,
            petPhotoData: petPhotoData,
            bondPhotoData: bondPhotoData,
            behaviorSnapshots: behaviorSnapshots,
            vaccinations: vaccinations,
            medicalHistory: medicalHistory,
            foodPreferences: foodPreferences,
            routines: routines,
            memories: memories,
            onboardingFocus: onboardingFocus,
            hasCompletedOnboarding: hasCompletedOnboarding
        )
    }
}

private extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
