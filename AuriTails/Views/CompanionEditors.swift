import PhotosUI
import SwiftUI

struct RoutineEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: RoutineItem
    @State private var showsDeleteAlert = false
    private let isNewRoutine: Bool

    init(viewModel: AppViewModel, routineID: UUID?) {
        self.viewModel = viewModel
        self.isNewRoutine = routineID == nil
        _draft = State(initialValue: viewModel.routine(for: routineID) ?? RoutineItem(
            title: "",
            subtitle: "",
            day: .current,
            time: ClockTime(hour: 8, minute: 0),
            durationMinutes: 30,
            systemImage: "sunrise.fill",
            category: .walk,
            tone: .apricot,
            isCompleted: false
        ))
    }

    var body: some View {
        EditorShell(
            title: draft.title.isEmpty ? L10n.tr("New Routine", default: "New Routine") : draft.title,
            saveLabel: L10n.tr("Save Routine", default: "Save Routine"),
            isSaveDisabled: draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            dismiss()
        } onSave: {
            viewModel.saveRoutine(draft)
            dismiss()
        } content: {
            GlassCard(tone: draft.tone) {
                SectionHeader(
                    eyebrow: "Routine",
                    title: "Build a flexible ritual",
                    detail: "Add a care moment the same way pet life actually works: editable, reschedulable, and calm."
                )

                EditorTextField(title: "Title", text: $draft.title, icon: "sparkles")
                EditorTextField(title: "Subtitle", text: $draft.subtitle, icon: "text.alignleft")

                HStack(spacing: 12) {
                    EditorEnumPicker(title: "Category", icon: "square.grid.2x2.fill", selection: $draft.category, options: RoutineCategory.allCases)
                    EditorEnumPicker(title: "Day", icon: "calendar", selection: $draft.day, options: Weekday.allCases)
                }

                ClockTimeEditor(title: "Time", time: $draft.time)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Duration", systemImage: "timer")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))

                    HStack(spacing: 12) {
                        Stepper(value: $draft.durationMinutes, in: 10...180, step: 5) {
                            Text("\(draft.durationMinutes) minutes")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .tint(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }

                SymbolPicker(
                    title: "Icon",
                    selection: $draft.systemImage,
                    options: EditorAssetOptions.routineSymbols
                )

                TonePicker(selection: $draft.tone)

                Toggle(isOn: $draft.isCompleted) {
                    Label("Mark as completed", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .tint(.white)
            }

            if viewModel.routine(for: draft.id) != nil {
                DeleteCard(label: "Delete Routine", icon: "trash.fill") {
                    showsDeleteAlert = true
                }
            }
        }
        .alert("Delete this routine?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteRoutine(draft.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the ritual from the weekly planner.")
        }
        .task {
            applyStarterIfNeeded(for: draft.category)
        }
        .onChange(of: draft.category) { _, newCategory in
            applyStarterIfNeeded(for: newCategory)
        }
    }

    private func applyStarterIfNeeded(for category: RoutineCategory) {
        guard isNewRoutine else { return }
        let starter = routineStarter(for: category)
        let titleIsEmpty = draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let subtitleIsEmpty = draft.subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isUsingDefaultWalkShell =
            draft.title.isEmpty &&
            draft.subtitle.isEmpty &&
            draft.systemImage == "sunrise.fill" &&
            draft.category == .walk

        guard titleIsEmpty || subtitleIsEmpty || isUsingDefaultWalkShell else { return }

        if titleIsEmpty || isUsingDefaultWalkShell {
            draft.title = starter.title
        }
        if subtitleIsEmpty || isUsingDefaultWalkShell {
            draft.subtitle = starter.subtitle
        }
        if draft.systemImage == "sunrise.fill" || isUsingDefaultWalkShell {
            draft.systemImage = starter.systemImage
        }
        if isUsingDefaultWalkShell || category == .grooming {
            draft.durationMinutes = starter.durationMinutes
            draft.tone = starter.tone
        }
    }

    private func routineStarter(for category: RoutineCategory) -> (title: String, subtitle: String, systemImage: String, durationMinutes: Int, tone: PaletteTone) {
        switch category {
        case .walk:
            return ("Morning walk", "A calm leash-led start to the day.", "sunrise.fill", 30, .apricot)
        case .meal:
            return ("Meal routine", "Food, water, and any easy supplements in one calm reset.", "carrot.fill", 20, .lagoon)
        case .training:
            return ("Training block", "A short skill session with one clear focus and reward.", "brain.head.profile", 25, .twilight)
        case .care:
            return ("Care check-in", "A simple health, comfort, or recovery moment.", "heart.text.square.fill", 20, .meadow)
        case .grooming:
            return ("Bath + brush", "Coat care, paw check, and a clean reset day.", "comb.fill", 35, .meadow)
        case .play:
            return ("Play session", "A high-energy release followed by a calmer wind-down.", "tennisball.fill", 30, .apricot)
        }
    }
}

struct MemoryEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: MemoryMoment
    @State private var showsDeleteAlert = false
    @State private var photoPickerItem: PhotosPickerItem?

    init(viewModel: AppViewModel, memoryID: UUID?) {
        self.viewModel = viewModel
        _draft = State(initialValue: viewModel.memory(for: memoryID) ?? MemoryMoment(
            title: "",
            date: .now,
            caption: "",
            detail: "",
            photoData: nil,
            systemImage: "heart.circle.fill",
            tone: .twilight,
            isAnnualCelebration: false
        ))
    }

    var body: some View {
        EditorShell(
            title: draft.title.isEmpty ? L10n.tr("New Memory", default: "New Memory") : draft.title,
            saveLabel: L10n.tr("Save Memory", default: "Save Memory"),
            isSaveDisabled: draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            dismiss()
        } onSave: {
            viewModel.saveMemory(draft)
            dismiss()
        } content: {
            GlassCard(tone: draft.tone) {
                SectionHeader(
                    eyebrow: "Memory",
                    title: "Capture the moment, not just the date",
                    detail: "Treat milestones like part of the relationship, with room for emotion and story."
                )

                EditorTextField(title: "Title", text: $draft.title, icon: "film.stack.fill")

                VStack(alignment: .leading, spacing: 10) {
                    Label("Date", systemImage: "calendar")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))

                    DatePicker(
                        "",
                        selection: $draft.date,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.graphical)
                    .tint(.white)
                    .padding(12)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }

                Toggle(isOn: $draft.isAnnualCelebration) {
                    Label("Repeat yearly", systemImage: "birthday.cake.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .tint(.white)

                AttachmentImageEditor(
                    imageData: $draft.photoData,
                    pickerItem: $photoPickerItem,
                    title: "Memory photo",
                    emptyMessage: "Add a photo to fill the memory postcard",
                    chooseLabel: "Choose Photo",
                    removeLabel: "Remove Photo",
                    placeholderIcon: "photo.stack.fill"
                )

                EditorTextField(title: "Caption", text: $draft.caption, icon: "quote.bubble.fill")
                EditorTextEditor(title: "Story", text: $draft.detail, icon: "text.book.closed.fill", height: 120)

                SymbolPicker(
                    title: "Moment icon",
                    selection: $draft.systemImage,
                    options: EditorAssetOptions.memorySymbols
                )

                TonePicker(selection: $draft.tone)
            }

            if viewModel.memory(for: draft.id) != nil {
                DeleteCard(label: "Delete Memory", icon: "trash.fill") {
                    showsDeleteAlert = true
                }
            }
        }
        .alert("Delete this memory?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteMemory(draft.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The slideshow and timeline will remove this moment.")
        }
        .task(id: photoPickerItem) {
            if let photoPickerItem, let data = try? await photoPickerItem.loadTransferable(type: Data.self) {
                draft.photoData = data
            }
        }
    }
}

