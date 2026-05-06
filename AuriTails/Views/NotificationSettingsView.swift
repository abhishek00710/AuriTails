import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        heroCard
                        routinesCard
                        vaccinesCard
                        medicationsCard
                        memoriesCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var heroCard: some View {
        GlassCard(tone: .lagoon) {
            SectionHeader(
                eyebrow: "Reminder settings",
                title: "Gentle nudges, not noisy alerts",
                detail: "Tune how AuriTails reminds you about routines, vaccine dates, medication timing, and important memory moments."
            )
        }
    }

    private var routinesCard: some View {
        GlassCard(tone: .meadow) {
            ToggleRow(title: "Routine reminders", detail: "Schedule nudges before the next upcoming routine.", isOn: $viewModel.notificationPreferences.routinesEnabled)
            LeadTimePicker(title: "Remind me before", options: [0, 15, 30, 60, 120], unit: "min", selection: $viewModel.notificationPreferences.routineLeadMinutes)
        }
    }

    private var vaccinesCard: some View {
        GlassCard(tone: .apricot) {
            ToggleRow(title: "Vaccine reminders", detail: "Surface due-soon care dates before they sneak up.", isOn: $viewModel.notificationPreferences.vaccinesEnabled)
            LeadTimePicker(title: "Remind me before", options: [0, 1, 3, 7, 14], unit: "day", selection: $viewModel.notificationPreferences.vaccineLeadDays)
        }
    }

    private var memoriesCard: some View {
        GlassCard(tone: .twilight) {
            ToggleRow(title: "Memory reminders", detail: "Celebrate birthdays and gotcha days before they arrive.", isOn: $viewModel.notificationPreferences.memoriesEnabled)
            LeadTimePicker(title: "Remind me before", options: [0, 1, 3, 7], unit: "day", selection: $viewModel.notificationPreferences.memoryLeadDays)
        }
    }

    private var medicationsCard: some View {
        GlassCard(tone: .lagoon) {
            ToggleRow(title: "Medication reminders", detail: "Protect dose timing for active meds and recovery support.", isOn: $viewModel.notificationPreferences.medicationsEnabled)
            LeadTimePicker(title: "Remind me before", options: [0, 15, 30, 60, 120], unit: "min", selection: $viewModel.notificationPreferences.medicationLeadMinutes)
        }
    }
}

private struct ToggleRow: View {
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isOn) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(detail)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                }
            }
            .tint(Color.white.opacity(0.95))
        }
    }
}

private struct LeadTimePicker: View {
    let title: LocalizedStringKey
    let options: [Int]
    let unit: String
    @Binding var selection: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        Text(label(for: option))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(selection == option ? Color(red: 0.12, green: 0.15, blue: 0.22) : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selection == option ? AnyShapeStyle(.white) : AnyShapeStyle(.white.opacity(0.08)), in: Capsule())
                    }
                    .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
                }
            }
        }
    }

    private func label(for option: Int) -> String {
        let localizedUnit = L10n.tr(unit, default: unit)
        if option == 0 { return L10n.tr("At time", default: "At time") }
        if option == 1 { return L10n.format("1 %@", default: "1 %@", localizedUnit) }
        return L10n.format("%d %@s", default: "%d %@s", option, localizedUnit)
    }
}
