import SwiftUI

struct AICompanionView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        GlassCard(tone: .lagoon) {
                            SectionHeader(
                                eyebrow: "Bond AI",
                                title: "Personalized tips from real rhythm patterns",
                                detail: "This stays intentionally gentle: no fake diagnosis, just thoughtful pattern-based guidance."
                            )

                            HStack(spacing: 12) {
                                StatChip(title: "Insights", value: "\(viewModel.insights.count)")
                                StatChip(title: "Bond score", value: "\(viewModel.bondScore)")
                            }
                        }

                        GlassCard {
                            Text("Behavior read")
                                .font(.system(size: 22, weight: .semibold, design: .serif))
                                .foregroundStyle(.white)

                            if viewModel.hasBehaviorData {
                                BehaviorSparkline(snapshots: viewModel.behaviorSnapshots)

                                Text("Energy peaks are healthy, but calmness dips later in the week hint that \(viewModel.displayPetName) does best when active rituals get a softer landing afterward.")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.76))
                            } else {
                                Text("Bond AI is waiting for real signals")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text("Once you log a few routines, food notes, vaccines, or daily check-ins, Bond AI will shift from setup guidance into real pattern-based insight.")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.76))
                            }
                        }

                        ForEach(viewModel.insights) { insight in
                            GlassCard {
                                HStack(alignment: .top, spacing: 14) {
                                    Image(systemName: insight.systemImage)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(insight.priority.tint)
                                        .frame(width: 46, height: 46)
                                        .background(insight.priority.tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(insight.title)
                                                .font(.system(size: 20, weight: .semibold, design: .serif))
                                                .foregroundStyle(.white)

                                            Spacer()

                                            Text(insight.priority.title)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(insight.priority.tint.opacity(0.95), in: Capsule())
                                        }

                                        Text(insight.detail)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.78))

                                        Text(insight.suggestedAction)
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                            .padding(12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Bond AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(colorScheme.topBarButtonColor)
                }
            }
        }
    }
}