private struct AttachmentImageEditor: View {
    @Binding var imageData: Data?
    @Binding var pickerItem: PhotosPickerItem?
    let title: LocalizedStringKey
    let emptyMessage: LocalizedStringKey
    let chooseLabel: LocalizedStringKey
    let removeLabel: LocalizedStringKey
    let placeholderIcon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: placeholderIcon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            ZStack {
                if imageData != nil {
                    CachedDataImage(imageData: imageData) {
                        EmptyView()
                    }
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.white.opacity(0.08))
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: placeholderIcon)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.72))
                                Text(emptyMessage)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.68))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 16)
                        }
                }
            }
            .frame(height: 220)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
            }
            .imageViewer(imageData: imageData, cornerRadius: 24)

            if imageData != nil {
                Button {
                    imageData = nil
                } label: {
                    Label(removeLabel, systemImage: "trash")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity)
                        .background(.white.opacity(0.10), in: Capsule())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
            } else {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label(chooseLabel, systemImage: "photo.badge.plus")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity)
                        .background(Color.white, in: Capsule())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
            }
        }
    }
}

struct VaccineEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: VaccineRecord
    @State private var showsDeleteAlert = false
    @State private var certificatePickerItem: PhotosPickerItem?

    init(viewModel: AppViewModel, vaccineID: UUID?, initialDraft: VaccineRecord? = nil) {
        self.viewModel = viewModel
        _draft = State(initialValue: viewModel.vaccine(for: vaccineID) ?? initialDraft ?? VaccineRecord(
            title: "",
            lastGiven: .now,
            nextDue: Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now,
            status: .onTrack,
            note: "",
            certificateData: nil
        ))
    }

    var body: some View {
        EditorShell(
            title: draft.title.isEmpty ? L10n.tr("New Vaccine", default: "New Vaccine") : draft.title,
            saveLabel: L10n.tr("Save Vaccine", default: "Save Vaccine"),
            isSaveDisabled: draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            dismiss()
        } onSave: {
            viewModel.saveVaccine(draft)
            dismiss()
        } content: {
            GlassCard(tone: tone(for: draft.status)) {
                SectionHeader(
                    eyebrow: "Wellness",
                    title: "Keep vaccine records current",
                    detail: "Dates, status, and notes should be easy to trust at a glance."
                )

                EditorTextField(title: "Vaccine name", text: $draft.title, icon: "cross.vial.fill")
                DateEditor(title: "Last given", icon: "checkmark.seal.fill", date: $draft.lastGiven)
                DateEditor(title: "Next due", icon: "calendar.badge.clock", date: $draft.nextDue)
                EditorEnumPicker(title: "Status", icon: "waveform.path.ecg", selection: $draft.status, options: VaccineStatus.allCases)
                AttachmentImageEditor(
                    imageData: $draft.certificateData,
                    pickerItem: $certificatePickerItem,
                    title: "Vaccine certificate",
                    emptyMessage: "Add the certificate so it can appear behind the vaccine passport card.",
                    chooseLabel: "Choose Certificate",
                    removeLabel: "Remove Certificate",
                    placeholderIcon: "doc.text.image.fill"
                )
                EditorTextEditor(title: "Care note", text: $draft.note, icon: "note.text", height: 110)
            }

            if viewModel.vaccine(for: draft.id) != nil {
                DeleteCard(label: "Delete Vaccine", icon: "trash.fill") {
                    showsDeleteAlert = true
                }
            }
        }
        .alert("Delete this vaccine record?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteVaccine(draft.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the vaccine from the wellness passport.")
        }
        .task(id: certificatePickerItem) {
            if let certificatePickerItem, let data = try? await certificatePickerItem.loadTransferable(type: Data.self) {
                draft.certificateData = data
            }
        }
    }

    private func tone(for status: VaccineStatus) -> PaletteTone {
        switch status {
        case .watch:
            return .apricot
        case .covered:
            return .meadow
        case .onTrack:
            return .lagoon
        }
    }
}

