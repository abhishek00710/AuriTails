import Combine
import MapKit
import SwiftUI
import UIKit
import VisionKit

@MainActor
final class AppViewModel: ObservableObject {
    struct BackupNotice: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    struct SharePayload: Identifiable {
        let id = UUID()
        let items: [Any]
    }

    @Published var selectedTab: RootTab { didSet { persistIfNeeded() } }
    @Published var selectedDay: Weekday { didSet { persistIfNeeded() } }
    @Published var isMenuPresented = false
    @Published var activeSheet: AppSheet?
    @Published var owner: OwnerProfile { didSet { persistIfNeeded() } }
    @Published var pet: PetProfile { didSet { persistIfNeeded() } }
    @Published var notificationPreferences: NotificationPreferences { didSet { persistIfNeeded() } }
    @Published var ownerPhotoData: Data? { didSet { persistIfNeeded() } }
    @Published var petPhotoData: Data? { didSet { persistIfNeeded() } }
    @Published var bondPhotoData: Data? { didSet { persistIfNeeded() } }
    @Published var behaviorSnapshots: [BehaviorSnapshot] { didSet { persistIfNeeded() } }
    @Published var weightEntries: [WeightEntry] { didSet { persistIfNeeded() } }
    @Published var vaccinations: [VaccineRecord] { didSet { persistIfNeeded() } }
    @Published var medications: [MedicationRecord] { didSet { persistIfNeeded() } }
    @Published var symptoms: [SymptomEntry] { didSet { persistIfNeeded() } }
    @Published var medicalHistory: [MedicalEntry] { didSet { persistIfNeeded() } }
    @Published var foodPreferences: [FoodPreference] { didSet { persistIfNeeded() } }
    @Published var routines: [RoutineItem] { didSet { persistIfNeeded() } }
    @Published var memories: [MemoryMoment] { didSet { persistIfNeeded() } }
    @Published var careCircleMembers: [CareCircleMember] { didSet { persistIfNeeded() } }
    @Published var careActivityEvents: [CareActivityEvent] { didSet { persistIfNeeded() } }
    @Published var onboardingFocus: OnboardingFocus { didSet { persistIfNeeded() } }
    @Published var hasCompletedOnboarding: Bool { didSet { persistIfNeeded() } }
    @Published var exportBackupDocument: AppBackupDocument?
    @Published var isExportingBackup = false
    @Published var isImportingBackup = false
    @Published var isImportingVaccineDocument = false
    @Published var isShowingVaccineScanner = false
    @Published var backupNotice: BackupNotice?
    @Published var sharePayload: SharePayload?
    @Published var vaccineEditorSeed: VaccineRecord?
    @Published private(set) var nearbyPetCare: [PetCarePlace] = []
    @Published private(set) var isLoadingNearbyPetCare = false
    @Published private(set) var nearbyPetCareStatusMessage = L10n.tr(
        "Find nearby pet hospitals and emergency care around you.",
        default: "Find nearby pet hospitals and emergency care around you."
    )

    private let store: AppStateStore
    private let insightEngine: PetInsightEngine
    private let notificationScheduler: NotificationScheduler
    private let nearbyPetCareService: NearbyPetCareService
    private let vetVisitPackBuilder = VetVisitPackBuilder()
    private let vaccineDocumentImportService = VaccineDocumentImportService()
    private var isApplyingState = false
    private var cancellables = Set<AnyCancellable>()

