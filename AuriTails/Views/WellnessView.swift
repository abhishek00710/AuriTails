import MapKit
import SwiftUI

struct WellnessView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 22) {
                overviewCard
                vetVisitPackSection
                petCareSection
                vaccinationSection
                medicationSection
                symptomSection
                medicalTimeline
                foodSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
    }

    private var overviewCard: some View {
        GlassCard(tone: .lagoon) {
            SectionHeader(
                eyebrow: "Profile",
                title: "\(viewModel.displayPetName)'s care passport",
                detail: LocalizedStringKey({
                    let parts = [
                        viewModel.pet.breed.trimmedOrNil,
                        viewModel.pet.ageDescription.trimmedOrNil,
                        viewModel.pet.weightDescription.trimmedOrNil,
                    ].compactMap { $0 }
                    return parts.isEmpty ? "Add your pet profile to turn this into a real wellness passport." : parts.joined(separator: " • ")
                }())
            )

            HStack(spacing: 12) {
                StatChip(title: "Favorite treat", value: viewModel.pet.favoriteTreat.trimmedOrNil ?? "Not added")
                StatChip(title: "Next watch", value: viewModel.nextMedication?.title ?? viewModel.upcomingWellnessTitle)
            }

            Text(viewModel.pet.energySummary.trimmedOrNil ?? "Vaccines, food notes, and care context will start shaping this summary once you add real details.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
        }
    }

    private var medicationSection: some View {
        GlassCard(tone: .meadow) {
            HStack(alignment: .top, spacing: 12) {
                SectionHeader(
                    eyebrow: "Medication",
                    title: "Support that stays on schedule",
                    detail: "Track dosage, timing, and why each medication is in the routine without losing the calmer visual language."
                )

                Spacer(minLength: 0)

                Button {
                    viewModel.openMedicationEditor()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
            }

            if viewModel.selectedPetMedications.isEmpty {
                wellnessEmptyPrompt(
                    title: "No medication records yet",
                    detail: "Add ongoing meds, recovery support, or seasonal treatments so this section starts reflecting the real care picture.",
                    buttonTitle: "Add medication",
                    systemImage: "pills.fill"
                ) {
                    viewModel.openMedicationEditor()
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.selectedPetMedications) { medication in
                        GlassHealthRow(tone: medication.tone) {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 10) {
                                        Text(medication.title)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.white)

                                        Text(medication.status.title)
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .background(.white, in: Capsule())
                                    }

                                    Text("\(medication.dosage) • \(medication.scheduleNote)")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.68))

                                    Text(medication.purpose)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.76))

                                    Text("Next dose • \(medication.nextDoseLabel)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.62))
                                }

                                Spacer(minLength: 0)

                                VStack(spacing: 10) {
                                    Button {
                                        viewModel.openMedicationEditor(medication.id)
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(.white.opacity(0.78))
                                    }
                                    .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))

                                    Button {
                                        viewModel.toggleMedicationNotifications(medication.id)
                                    } label: {
                                        Image(systemName: medication.notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(.white.opacity(0.78))
                                    }
                                    .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var symptomSection: some View {
        GlassCard(tone: .apricot) {
            HStack(alignment: .top, spacing: 12) {
                SectionHeader(
                    eyebrow: "Symptoms",
                    title: "Notice small shifts before they disappear",
                    detail: "Capture appetite dips, itchiness, coughing, or recovery notes with just enough structure to be useful later."
                )

                Spacer(minLength: 0)

                Button {
                    viewModel.openSymptomEditor()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
            }

            if viewModel.selectedPetSymptoms.isEmpty {
                wellnessEmptyPrompt(
                    title: "No symptom notes yet",
                    detail: "Log things like paw licking, appetite changes, sneezing, or low-energy days when they happen so the pattern has something real to read.",
                    buttonTitle: "Add symptom",
                    systemImage: "stethoscope"
                ) {
                    viewModel.openSymptomEditor()
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.recentSymptoms.prefix(5)) { symptom in
                        GlassHealthRow(tone: symptom.tone) {
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.white.opacity(0.10))

                                    Image(systemName: symptom.systemImage)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 46, height: 46)

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 10) {
                                        Text(symptom.title)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.white)

                                        Text(symptom.severity.title)
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .background(.white, in: Capsule())
                                    }

                                    Text(symptom.observedLabel)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.62))

                                    Text(symptom.detail)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.76))
                                }

                                Spacer(minLength: 0)

                                Button {
                                    viewModel.openSymptomEditor(symptom.id)
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.78))
                                }
                                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                            }
                        }
                    }
                }
            }
        }
    }

    private var petCareSection: some View {
        GlassCard(tone: .apricot) {
            HStack(alignment: .top, spacing: 12) {
                SectionHeader(
                    eyebrow: "Nearby care",
                    title: "Pet hospital locator",
                    detail: "Find nearby veterinary hospitals and emergency clinics without leaving the wellness flow."
                )

                Spacer(minLength: 0)

                Button {
                    viewModel.refreshNearbyPetCare()
                } label: {
                    Image(systemName: "location.magnifyingglass")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
            }

            if viewModel.isLoadingNearbyPetCare {
                HStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)

                    Text(viewModel.nearbyPetCareStatusMessage)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if viewModel.nearbyPetCare.isEmpty {
                Text(viewModel.nearbyPetCareStatusMessage)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.nearbyPetCare.prefix(4)) { place in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(place.name)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)

                                    Text(place.address)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.72))

                                    Text(place.distanceText)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.56))
                                }

                                Spacer(minLength: 0)
                            }

                            HStack(spacing: 10) {
                                Button {
                                    viewModel.openDirections(to: place)
                                } label: {
                                    LocatorActionLabel(title: "Directions", systemImage: "car.fill")
                                }
                                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))

                                if place.phoneNumber != nil {
                                    Button {
                                        viewModel.call(place)
                                    } label: {
                                        LocatorActionLabel(title: "Call", systemImage: "phone.fill")
                                    }
                                    .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
                                }

                                Button {
                                    place.mapItem.openInMaps()
                                } label: {
                                    LocatorActionLabel(title: "Maps", systemImage: "map.fill")
                                }
                                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                }
            }
        }
    }

    private var vetVisitPackSection: some View {
        GlassCard(tone: .twilight) {
            SectionHeader(
                eyebrow: "Vet ready",
                title: "Visit pack and fast import",
                detail: "Share a polished care PDF for appointments, or scan a vaccine certificate to prefill a record in seconds."
            )

            Button {
                viewModel.shareVetVisitPack()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up.on.square.fill")
                    Text("Share Vet Visit Pack")
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.white, in: Capsule())
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))

            HStack(spacing: 12) {
                Button {
                    viewModel.startVaccineScanner()
                } label: {
                    VetVisitActionLabel(title: "Scan Certificate", systemImage: "doc.text.viewfinder")
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))

                Button {
                    viewModel.importVaccineDocument()
                } label: {
                    VetVisitActionLabel(title: "Import File", systemImage: "tray.and.arrow.down.fill")
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
            }
        }
    }

    private var vaccinationSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    SectionHeader(
                        eyebrow: "Vaccines",
                        title: "Reports that stay readable",
                        detail: "Medical data is still clinical, but the interface doesn't need to feel cold."
                    )

                    Spacer(minLength: 0)

                    Button {
                        viewModel.openVaccineEditor()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                            .frame(width: 42, height: 42)
                            .background(Color.white, in: Circle())
                    }
                    .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                }

                if viewModel.selectedPetVaccinations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        wellnessEmptyPrompt(
                            title: "No vaccine records yet",
                            detail: "Add the first vaccine manually or scan a certificate to start the passport with something real.",
                            buttonTitle: "Add vaccine",
                            systemImage: "cross.case.fill"
                        ) {
                            viewModel.openVaccineEditor()
                        }

                        EmptyDelightActionButton(title: "Scan certificate", systemImage: "camera.viewfinder") {
                            viewModel.startVaccineScanner()
                        }
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(viewModel.selectedPetVaccinations) { record in
                                VaccinePassportCard(record: record, tone: tone(for: record.status)) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(record.title)
                                                .font(.system(size: 20, weight: .semibold, design: .serif))
                                                .foregroundStyle(.white)

                                            Text(record.status.title)
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(.white, in: Capsule())
                                        }

                                        Spacer()

                                        Button {
                                            viewModel.openVaccineEditor(record.id)
                                        } label: {
                                            Image(systemName: "pencil.circle.fill")
                                                .font(.system(size: 21, weight: .semibold))
                                                .foregroundStyle(.white.opacity(0.84))
                                        }
                                        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))

                                        Button {
                                            viewModel.toggleVaccineNotifications(record.id)
                                        } label: {
                                            Image(systemName: record.notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundStyle(.white.opacity(0.84))
                                        }
                                        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                                    }

                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Last given • \(record.lastGivenLabel)")
                                        Text("Next due • \(record.nextDueLabel)")
                                    }
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.76))

                                    Text(record.note)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.72))
                                }
                                .frame(width: 240, height: 210, alignment: .topLeading)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }

    private var medicalTimeline: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 12) {
                SectionHeader(
                    eyebrow: "History",
                    title: "Medical moments with context",
                    detail: "Vet notes, allergy flares, and cleanings stay beside the story instead of hiding in a document folder."
                )

                Spacer(minLength: 0)

                Button {
                    viewModel.openMedicalEntryEditor()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
            }

            if viewModel.selectedPetMedicalHistory.isEmpty {
                wellnessEmptyPrompt(
                    title: "No medical history yet",
                    detail: "Annual exams, allergy notes, injury updates, and dental visits will start living here once you log the first one.",
                    buttonTitle: "Add medical note",
                    systemImage: "doc.text.fill"
                ) {
                    viewModel.openMedicalEntryEditor()
                }
            } else {
                VStack(spacing: 18) {
                    ForEach(viewModel.selectedPetMedicalHistory) { entry in
                        HStack(alignment: .top, spacing: 14) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(entry.tone.secondaryColor)
                                    .frame(width: 14, height: 14)
                                Rectangle()
                                    .fill(.white.opacity(0.12))
                                    .frame(width: 1)
                            }
                            .frame(width: 16)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(entry.title)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("\(entry.dateLabel) • \(entry.clinician)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.62))
                                Text(entry.summary)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.76))
                            }

                            Spacer()

                            Button {
                                viewModel.openMedicalEntryEditor(entry.id)
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.72))
                            }
                            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                        }
                    }
                }
            }
        }
    }

    private var foodSection: some View {
        GlassCard(tone: .meadow) {
            HStack(alignment: .top, spacing: 12) {
                SectionHeader(
                    eyebrow: "Food habits",
                    title: "Preferences and body cues",
                    detail: "Meals feel more useful when they reflect sensitivities, enrichment, and hydration rhythms."
                )

                Spacer(minLength: 0)

                Button {
                    viewModel.openFoodPreferenceEditor()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
            }

            if viewModel.selectedPetFoodPreferences.isEmpty {
                wellnessEmptyPrompt(
                    title: "No food notes yet",
                    detail: "Add meals, sensitivities, favorite toppers, or hydration rituals so food patterns start feeling useful instead of blank.",
                    buttonTitle: "Add food note",
                    systemImage: "fork.knife"
                ) {
                    viewModel.openFoodPreferenceEditor()
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.selectedPetFoodPreferences) { preference in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                Label(preference.title, systemImage: preference.systemImage)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Spacer(minLength: 8)

                                Button {
                                    viewModel.openFoodPreferenceEditor(preference.id)
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.72))
                                }
                                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                            }
                            Text(preference.detail)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))
                        }
                        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
                        .padding(16)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                }
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

    private func wellnessEmptyPrompt(
        title: String,
        detail: String,
        buttonTitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text(detail)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.76))
                .fixedSize(horizontal: false, vertical: true)

            EmptyDelightActionButton(title: buttonTitle, systemImage: systemImage, action: action)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct GlassHealthRow<Content: View>: View {
    let tone: PaletteTone
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    tone.primaryColor.opacity(0.22),
                    tone.secondaryColor.opacity(0.12),
                    Color.white.opacity(0.04),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        }
    }
}

private struct VaccinePassportCard<Content: View>: View {
    let record: VaccineRecord
    let tone: PaletteTone
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
        .background {
            ZStack {
                if record.certificateData != nil {
                    CachedDataImage(imageData: record.certificateData) {
                        EmptyView()
                    }
                    .overlay {
                        LinearGradient(
                            colors: [
                                tone.primaryColor.opacity(0.30),
                                Color.black.opacity(0.10),
                                Color.black.opacity(0.42),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tone.primaryColor, tone.secondaryColor, Color.black.opacity(0.24)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(.white.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 12)
        .imageViewer(imageData: record.certificateData, cornerRadius: 30)
    }
}

private struct VetVisitActionLabel: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
            Text(title)
        }
        .font(.system(size: 13, weight: .bold, design: .rounded))
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.10), in: Capsule())
    }
}

private struct LocatorActionLabel: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(Color.white, in: Capsule())
    }
}