struct BehaviorCheckInEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: BehaviorSnapshot
    @State private var originalDay: Weekday
    @State private var showsDeleteAlert = false

    init(viewModel: AppViewModel, day: Weekday?) {
        self.viewModel = viewModel
        let resolvedDay = day ?? .current
        let existing = viewModel.behaviorSnapshot(for: resolvedDay)
        let initialDraft = existing ?? BehaviorSnapshot(
            day: resolvedDay,
            energy: 0.75,
            calmness: 0.75,
            appetite: 0.80,
            sleepHours: 11.5
        )
        _draft = State(initialValue: initialDraft)
        _originalDay = State(initialValue: existing?.day ?? resolvedDay)
    }

    var body: some View {
        EditorShell(
            title: L10n.tr("Daily Check-In", default: "Daily Check-In"),
            saveLabel: L10n.tr("Save Check-In", default: "Save Check-In")
        ) {
            dismiss()
        } onSave: {
            if originalDay != draft.day {
                viewModel.deleteBehaviorSnapshot(for: originalDay)
            }
            viewModel.saveBehaviorSnapshot(draft)
            dismiss()
        } content: {
            GlassCard(tone: .lagoon) {
                SectionHeader(
                    eyebrow: "Behavior",
                    title: "Log the day your pet actually had",
                    detail: "A quick check-in turns Bond Pulse into something trustworthy instead of inferred."
                )

                EditorEnumPicker(
                    title: "Day",
                    icon: "calendar",
                    selection: $draft.day,
                    options: Weekday.allCases
                )

                BehaviorMetricEditor(
                    title: "Energy",
                    icon: "bolt.heart.fill",
                    value: $draft.energy,
                    rangeLabel: behaviorDescriptor(for: draft.energy)
                )

                BehaviorMetricEditor(
                    title: "Calmness",
                    icon: "moon.zzz.fill",
                    value: $draft.calmness,
                    rangeLabel: behaviorDescriptor(for: draft.calmness)
                )

                BehaviorMetricEditor(
                    title: "Appetite",
                    icon: "fork.knife.circle.fill",
                    value: $draft.appetite,
                    rangeLabel: appetiteDescriptor(for: draft.appetite)
                )

                SleepHoursEditor(hours: $draft.sleepHours)
            }

            if viewModel.behaviorSnapshot(for: originalDay) != nil {
                DeleteCard(label: "Delete Check-In", icon: "trash.fill") {
                    showsDeleteAlert = true
                }
            }
        }
        .alert("Delete this daily check-in?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteBehaviorSnapshot(for: originalDay)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This day will no longer contribute to Bond Pulse until you log it again.")
        }
    }

    private func behaviorDescriptor(for value: Double) -> String {
        switch value {
        case ..<0.35:
            return L10n.tr("Low", default: "Low")
        case ..<0.7:
            return L10n.tr("Balanced", default: "Balanced")
        default:
            return L10n.tr("High", default: "High")
        }
    }

    private func appetiteDescriptor(for value: Double) -> String {
        switch value {
        case ..<0.4:
            return L10n.tr("Light appetite", default: "Light appetite")
        case ..<0.75:
            return L10n.tr("Steady appetite", default: "Steady appetite")
        default:
            return L10n.tr("Strong appetite", default: "Strong appetite")
        }
    }
}