    init(
        seed: AppSeed,
        store: AppStateStore = AppStateStore(),
        insightEngine: PetInsightEngine? = nil,
        notificationScheduler: NotificationScheduler = NotificationScheduler(),
        nearbyPetCareService: NearbyPetCareService? = nil,
        prefersPersistedState: Bool = true
    ) {
        let initialState = prefersPersistedState ? (store.load() ?? PersistedAppState(seed: seed)) : PersistedAppState(seed: seed)
        let nearbyPetCareService = nearbyPetCareService ?? NearbyPetCareService()

        selectedTab = initialState.selectedTab
        selectedDay = initialState.selectedDay
        owner = initialState.owner
        pet = initialState.pet
        notificationPreferences = initialState.notificationPreferences
        ownerPhotoData = initialState.ownerPhotoData
        petPhotoData = initialState.petPhotoData
        bondPhotoData = initialState.bondPhotoData
        behaviorSnapshots = initialState.behaviorSnapshots
        weightEntries = initialState.weightEntries
        vaccinations = initialState.vaccinations
        medications = initialState.medications
        symptoms = initialState.symptoms
        medicalHistory = initialState.medicalHistory
        foodPreferences = initialState.foodPreferences
        routines = initialState.routines
        memories = initialState.memories
        careCircleMembers = initialState.careCircleMembers
        careActivityEvents = initialState.careActivityEvents
        onboardingFocus = initialState.onboardingFocus
        hasCompletedOnboarding = initialState.hasCompletedOnboarding
        self.store = store
        self.insightEngine = insightEngine ?? PetInsightEngine()
        self.notificationScheduler = notificationScheduler
        self.nearbyPetCareService = nearbyPetCareService

        nearbyPetCareService.$places
            .sink { [weak self] in self?.nearbyPetCare = $0 }
            .store(in: &cancellables)

        nearbyPetCareService.$isLoading
            .sink { [weak self] in self?.isLoadingNearbyPetCare = $0 }
            .store(in: &cancellables)

        nearbyPetCareService.$statusMessage
            .sink { [weak self] in self?.nearbyPetCareStatusMessage = $0 }
            .store(in: &cancellables)

        Task {
            await notificationScheduler.requestAuthorizationIfNeeded()
            await notificationScheduler.refreshNotifications(for: snapshotState())
        }

        nearbyPetCareService.refresh()
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
            medications: medications,
            symptoms: symptoms,
            pet: pet
        )
    }

    var displayOwnerName: String {
        owner.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? L10n.tr("Pet Parent", default: "Pet Parent")
        : owner.name
    }

    var displayPetName: String {
        pet.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? L10n.tr("Your Pet", default: "Your Pet")
        : pet.name
    }

    var todayBehaviorSnapshot: BehaviorSnapshot? {
        behaviorSnapshots.first(where: { $0.day == .current })
    }

    var latestWeightEntry: WeightEntry? {
        weightEntries.sorted { $0.loggedAt > $1.loggedAt }.first
    }

    var preferredWeightUnit: WeightUnit {
        latestWeightEntry?.unit ?? .kilograms
    }

    var recentWeightEntries: [WeightEntry] {
        weightEntries.sorted { $0.loggedAt < $1.loggedAt }
    }

    var hasBehaviorData: Bool { !behaviorSnapshots.isEmpty }
    var hasWeightData: Bool { !weightEntries.isEmpty }
    var hasRoutineData: Bool { !routines.isEmpty }
    var hasMemoryData: Bool { !memories.isEmpty }
    var hasVaccinationData: Bool { !vaccinations.isEmpty }
    var hasMedicationData: Bool { !medications.isEmpty }
    var hasSymptomData: Bool { !symptoms.isEmpty }
    var hasMedicalData: Bool { !medicalHistory.isEmpty }
    var hasFoodData: Bool { !foodPreferences.isEmpty }
    var activeCareCircleMembers: [CareCircleMember] { careCircleMembers.filter { $0.status == .active } }
    var invitedCareCircleMembers: [CareCircleMember] { careCircleMembers.filter { $0.status == .invited } }
    var totalCareCircleCount: Int { 1 + activeCareCircleMembers.count }
    var careCircleSummary: String {
        if activeCareCircleMembers.isEmpty {
            return L10n.tr("Just you so far. Invite one trusted caregiver to share routines, meds, and moments.", default: "Just you so far. Invite one trusted caregiver to share routines, meds, and moments.")
        }

        return L10n.format(
            "%d trusted caregiver%@ already inside %@'s circle.",
            default: "%d trusted caregiver%@ already inside %@'s circle.",
            activeCareCircleMembers.count,
            activeCareCircleMembers.count == 1 ? "" : "s",
            displayPetName
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
        upcomingWellnessRecord?.note ?? L10n.tr("No urgent health paperwork waiting.", default: "No urgent health paperwork waiting.")
    }

    var upcomingWellnessTitle: String {
        upcomingWellnessRecord?.title ?? L10n.tr("All clear", default: "All clear")
    }

    var nextMedication: MedicationRecord? {
        medications.sorted { $0.nextDose < $1.nextDose }.first
    }

    var recentSymptoms: [SymptomEntry] {
        symptoms.sorted { $0.observedAt > $1.observedAt }
    }

    var recentSymptomCounts: [(severity: SymptomSeverity, count: Int)] {
        SymptomSeverity.allCases.map { severity in
            (severity, symptoms.filter { $0.severity == severity }.count)
        }
    }

    var weightTrendSummary: String {
        guard let latestWeightEntry else {
            return L10n.tr("Add a few weigh-ins to start seeing gentle health movement over time.", default: "Add a few weigh-ins to start seeing gentle health movement over time.")
        }

        let ordered = recentWeightEntries
        guard let first = ordered.first, ordered.count > 1 else {
            return L10n.format("%@ is currently %@. One or two more weigh-ins will reveal whether that is holding steady.", default: "%@ is currently %@. One or two more weigh-ins will reveal whether that is holding steady.", displayPetName, latestWeightEntry.valueLabel)
        }

        let delta = latestWeightEntry.displayValue(in: preferredWeightUnit) - first.displayValue(in: preferredWeightUnit)
        let absoluteDelta = abs(delta).formatted(.number.precision(.fractionLength(1)))
        if abs(delta) < 0.15 {
            return L10n.format("%@ is holding fairly steady around %@, which makes the rest of the wellness picture easier to interpret.", default: "%@ is holding fairly steady around %@, which makes the rest of the wellness picture easier to interpret.", displayPetName, latestWeightEntry.valueLabel)
        }

        let direction = delta > 0
            ? L10n.tr("up", default: "up")
            : L10n.tr("down", default: "down")
        return L10n.format("%@ is trending %@ by %@ %@ across the logged weigh-ins.", default: "%@ is trending %@ by %@ %@ across the logged weigh-ins.", displayPetName, direction, absoluteDelta, preferredWeightUnit.shortLabel)
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
            if tab == .routines {
                selectedDay = .current
            }
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

    func openCareCircle() {
        closeMenu()
        activeSheet = .careCircle
    }

    func openNotificationSettings() {
        closeMenu()
        activeSheet = .notificationSettings
    }

    func openBehaviorCheckIn(_ day: Weekday? = nil) {
        activeSheet = .behaviorCheckInEditor(day)
    }

    func openWeightEntryEditor(_ entryID: UUID? = nil) {
        activeSheet = .weightEntryEditor(entryID)
    }

    func refreshNearbyPetCare() {
        nearbyPetCareService.refresh()
    }

    func openDirections(to place: PetCarePlace) {
        place.mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    func call(_ place: PetCarePlace) {
        guard let phoneNumber = place.phoneNumber else { return }
        let digits = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard let url = URL(string: "tel://\(digits)") else { return }
        UIApplication.shared.open(url)
    }

    func openAppShare() {
        closeMenu()
        sharePayload = SharePayload(items: [appShareMessage])
    }

    func openMemoryShare(_ memory: MemoryMoment) {
        var items: [Any] = []
        if let data = memory.photoData, let image = UIImage(data: data) {
            items.append(image)
        }
        items.append(shareMessage(for: memory))
        sharePayload = SharePayload(items: items)
    }

    func shareVetVisitPack() {
        do {
            let document = try vetVisitPackBuilder.makeDocument(
                owner: owner,
                pet: pet,
                vaccinations: vaccinations,
                medications: medications,
                symptoms: symptoms,
                medicalHistory: medicalHistory,
                foodPreferences: foodPreferences,
                routines: routines,
                bondPhotoData: bondPhotoData
            )
            sharePayload = SharePayload(items: [document.url])
        } catch {
            backupNotice = BackupNotice(
                title: L10n.tr("Vet Pack Failed", default: "Vet Pack Failed"),
                message: L10n.tr("AuriTails couldn't prepare the vet visit PDF right now.", default: "AuriTails couldn't prepare the vet visit PDF right now.")
            )
        }
    }

    func startVaccineScanner() {
        guard VNDocumentCameraViewController.isSupported else {
            backupNotice = BackupNotice(
                title: L10n.tr("Scanner Unavailable", default: "Scanner Unavailable"),
                message: L10n.tr("Document scanning isn't available on this device, but you can still import a file.", default: "Document scanning isn't available on this device, but you can still import a file.")
            )
            return
        }
        isShowingVaccineScanner = true
    }

    func cancelVaccineScanner() {
        isShowingVaccineScanner = false
    }

    func handleScannedVaccinePages(_ pages: [UIImage]) {
        isShowingVaccineScanner = false
        Task {
            guard let draft = await vaccineDocumentImportService.importFromScannedPages(pages) else {
                backupNotice = BackupNotice(
                    title: L10n.tr("Import Failed", default: "Import Failed"),
                    message: L10n.tr("AuriTails couldn't read enough vaccine detail from that scan.", default: "AuriTails couldn't read enough vaccine detail from that scan.")
                )
                return
            }
            openImportedVaccineEditor(draft)
        }
    }

    func importVaccineDocument() {
        isImportingVaccineDocument = true
    }

    func handleVaccineDocumentImport(result: Result<URL, Error>) {
        isImportingVaccineDocument = false

        guard case let .success(url) = result else {
            return
        }

        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        Task {
            guard let draft = await vaccineDocumentImportService.importFromFile(url: url) else {
                backupNotice = BackupNotice(
                    title: L10n.tr("Import Failed", default: "Import Failed"),
                    message: L10n.tr("That file couldn't be turned into a vaccine draft.", default: "That file couldn't be turned into a vaccine draft.")
                )
                return
            }
            openImportedVaccineEditor(draft)
        }
    }

    var appShareMessage: String {
        L10n.tr(
            "Check out AuriTails, the bond-first pet app for wellness, routines, memories, and gentle Bond Pulse insights.",
            default: "Check out AuriTails, the bond-first pet app for wellness, routines, memories, and gentle Bond Pulse insights."
        )
    }

    func shareMessage(for memory: MemoryMoment) -> String {
        if memory.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return L10n.format(
                "Memory from AuriTails\n%@\n%@\n%@",
                default: "Memory from AuriTails\n%@\n%@\n%@",
                memory.title,
                memory.dateLabel,
                memory.caption
            )
        }

        return L10n.format(
            "Memory from AuriTails\n%@\n%@\n%@\n\n%@",
            default: "Memory from AuriTails\n%@\n%@\n%@\n\n%@",
            memory.title,
            memory.dateLabel,
            memory.caption,
            memory.detail
        )
    }

    var backupFilename: String {
        L10n.tr("AuriTails-Backup", default: "AuriTails-Backup")
    }

    func exportBackup() {
        closeMenu()

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(snapshotState())
            exportBackupDocument = AppBackupDocument(data: data)
            isExportingBackup = true
        } catch {
            backupNotice = BackupNotice(
                title: L10n.tr("Backup Failed", default: "Backup Failed"),
                message: L10n.tr("AuriTails couldn't prepare the backup file. Please try again.", default: "AuriTails couldn't prepare the backup file. Please try again.")
            )
        }
    }

    func importBackup() {
        closeMenu()
        isImportingBackup = true
    }

    func handleBackupExport(result: Result<URL, Error>) {
        isExportingBackup = false
        exportBackupDocument = nil

        switch result {
        case .success:
            backupNotice = BackupNotice(
                title: L10n.tr("Backup Saved", default: "Backup Saved"),
                message: L10n.tr("Your AuriTails data was exported successfully.", default: "Your AuriTails data was exported successfully.")
            )
        case .failure:
            backupNotice = BackupNotice(
                title: L10n.tr("Backup Failed", default: "Backup Failed"),
                message: L10n.tr("AuriTails couldn't save the backup file.", default: "AuriTails couldn't save the backup file.")
            )
        }
    }

    func handleBackupImport(result: Result<URL, Error>) {
        isImportingBackup = false

        guard case let .success(url) = result else {
            backupNotice = BackupNotice(
                title: L10n.tr("Restore Cancelled", default: "Restore Cancelled"),
                message: L10n.tr("No backup file was imported.", default: "No backup file was imported.")
            )
            return
        }

        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let importedState = try decoder.decode(PersistedAppState.self, from: data)
            apply(state: importedState)
            backupNotice = BackupNotice(
                title: L10n.tr("Backup Restored", default: "Backup Restored"),
                message: L10n.tr("Your AuriTails data was restored from the selected backup.", default: "Your AuriTails data was restored from the selected backup.")
            )
        } catch {
            backupNotice = BackupNotice(
                title: L10n.tr("Restore Failed", default: "Restore Failed"),
                message: L10n.tr("That backup file couldn't be read by AuriTails.", default: "That backup file couldn't be read by AuriTails.")
            )
        }
    }

    func clearBackupNotice() {
        backupNotice = nil
    }

    func openRoutineEditor(_ routineID: UUID? = nil) {
        activeSheet = .routineEditor(routineID)
    }

    func openMemoryEditor(_ memoryID: UUID? = nil) {
        activeSheet = .memoryEditor(memoryID)
    }

    func openVaccineEditor(_ vaccineID: UUID? = nil) {
        if vaccineID == nil {
            vaccineEditorSeed = nil
        }
        activeSheet = .vaccineEditor(vaccineID)
    }

    func openMedicationEditor(_ medicationID: UUID? = nil) {
        activeSheet = .medicationEditor(medicationID)
    }

    func openSymptomEditor(_ symptomID: UUID? = nil) {
        activeSheet = .symptomEditor(symptomID)
    }

    func openImportedVaccineEditor(_ draft: VaccineRecord) {
        vaccineEditorSeed = draft
        activeSheet = .vaccineEditor(nil)
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

    func inviteCaregiver(name: String, contact: String, relationshipLabel: String, note: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let member = CareCircleMember(
            name: trimmedName,
            contact: contact.trimmingCharacters(in: .whitespacesAndNewlines),
            relationshipLabel: relationshipLabel.trimmingCharacters(in: .whitespacesAndNewlines),
            role: .caregiver,
            status: .invited,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            invitedAt: .now
        )

        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            careCircleMembers.append(member)
            sortCareCircleMembers()
            prependCareActivity(
                title: L10n.format("Invite prepared for %@", default: "Invite prepared for %@", trimmedName),
                detail: L10n.format("%@ can join %@'s shared care space as soon as the invite is accepted.", default: "%@ can join %@'s shared care space as soon as the invite is accepted.", trimmedName, displayPetName),
                systemImage: "person.badge.plus",
                tone: .twilight
            )
        }
    }

    func markCaregiverInviteAccepted(_ memberID: UUID) {
        guard let index = careCircleMembers.firstIndex(where: { $0.id == memberID }) else { return }
        guard careCircleMembers[index].status == .invited else { return }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            careCircleMembers[index].status = .active
            let memberName = careCircleMembers[index].name
            sortCareCircleMembers()
            prependCareActivity(
                title: L10n.format("%@ joined the Care Circle", default: "%@ joined the Care Circle", memberName),
                detail: L10n.format("%@ can now help with routines, wellness updates, and shared memory keeping for %@.", default: "%@ can now help with routines, wellness updates, and shared memory keeping for %@.", memberName, displayPetName),
                systemImage: "person.2.fill",
                tone: .meadow
            )
        }
    }

    func removeCareCircleMember(_ memberID: UUID) {
        guard let member = careCircleMembers.first(where: { $0.id == memberID }) else { return }

        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            careCircleMembers.removeAll { $0.id == memberID }
            prependCareActivity(
                title: L10n.format("%@ was removed from the circle", default: "%@ was removed from the circle", member.name),
                detail: L10n.format("%@'s shared space is back to %d trusted member%@.", default: "%@'s shared space is back to %d trusted member%@.", displayPetName, totalCareCircleCount, totalCareCircleCount == 1 ? "" : "s"),
                systemImage: "person.crop.circle.badge.minus",
                tone: .apricot
            )
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

    func enterDemoMode() {
        load(seed: .preview, onboardingCompleted: true)
    }

    func beginCleanSetup() {
        load(seed: .empty, onboardingCompleted: false)
    }

    func reopenOnboardingForDevelopment() {
        closeMenu()
        activeSheet = nil
        isShowingVaccineScanner = false
        isExportingBackup = false
        isImportingBackup = false
        isImportingVaccineDocument = false
        sharePayload = nil
        backupNotice = nil
        hasCompletedOnboarding = false
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

    func behaviorSnapshot(for day: Weekday?) -> BehaviorSnapshot? {
        let resolvedDay = day ?? .current
        return behaviorSnapshots.first(where: { $0.day == resolvedDay })
    }

    func saveBehaviorSnapshot(_ snapshot: BehaviorSnapshot) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            if let index = behaviorSnapshots.firstIndex(where: { $0.day == snapshot.day }) {
                behaviorSnapshots[index] = snapshot
            } else {
                behaviorSnapshots.append(snapshot)
            }
            behaviorSnapshots.sort { $0.day.rawValue < $1.day.rawValue }
        }
    }

    func deleteBehaviorSnapshot(for day: Weekday) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            behaviorSnapshots.removeAll { $0.day == day }
        }
    }

    func weightEntry(for id: UUID?) -> WeightEntry? {
        guard let id else { return nil }
        return weightEntries.first(where: { $0.id == id })
    }

    func saveWeightEntry(_ entry: WeightEntry) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            if let index = weightEntries.firstIndex(where: { $0.id == entry.id }) {
                weightEntries[index] = entry
            } else {
                weightEntries.append(entry)
            }
            weightEntries.sort { $0.loggedAt < $1.loggedAt }
        }
    }

    func deleteWeightEntry(_ entryID: UUID) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            weightEntries.removeAll { $0.id == entryID }
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
            vaccineEditorSeed = nil
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

    func medication(for id: UUID?) -> MedicationRecord? {
        guard let id else { return nil }
        return medications.first(where: { $0.id == id })
    }

    func saveMedication(_ medication: MedicationRecord) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            if let index = medications.firstIndex(where: { $0.id == medication.id }) {
                medications[index] = medication
            } else {
                medications.append(medication)
            }
            medications.sort { $0.nextDose < $1.nextDose }
        }
    }

    func toggleMedicationNotifications(_ medicationID: UUID) {
        guard let index = medications.firstIndex(where: { $0.id == medicationID }) else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            medications[index].notificationsEnabled.toggle()
        }
    }

    func deleteMedication(_ medicationID: UUID) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            medications.removeAll { $0.id == medicationID }
        }
    }

    func symptom(for id: UUID?) -> SymptomEntry? {
        guard let id else { return nil }
        return symptoms.first(where: { $0.id == id })
    }

    func saveSymptom(_ symptom: SymptomEntry) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            if let index = symptoms.firstIndex(where: { $0.id == symptom.id }) {
                symptoms[index] = symptom
            } else {
                symptoms.append(symptom)
            }
            symptoms.sort { $0.observedAt > $1.observedAt }
        }
    }

    func deleteSymptom(_ symptomID: UUID) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            symptoms.removeAll { $0.id == symptomID }
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

    private func persistIfNeeded() {
        guard !isApplyingState else { return }
        persist()
    }

    private func load(seed: AppSeed, onboardingCompleted: Bool) {
        let state = PersistedAppState(seed: seed)
        isApplyingState = true
        selectedTab = .dashboard
        selectedDay = .current
        owner = state.owner
        pet = state.pet
        notificationPreferences = state.notificationPreferences
        ownerPhotoData = nil
        petPhotoData = nil
        bondPhotoData = nil
        behaviorSnapshots = state.behaviorSnapshots
        weightEntries = state.weightEntries
        vaccinations = state.vaccinations
        medications = state.medications
        symptoms = state.symptoms
        medicalHistory = state.medicalHistory
        foodPreferences = state.foodPreferences
        routines = state.routines
        memories = state.memories
        careCircleMembers = state.careCircleMembers
        careActivityEvents = state.careActivityEvents
        onboardingFocus = .dashboard
        hasCompletedOnboarding = onboardingCompleted
        vaccineEditorSeed = nil
        isApplyingState = false
        persist()
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
            onboardingFocus: onboardingFocus,
            hasCompletedOnboarding: hasCompletedOnboarding
        )
    }

    private func apply(state: PersistedAppState) {
        isApplyingState = true
        selectedTab = state.selectedTab
        selectedDay = state.selectedDay
        owner = state.owner
        pet = state.pet
        notificationPreferences = state.notificationPreferences
        ownerPhotoData = state.ownerPhotoData
        petPhotoData = state.petPhotoData
        bondPhotoData = state.bondPhotoData
        behaviorSnapshots = state.behaviorSnapshots
        weightEntries = state.weightEntries
        vaccinations = state.vaccinations
        medications = state.medications
        symptoms = state.symptoms
        medicalHistory = state.medicalHistory
        foodPreferences = state.foodPreferences
        routines = state.routines
        memories = state.memories
        careCircleMembers = state.careCircleMembers
        careActivityEvents = state.careActivityEvents
        onboardingFocus = state.onboardingFocus
        hasCompletedOnboarding = state.hasCompletedOnboarding
        isApplyingState = false
        persist()
    }

    private func sortCareCircleMembers() {
        careCircleMembers.sort { lhs, rhs in
            if lhs.status != rhs.status {
                return lhs.status == .active
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private func prependCareActivity(title: String, detail: String, systemImage: String, tone: PaletteTone) {
        careActivityEvents.insert(
            CareActivityEvent(
                title: title,
                detail: detail,
                createdAt: .now,
                systemImage: systemImage,
                tone: tone
            ),
            at: 0
        )
        if careActivityEvents.count > 12 {
            careActivityEvents = Array(careActivityEvents.prefix(12))
        }
    }
}

private extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
