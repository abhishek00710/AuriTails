import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var hasAppeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 22) {
                heroCard
                    .offset(y: hasAppeared ? 0 : 20)
                    .opacity(hasAppeared ? 1 : 0)

                spotlightGrid
                    .offset(y: hasAppeared ? 0 : 28)
                    .opacity(hasAppeared ? 1 : 0)

                rhythmCard
                    .offset(y: hasAppeared ? 0 : 36)
                    .opacity(hasAppeared ? 1 : 0)

                insightCard
                    .offset(y: hasAppeared ? 0 : 44)
                    .opacity(hasAppeared ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .onAppear {
            guard !hasAppeared else { return }
            withAnimation(.spring(response: 0.62, dampingFraction: 0.88)) {
                hasAppeared = true
            }
        }
    }

    private var heroCard: some View {
        GlassCard(tone: .apricot) {
            VStack(alignment: .leading, spacing: 18) {
                Text("A softer home for every walk, memory, and wellness check.")
                    .font(.system(size: 32, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)

                Text("\(viewModel.displayOwnerName) and \(viewModel.displayPetName) get one cinematic dashboard instead of four disconnected pet tools.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))

                GeometryReader { proxy in
                    let imageSpacing = AppLayoutMetrics.screenWidth * 0.045
                    let cardWidth = max(0, (proxy.size.width - imageSpacing) / 2)

                    HStack(spacing: imageSpacing) {
                        VStack(alignment: .leading, spacing: 10) {
                            RoundedProfilePhoto(
                                imageData: viewModel.ownerPhotoData,
                                role: .owner,
                                height: 122,
                                cornerRadius: 26,
                                expandsHorizontally: true,
                                maxWidth: cardWidth
                            )
                            .frame(width: cardWidth, height: 122)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

                            Text(viewModel.displayOwnerName)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        .frame(width: cardWidth, alignment: .leading)

                        VStack(alignment: .leading, spacing: 10) {
                            RoundedProfilePhoto(
                                imageData: viewModel.petPhotoData,
                                role: .pet,
                                height: 122,
                                cornerRadius: 26,
                                expandsHorizontally: true,
                                maxWidth: cardWidth
                            )
                            .frame(width: cardWidth, height: 122)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

                            Text(viewModel.displayPetName)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        .frame(width: cardWidth, alignment: .leading)
                    }
                }
                .frame(height: 152)

                BondHeroPhoto(imageData: viewModel.bondPhotoData, height: 250, cornerRadius: 30)

                HStack(spacing: 12) {
                    StatChip(title: "Bond Score", value: "\(viewModel.bondScore)")
                    StatChip(title: "Today's Rhythm", value: "\(viewModel.todaysRoutines.count) rituals")
                    StatChip(title: "Next Glow", value: viewModel.nextCelebration?.title ?? "Ready")
                }
            }
        }
    }

    private var spotlightGrid: some View {
        HStack(spacing: 14) {
            GlassCard(tone: .lagoon) {
                Label("Wellness note", systemImage: "cross.case.fill")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))

                Text(viewModel.upcomingWellnessNote)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Health admin feels calmer when records live beside the relationship, not outside it.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .frame(maxWidth: .infinity)

            GlassCard(tone: .meadow) {
                Label("Memory pulse", systemImage: "film.stack.fill")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))

                Text(viewModel.nextCelebration?.title ?? "First memory ready")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(viewModel.nextCelebration?.detail ?? "Add one milestone and AuriTails will turn it into a richer story card.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var rhythmCard: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 12) {
                SectionHeader(
                    eyebrow: "Pattern read",
                    title: "This week's emotional rhythm",
                    detail: "Bars show energy. The white marker shows calmness, so you can spot when busy days need softer landings."
                )

                Spacer(minLength: 0)

                Button {
                    viewModel.openBehaviorCheckIn()
                } label: {
                    Image(systemName: viewModel.todayBehaviorSnapshot == nil ? "plus" : "pencil")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                .accessibilityLabel(viewModel.todayBehaviorSnapshot == nil ? "Add daily check-in" : "Edit daily check-in")
            }
            if viewModel.hasBehaviorData {
                BehaviorSparkline(snapshots: viewModel.selectedPetBehaviorSnapshots)

                if let todaySnapshot = viewModel.todayBehaviorSnapshot {
                    HStack(alignment: .top, spacing: 0) {
                        StatChip(title: "Energy", value: todaySnapshot.energy.formattedBehaviorScore, fillsWidth: false)
                        Spacer(minLength: 12)
                        StatChip(title: "Calmness", value: todaySnapshot.calmness.formattedBehaviorScore, fillsWidth: false)
                        Spacer(minLength: 12)
                        StatChip(title: "Appetite", value: todaySnapshot.appetite.formattedBehaviorScore, fillsWidth: false)
                        Spacer(minLength: 12)
                        StatChip(title: "Sleep", value: todaySnapshot.sleepHours.formattedSleepLabel, fillsWidth: false)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(viewModel.pet.bondStatement.trimmedOrNil ?? "A few daily check-ins will turn this area into a live read of energy, calmness, appetite, and recovery.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            } else {
                EmptyDelightCard(
                    tone: .twilight,
                    eyebrow: "First rhythm",
                    title: "Start with one honest daily check-in",
                    detail: "The moment you log energy, calmness, appetite, or sleep, this card stops feeling generic and starts reading like your real week.",
                    systemImage: "waveform.path.ecg"
                ) {
                    EmptyDelightActionButton(title: "Add today's check-in", systemImage: "sparkles") {
                        viewModel.openBehaviorCheckIn()
                    }
                }
            }
        }
    }

    private var insightCard: some View {
        GlassCard(tone: .twilight) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: viewModel.insights.first?.systemImage ?? "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.99, green: 0.84, blue: 0.67))
                    .frame(width: 46, height: 46)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.insights.first?.title ?? "Bond AI is listening")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)

                    Text(viewModel.insights.first?.detail ?? "Add a few care signals and routines to start receiving personalized guidance.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))

                    Button {
                        viewModel.openAI()
                    } label: {
                        Label("Open Bond AI", systemImage: "arrow.up.right")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.white, in: Capsule())
                    }
                    .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92, pressedBrightness: 0.06))
                }

                Spacer()
            }
        }
    }
}

private extension Double {
    var formattedBehaviorScore: String {
        "\(Int((self * 100).rounded()))%"
    }

    var formattedSleepLabel: String {
        "\(self.formatted(.number.precision(.fractionLength(1))))h"
    }
}