struct WeightEntryEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: WeightEntry
    @State private var valueText: String
    @State private var showsDeleteAlert = false

    init(viewModel: AppViewModel, entryID: UUID?) {
        self.viewModel = viewModel
        let draft = viewModel.weightEntry(for: entryID) ?? WeightEntry(
            loggedAt: .now,
            value: 0,
            unit: viewModel.preferredWeightUnit,
            note: ""
        )
        _draft = State(initialValue: draft)
        _valueText = State(initialValue: draft.value > 0 ? draft.value.formatted(.number.precision(.fractionLength(1))) : "")
    }

    private var parsedValue: Double? {
        Double(valueText.replacingOccurrences(of: ",", with: "."))
    }

    var body: some View {
        EditorShell(
            title: L10n.tr("Weight Log", default: "Weight Log"),
            saveLabel: L10n.tr("Save Weight", default: "Save Weight"),
            isSaveDisabled: (parsedValue ?? 0) <= 0
        ) {
            dismiss()
        } onSave: {
            guard let parsedValue, parsedValue > 0 else { return }
            draft.value = parsedValue
            viewModel.saveWeightEntry(draft)
            dismiss()
        } content: {
            GlassCard(tone: .lagoon) {
                SectionHeader(
                    eyebrow: "Weight",
                    title: "Track the body story over time",
                    detail: "A few consistent weigh-ins make Bond Pulse and wellness reviews far more trustworthy."
                )

                DateEditor(title: "Date", icon: "calendar", date: $draft.loggedAt)
                WeightValueEditor(valueText: $valueText, unit: $draft.unit)
                EditorTextEditor(title: "Context note", text: $draft.note, icon: "text.alignleft", height: 110)
            }

            if viewModel.weightEntry(for: draft.id) != nil {
                DeleteCard(label: "Delete Weight Log", icon: "trash.fill") {
                    showsDeleteAlert = true
                }
            }
        }
        .alert("Delete this weight log?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteWeightEntry(draft.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the weigh-in from the health trend chart.")
        }
    }
}

