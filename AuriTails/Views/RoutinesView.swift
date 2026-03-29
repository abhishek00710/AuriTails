import SwiftUI

struct RoutinesView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                summaryCard

                GlassCard {
                    SectionHeader(
                        eyebrow: "Week view",
                        title: "Schedule and re-schedule with less friction",
                        detail: "Pick a day, nudge the time, or move a ritual to another day without rebuilding it."
                    )

                    WeekdayPicker(
                        selection: Binding(
                            get: { viewModel.selectedDay },
                            set: { viewModel.selectedDay = $0 }
                        )
                    )
                }

                if viewModel.selectedDayRoutines.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.selectedDayRoutines) { routine in
                            routineCard(routine)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
    }

    private var summaryCard: some View {
        GlassCard(tone: .meadow) {
            SectionHeader(
                eyebrow: "Weekly rhythm",
                title: "A routine engine that feels human",
                detail: "Most pet apps stop at reminders. This one lets the week breathe and still stay intentional."
            )

            HStack(spacing: 12) {
                StatChip(title: "Completed", value: "\(Int((viewModel.weeklyCompletionRatio * 100).rounded()))%")
                StatChip(title: "Selected day", value: viewModel.selectedDay.title)
            }
        }
    }

    private func routineCard(_ routine: RoutineItem) -> some View {
        GlassCard(tone: routine.tone) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: routine.systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                    .frame(width: 52, height: 52)
                    .background(routine.tone.secondaryColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(routine.title)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        Spacer()

                        Button {
                            viewModel.toggleRoutine(routine.id)
                        } label: {
                            Image(systemName: routine.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.88, pressedBrightness: 0.08))
                    }

                    Text(routine.subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))

                    HStack(spacing: 10) {
                        Label(routine.time.label, systemImage: "clock.fill")
                        Label(routine.durationLabel, systemImage: "timer")
                        Text(routine.day.shortTitle)
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))
                }
            }

            HStack(spacing: 10) {
                Button {
                    viewModel.shiftRoutine(routine.id, by: -30)
                } label: {
                    Label("-30m", systemImage: "arrow.left.circle.fill")
                }

                Button {
                    viewModel.shiftRoutine(routine.id, by: 30)
                } label: {
                    Label("+30m", systemImage: "arrow.right.circle.fill")
                }

                Menu {
                    ForEach(Weekday.allCases) { day in
                        Button(day.title) {
                            viewModel.rescheduleRoutine(routine.id, to: day)
                        }
                    }
                } label: {
                    Label("Re-schedule", systemImage: "calendar.badge.clock")
                }
            }
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.93, pressedBrightness: 0.06))
            .padding(12)
            .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var emptyState: some View {
        GlassCard(tone: .twilight) {
            Text("No rituals scheduled for \(viewModel.selectedDay.title) yet.")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text("That empty space can be intentional too. Use it as a recovery day, memory day, or just a softer rhythm.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))
        }
    }
}
