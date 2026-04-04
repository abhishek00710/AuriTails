import PhotosUI
import SwiftUI

struct RoutineEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: RoutineItem
    @State private var showsDeleteAlert = false

    init(viewModel: AppViewModel, routineID: UUID?) {
        self.viewModel = viewModel
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
            title: draft.title.isEmpty ? "New Routine" : draft.title,
            saveLabel: "Save Routine",
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
            title: draft.title.isEmpty ? "New Memory" : draft.title,
            saveLabel: "Save Memory",
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

                MemoryPhotoEditor(imageData: $draft.photoData, pickerItem: $photoPickerItem)

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

private struct MemoryPhotoEditor: View {
    @Binding var imageData: Data?
    @Binding var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Memory photo", systemImage: "photo.stack.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            ZStack {
                if let imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.white.opacity(0.08))
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.72))
                                Text("Add a photo to fill the memory postcard")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.68))
                            }
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

            if imageData != nil {
                Button {
                    imageData = nil
                } label: {
                    Label("Remove Photo", systemImage: "trash")
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
                    Label("Choose Photo", systemImage: "photo.badge.plus")
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

    init(viewModel: AppViewModel, vaccineID: UUID?) {
        self.viewModel = viewModel
        _draft = State(initialValue: viewModel.vaccine(for: vaccineID) ?? VaccineRecord(
            title: "",
            lastGiven: .now,
            nextDue: Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now,
            status: .onTrack,
            note: ""
        ))
    }

    var body: some View {
        EditorShell(
            title: draft.title.isEmpty ? "New Vaccine" : draft.title,
            saveLabel: "Save Vaccine",
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
            title: draft.title.isEmpty ? "Medical Entry" : draft.title,
            saveLabel: "Save Entry",
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
            title: draft.title.isEmpty ? "Food Note" : draft.title,
            saveLabel: "Save Food Note",
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
                AppBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        content
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", action: onClose)
                        .foregroundStyle(colorScheme.topBarButtonColor)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(saveLabel, action: onSave)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(isSaveDisabled ? colorScheme.topBarButtonColor.opacity(0.45) : colorScheme.topBarButtonColor)
                        .disabled(isSaveDisabled)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

private struct EditorTextField: View {
    let title: String
    @Binding var text: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            TextField("", text: $text)
                .textInputAutocapitalization(.words)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct EditorTextEditor: View {
    let title: String
    @Binding var text: String
    let icon: String
    let height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .frame(height: height)
                .padding(12)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct EditorEnumPicker<Option: Identifiable & CaseIterable & Hashable>: View where Option.AllCases: RandomAccessCollection, Option: CustomStringConvertible {
    let title: String
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
    let title: String
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

private struct ClockTimeEditor: View {
    let title: String
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
    let title: String
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
    let label: String
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