struct MedicalEntryEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: MedicalEntry
    @State private var showsDeleteAlert = false

    init(viewModel: AppViewModel, entryID: UUID?) {
        self.viewModel = viewModel
        _draft = State(initialValue: viewModel.medicalEntry(for: entryID) ?? MedicalEntry(
            title: "",
            date: .now,
            summary: "",
            clinician: "",
            tone: .lagoon
        ))
    }

    var body: some View {
        EditorShell(
            title: draft.title.isEmpty ? L10n.tr("Medical Entry", default: "Medical Entry") : draft.title,
            saveLabel: L10n.tr("Save Entry", default: "Save Entry"),
            isSaveDisabled: draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            dismiss()
        } onSave: {
            viewModel.saveMedicalEntry(draft)
            dismiss()
        } content: {
            GlassCard(tone: draft.tone) {
                SectionHeader(
                    eyebrow: "Medical",
                    title: "Log context around the care moment",
                    detail: "Clinical details matter more when the app keeps them readable and human."
                )

                EditorTextField(title: "Title", text: $draft.title, icon: "stethoscope")
                DateEditor(title: "Date", icon: "calendar", date: $draft.date)
                EditorTextField(title: "Clinician", text: $draft.clinician, icon: "person.text.rectangle.fill")
                EditorTextEditor(title: "Summary", text: $draft.summary, icon: "text.alignleft", height: 130)
                TonePicker(selection: $draft.tone)
            }

            if viewModel.medicalEntry(for: draft.id) != nil {
                DeleteCard(label: "Delete Entry", icon: "trash.fill") {
                    showsDeleteAlert = true
                }
            }
        }
        .alert("Delete this medical entry?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteMedicalEntry(draft.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the item from the medical timeline.")
        }
    }
}

private struct WeightValueEditor: View {
    @Binding var valueText: String
    @Binding var unit: WeightUnit

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Weight", systemImage: "scalemass.fill")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))

                TextField("12.5", text: $valueText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .tint(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("Unit", systemImage: "ruler.fill")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))

                Menu {
                    ForEach(WeightUnit.allCases) { option in
                        Button(option.description) {
                            unit = option
                        }
                    }
                } label: {
                    HStack {
                        Text(unit.description)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.98))
            }
            .frame(width: 128)
        }
    }
}

private struct BehaviorMetricEditor: View {
    let title: LocalizedStringKey
    let icon: String
    @Binding var value: Double
    let rangeLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))

                Spacer()

                Text("\(Int((value * 100).rounded()))% • \(rangeLabel)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
            }

            Slider(value: $value, in: 0...1)
                .tint(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 10)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct SleepHoursEditor: View {
    @Binding var hours: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Sleep", systemImage: "bed.double.fill")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))

                Spacer()

                Text("\(hours.formatted(.number.precision(.fractionLength(1)))) h")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
            }

            Slider(value: $hours, in: 4...18, step: 0.5)
                .tint(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 10)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

