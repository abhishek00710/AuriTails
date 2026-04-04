import Combine
import SwiftUI

struct MemoriesView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedSlide = 0
    private let timer = Timer.publish(every: 4.2, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                heroCard

                TabView(selection: $selectedSlide) {
                    ForEach(Array(viewModel.featuredMemories.prefix(4).enumerated()), id: \.element.id) { index, memory in
                        MemoryPostcard(memory: memory)
                            .padding(.horizontal, 2)
                            .tag(index)
                    }
                }
                .frame(height: 310)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .onReceive(timer) { _ in
                    let count = min(viewModel.featuredMemories.count, 4)
                    guard count > 0 else { return }
                    withAnimation(.easeInOut(duration: 0.8)) {
                        selectedSlide = (selectedSlide + 1) % count
                    }
                }

                timelineCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
    }

    private var heroCard: some View {
        GlassCard(tone: .twilight) {
            HStack(alignment: .top, spacing: 12) {
                SectionHeader(
                    eyebrow: "Slideshow",
                    title: "A keepsake space, not just a gallery",
                    detail: "Important dates become narrative moments with atmosphere, not isolated photos lost in a library."
                )

                Spacer(minLength: 0)

                Button {
                    viewModel.openMemoryEditor()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
            }

            if let next = viewModel.nextCelebration {
                HStack(spacing: 14) {
                    Image(systemName: next.systemImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                        .frame(width: 54, height: 54)
                        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(next.title)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(next.detail)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.74))
                    }

                    Spacer()
                }
            }
        }
    }

    private var timelineCard: some View {
        GlassCard {
            SectionHeader(
                eyebrow: "Timeline",
                title: "The story of us",
                detail: "The best pet products rarely make space for emotion. This one treats it like a first-class feature."
            )

            VStack(spacing: 16) {
                ForEach(viewModel.memoryTimeline) { memory in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: memory.systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(memory.tone.secondaryColor)
                            .frame(width: 38, height: 38)
                            .background(memory.tone.primaryColor.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(memory.title)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(memory.dateLabel)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                            Text(memory.caption)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))
                        }

                        Spacer()

                        Button {
                            viewModel.openMemoryEditor(memory.id)
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.72))
                        }
                        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))

                        Button {
                            viewModel.toggleMemoryNotifications(memory.id)
                        } label: {
                            Image(systemName: memory.notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.72))
                        }
                        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                    }
                }
            }
        }
    }
}
