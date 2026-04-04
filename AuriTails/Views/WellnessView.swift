import SwiftUI

struct WellnessView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                overviewCard
                vaccinationSection
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
                title: "\(viewModel.pet.name)'s care passport",
                detail: "\(viewModel.pet.breed) • \(viewModel.pet.ageDescription) • \(viewModel.pet.weightDescription)"
            )

            HStack(spacing: 12) {
                StatChip(title: "Favorite treat", value: viewModel.pet.favoriteTreat)
                StatChip(title: "Next watch", value: viewModel.upcomingWellnessTitle)
            }

            Text(viewModel.pet.energySummary)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
        }
    }

    private var vaccinationSection: some View {
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.vaccinations) { record in
                        GlassCard(tone: tone(for: record.status)) {
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
                        .frame(width: 240)
                    }
                }
                .padding(.vertical, 2)
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

            VStack(spacing: 18) {
                ForEach(viewModel.medicalHistory) { entry in
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

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.foodPreferences) { preference in
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