struct FoodPreferenceEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: FoodPreference
    @State private var showsDeleteAlert = false

    init(viewModel: AppViewModel, preferenceID: UUID?) {
        self.viewModel = viewModel
        _draft = State(initialValue: viewModel.foodPreference(for: preferenceID) ?? FoodPreference(
            title: "",
            detail: "",
            systemImage: "fork.knife.circle.fill"
        ))
    }

    var body: some View {
        EditorShell(
            title: draft.title.isEmpty ? L10n.tr("Food Note", default: "Food Note") : draft.title,
            saveLabel: L10n.tr("Save Food Note", default: "Save Food Note"),
            isSaveDisabled: draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            dismiss()
        } onSave: {
            viewModel.saveFoodPreference(draft)
            dismiss()
        } content: {
            GlassCard(tone: .meadow) {
                SectionHeader(
                    eyebrow: "Food habits",
                    title: "Capture preferences and body cues",
                    detail: "Small feeding details are often the most useful once they are easy to log."
                )

                EditorTextField(title: "Title", text: $draft.title, icon: "leaf.fill")
                EditorTextEditor(title: "Detail", text: $draft.detail, icon: "fork.knife", height: 120)

                SymbolPicker(
                    title: "Category icon",
                    selection: $draft.systemImage,
                    options: EditorAssetOptions.foodSymbols
                )
            }

            if viewModel.foodPreference(for: draft.id) != nil {
                DeleteCard(label: "Delete Food Note", icon: "trash.fill") {
                    showsDeleteAlert = true
                }
            }
        }
        .alert("Delete this food note?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteFoodPreference(draft.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the note from the wellness food section.")
        }
    }
}

struct MedicationEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: MedicationRecord
    @State private var showsDeleteAlert = false

    init(viewModel: AppViewModel, medicationID: UUID?) {
        self.viewModel = viewModel
        _draft = State(initialValue: viewModel.medication(for: medicationID) ?? MedicationRecord(
            title: "",
            dosage: "",
            scheduleNote: "",
            purpose: "",
            nextDose: .now,
            status: .active,
            tone: .lagoon
        ))
    }

    var body: some View {
        EditorShell(
            title: draft.title.isEmpty ? L10n.tr("Medication", default: "Medication") : draft.title,
            saveLabel: L10n.tr("Save Medication", default: "Save Medication"),
            isSaveDisabled: draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            dismiss()
        } onSave: {
            viewModel.saveMedication(draft)
            dismiss()
        } content: {
            GlassCard(tone: draft.tone) {
                SectionHeader(
                    eyebrow: "Medication",
                    title: "Track support that keeps care steady",
                    detail: "Dosage, timing, and why it matters should stay easy to review before the next vet visit."
                )

                EditorTextField(title: "Medication name", text: $draft.title, icon: "pills.fill")
                EditorTextField(title: "Dosage", text: $draft.dosage, icon: "scalemass.fill")
                EditorTextField(title: "Schedule", text: $draft.scheduleNote, icon: "clock.badge.checkmark.fill")
                EditorTextEditor(title: "Purpose or note", text: $draft.purpose, icon: "heart.text.square.fill", height: 110)
                DateTimeEditor(title: "Next dose", icon: "calendar.badge.clock", date: $draft.nextDose)
                EditorEnumPicker(title: "Status", icon: "waveform.path.ecg", selection: $draft.status, options: MedicationStatus.allCases)
                TonePicker(selection: $draft.tone)

                Toggle(isOn: $draft.notificationsEnabled) {
                    Label("Medication reminders", systemImage: "bell.badge.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .tint(.white)
            }

            if viewModel.medication(for: draft.id) != nil {
                DeleteCard(label: "Delete Medication", icon: "trash.fill") {
                    showsDeleteAlert = true
                }
            }
        }
        .alert("Delete this medication?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteMedication(draft.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the medication from the wellness tracker.")
        }
    }
}

