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
                StatChip(title: "Next watch", value: "Bordetella")
            }

            Text(viewModel.pet.energySummary)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
        }
    }

    private var vaccinationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(
                eyebrow: "Vaccines",
                title: "Reports that stay readable",
                detail: "Medical data is still clinical, but the interface doesn't need to feel cold."
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.vaccinations) { record in
                        GlassCard(tone: tone(for: record.status)) {
                            Text(record.title)
                                .font(.system(size: 20, weight: .semibold, design: .serif))
                                .foregroundStyle(.white)

                            Text(record.status)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.white, in: Capsule())

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last given • \(record.lastGiven)")
                                Text("Next due • \(record.nextDue)")
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
            SectionHeader(
                eyebrow: "History",
                title: "Medical moments with context",
                detail: "Vet notes, allergy flares, and cleanings stay beside the story instead of hiding in a document folder."
            )

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
                    }
                }
            }
        }
    }

    private var foodSection: some View {
        GlassCard(tone: .meadow) {
            SectionHeader(
                eyebrow: "Food habits",
                title: "Preferences and body cues",
                detail: "Meals feel more useful when they reflect sensitivities, enrichment, and hydration rhythms."
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.foodPreferences) { preference in
                    VStack(alignment: .leading, spacing: 10) {
                        Label(preference.title, systemImage: preference.systemImage)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
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

    private func tone(for status: String) -> PaletteTone {
        switch status {
        case "Watch":
            return .apricot
        case "Covered":
            return .meadow
        default:
            return .lagoon
        }
    }
}