struct SymptomEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: SymptomEntry
    @State private var showsDeleteAlert = false

    init(viewModel: AppViewModel, symptomID: UUID?) {
        self.viewModel = viewModel
        _draft = State(initialValue: viewModel.symptom(for: symptomID) ?? SymptomEntry(
            title: "",
            detail: "",
            observedAt: .now,
            severity: .mild,
            systemImage: "exclamationmark.triangle.fill",
            tone: .apricot
        ))
    }

    var body: some View {
        EditorShell(
            title: draft.title.isEmpty ? L10n.tr("Symptom", default: "Symptom") : draft.title,
            saveLabel: L10n.tr("Save Symptom", default: "Save Symptom"),
            isSaveDisabled: draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            dismiss()
        } onSave: {
            viewModel.saveSymptom(draft)
            dismiss()
        } content: {
            GlassCard(tone: draft.tone) {
                SectionHeader(
                    eyebrow: "Symptoms",
                    title: "Log what felt off, while it is fresh",
                    detail: "Small changes are often the most useful when you can capture them with date, severity, and context."
                )

                EditorTextField(title: "Symptom", text: $draft.title, icon: "stethoscope.circle.fill")
                DateTimeEditor(title: "Observed at", icon: "calendar", date: $draft.observedAt)
                EditorEnumPicker(title: "Severity", icon: "exclamationmark.circle.fill", selection: $draft.severity, options: SymptomSeverity.allCases)
                EditorTextEditor(title: "Detail", text: $draft.detail, icon: "text.alignleft", height: 130)
                SymbolPicker(title: "Symptom icon", selection: $draft.systemImage, options: EditorAssetOptions.symptomSymbols)
                TonePicker(selection: $draft.tone)
            }

            if viewModel.symptom(for: draft.id) != nil {
                DeleteCard(label: "Delete Symptom", icon: "trash.fill") {
                    showsDeleteAlert = true
                }
            }
        }
        .alert("Delete this symptom entry?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteSymptom(draft.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the symptom from the wellness timeline.")
        }
    }
}

private struct EditorShell<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let saveLabel: String
    let isSaveDisabled: Bool
    let onClose: () -> Void
    let onSave: () -> Void
    @ViewBuilder let content: Content

    init(
        title: String,
        saveLabel: String,
        isSaveDisabled: Bool = false,
        onClose: @escaping () -> Void,
        onSave: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.saveLabel = saveLabel
        self.isSaveDisabled = isSaveDisabled
        self.onClose = onClose
        self.onSave = onSave
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FormBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        content
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", action: onClose)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(saveLabel, action: onSave)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(isSaveDisabled ? Color.white.opacity(0.45) : .white)
                        .disabled(isSaveDisabled)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

private struct EditorTextField: View {
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let icon: String

    init(
        title: LocalizedStringKey,
        placeholder: LocalizedStringKey? = nil,
        text: Binding<String>,
        icon: String
    ) {
        self.title = title
        self.placeholder = placeholder ?? title
        self._text = text
        self.icon = icon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.words)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .tint(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct EditorTextEditor: View {
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let icon: String
    let height: CGFloat

    init(
        title: LocalizedStringKey,
        placeholder: LocalizedStringKey? = nil,
        text: Binding<String>,
        icon: String,
        height: CGFloat
    ) {
        self.title = title
        self.placeholder = placeholder ?? title
        self._text = text
        self.icon = icon
        self.height = height
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            ZStack(alignment: .topLeading) {
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(placeholder)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.38))
                        .padding(.horizontal, 17)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(height: height)
                    .padding(12)
                    .background(Color.clear)
            }
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct EditorEnumPicker<Option: Identifiable & CaseIterable & Hashable>: View where Option.AllCases: RandomAccessCollection, Option: CustomStringConvertible {
    let title: LocalizedStringKey
    let icon: String
    @Binding var selection: Option
    let options: Option.AllCases

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            Menu {
                ForEach(Array(options), id: \.id) { option in
                    Button(option.description) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.description)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.98))
        }
    }
}

private struct DateEditor: View {
    let title: LocalizedStringKey
    let icon: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct DateTimeEditor: View {
    let title: LocalizedStringKey
    let icon: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            DatePicker("", selection: $date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct ClockTimeEditor: View {
    let title: LocalizedStringKey
    @Binding var time: ClockTime

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: "clock.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            DatePicker(
                "",
                selection: Binding(
                    get: { time.dateValue },
                    set: { time = ClockTime(date: $0) }
                ),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.wheel)
            .tint(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct TonePicker: View {
    @Binding var selection: PaletteTone
    
    private let columns = [
        GridItem(.adaptive(minimum: 108, maximum: 156), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Color tone", systemImage: "paintpalette.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                ForEach(PaletteTone.allCases) { tone in
                    Button {
                        selection = tone
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(tone.primaryColor)
                                .frame(width: 12, height: 12)
                            Text(tone.title)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                        }
                        .foregroundStyle(selection == tone ? Color(red: 0.10, green: 0.13, blue: 0.22) : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selection == tone ? AnyShapeStyle(.white) : AnyShapeStyle(.white.opacity(0.08)), in: Capsule())
                    }
                    .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97))
                }
            }
        }
    }
}

private struct SymbolPicker: View {
    let title: LocalizedStringKey
    @Binding var selection: String
    let options: [String]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: "square.grid.2x2")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(options, id: \.self) { symbol in
                    Button {
                        selection = symbol
                    } label: {
                        Image(systemName: symbol)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(selection == symbol ? Color(red: 0.10, green: 0.13, blue: 0.22) : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(selection == symbol ? AnyShapeStyle(.white) : AnyShapeStyle(.white.opacity(0.08)), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
                }
            }
        }
    }
}

private struct DeleteCard: View {
    let label: LocalizedStringKey
    let icon: String
    let action: () -> Void

    var body: some View {
        GlassCard(tone: .twilight) {
            Button(action: action) {
                HStack {
                    Spacer()
                    Label(label, systemImage: icon)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    Spacer()
                }
                .background(Color.red.opacity(0.22), in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(Color.red.opacity(0.28), lineWidth: 1)
                }
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97))
        }
    }
}

private enum EditorAssetOptions {
    static let routineSymbols = [
        "sunrise.fill",
        "figure.walk",
        "carrot.fill",
        "brain.head.profile",
        "comb.fill",
        "shower.fill",
        "figure.run.circle.fill",
        "cup.and.saucer.fill",
        "mountain.2.fill",
        "moon.stars.fill",
        "tennisball.fill",
        "sparkles",
        "heart.circle.fill",
    ]

    static let memorySymbols = [
        "heart.circle.fill",
        "birthday.cake.fill",
        "camera.fill",
        "sparkles.rectangle.stack.fill",
        "cross.vial.fill",
        "sun.max.fill",
        "leaf.fill",
        "cloud.drizzle.fill",
        "car.fill",
        "gift.fill",
        "party.popper.fill",
        "pawprint.fill",
    ]

    static let foodSymbols = [
        "fork.knife.circle.fill",
        "drop.fill",
        "carrot.fill",
        "sparkles",
        "fish.fill",
        "leaf.fill",
        "heart.text.square.fill",
        "exclamationmark.triangle.fill",
    ]

    static let symptomSymbols = [
        "exclamationmark.triangle.fill",
        "pawprint.fill",
        "drop.fill",
        "wind",
        "waveform.path.ecg",
        "bed.double.fill",
        "fork.knife.circle.fill",
        "eye.fill",
    ]
}

private extension ClockTime {
    init(date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        self.init(hour: components.hour ?? 0, minute: components.minute ?? 0)
    }

    var dateValue: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? .now
    }
}

extension RoutineCategory: CustomStringConvertible {
    var description: String { title }
}

extension Weekday: CustomStringConvertible {
    var description: String { title }
}

extension VaccineStatus: CustomStringConvertible {
    var description: String { title }
}

extension WeightUnit: CustomStringConvertible {
    var description: String { title }
}

extension MedicationStatus: CustomStringConvertible {
    var description: String { title }
}

extension SymptomSeverity: CustomStringConvertible {
    var description: String { title }
}
