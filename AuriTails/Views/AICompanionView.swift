import Charts
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

                                Button {
                                    viewModel.openBehaviorCheckIn()
                                } label: {
                                    Label("Log daily check-in", systemImage: "plus.circle.fill")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.white, in: Capsule())
                                }
                                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
                            }
                        }

                        GlassCard(tone: .twilight) {
                            SectionHeader(
                                eyebrow: "Health trends",
                                title: "What the care pattern is doing over time",
                                detail: "This is where Bond AI reads movement across weight, weekly behavior, and symptom intensity instead of looking at isolated entries."
                            )

                            if viewModel.hasWeightData {
                                AITrendPanel(title: "Weight arc", subtitle: viewModel.weightTrendSummary) {
                                    WeightTrendChart(entries: viewModel.recentWeightEntries, unit: viewModel.preferredWeightUnit)

                                    if let latestWeightEntry = viewModel.latestWeightEntry {
                                        HStack(spacing: 12) {
                                            StatChip(title: "Latest", value: latestWeightEntry.valueLabel, fillsWidth: false)
                                            StatChip(title: "Logs", value: "\(viewModel.recentWeightEntries.count)", fillsWidth: false)
                                        }
                                    }

                                    LazyVStack(spacing: 10) {
                                        ForEach(viewModel.recentWeightEntries.suffix(3).reversed()) { entry in
                                            Button {
                                                viewModel.openWeightEntryEditor(entry.id)
                                            } label: {
                                                HStack(spacing: 12) {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(entry.valueLabel)
                                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                                            .foregroundStyle(.white)
                                                        Text(entry.loggedLabel)
                                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                                            .foregroundStyle(.white.opacity(0.62))
                                                    }

                                                    Spacer(minLength: 12)

                                                    if !entry.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                        Text(entry.note)
                                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                                            .foregroundStyle(.white.opacity(0.70))
                                                            .multilineTextAlignment(.trailing)
                                                            .lineLimit(2)
                                                    }

                                                    Image(systemName: "pencil.circle.fill")
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundStyle(.white.opacity(0.72))
                                                }
                                                .padding(12)
                                                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            }
                                            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97))
                                        }
                                    }
                                }
                            } else {
                                AIEmptyTrendPanel(
                                    title: "Weight arc",
                                    detail: "Add the first weigh-in and Bond AI will start watching whether the body picture is holding steady, drifting, or recovering.",
                                    buttonTitle: "Add weight",
                                    systemImage: "scalemass.fill"
                                ) {
                                    viewModel.openWeightEntryEditor()
                                }
                            }

                            if viewModel.hasBehaviorData {
                                AITrendPanel(
                                    title: "Behavior rhythm",
                                    subtitle: "Energy, calmness, appetite, and sleep become easier to compare once the week is visible as one shape."
                                ) {
                                    WeeklyBehaviorTrendChart(snapshots: viewModel.behaviorSnapshots)
                                }
                            } else {
                                AIEmptyTrendPanel(
                                    title: "Behavior rhythm",
                                    detail: "Log daily check-ins and this chart will start tracing calmness, appetite, sleep, and energy across the week.",
                                    buttonTitle: "Log check-in",
                                    systemImage: "waveform.path.ecg"
                                ) {
                                    viewModel.openBehaviorCheckIn()
                                }
                            }

                            if viewModel.hasSymptomData {
                                AITrendPanel(
                                    title: "Symptom intensity",
                                    subtitle: "Severity counts help Bond AI tell the difference between light noise and a week that deserves closer observation."
                                ) {
                                    SymptomSeverityChart(counts: viewModel.recentSymptomCounts)
                                }
                            } else {
                                AIEmptyTrendPanel(
                                    title: "Symptom intensity",
                                    detail: "Add symptom notes when something feels off and Bond AI will start showing whether the log is mostly mild or worth closer watch.",
                                    buttonTitle: "Add symptom",
                                    systemImage: "exclamationmark.triangle.fill"
                                ) {
                                    viewModel.openSymptomEditor()
                                }
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

private struct AITrendPanel<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct AIEmptyTrendPanel: View {
    let title: String
    let detail: String
    let buttonTitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text(detail)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))

            Button(action: action) {
                Label(buttonTitle, systemImage: systemImage)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white, in: Capsule())
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct WeightTrendChart: View {
    let entries: [WeightEntry]
    let unit: WeightUnit

    var body: some View {
        Chart(entries) { entry in
            LineMark(
                x: .value("Date", entry.loggedAt),
                y: .value("Weight", entry.displayValue(in: unit))
            )
            .foregroundStyle(Color.white)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

            AreaMark(
                x: .value("Date", entry.loggedAt),
                y: .value("Weight", entry.displayValue(in: unit))
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.white.opacity(0.34), Color.white.opacity(0.04)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            PointMark(
                x: .value("Date", entry.loggedAt),
                y: .value("Weight", entry.displayValue(in: unit))
            )
            .foregroundStyle(Color.white)
            .symbolSize(36)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: min(max(entries.count, 2), 4))) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.08))
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month(.abbreviated).day())
                    }
                }
                .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.08))
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text("\(amount.formatted(.number.precision(.fractionLength(1)))) \(unit.shortLabel)")
                    }
                }
                .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartPlotStyle { plot in
            plot
                .background(.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .frame(height: 210)
    }
}

private struct WeeklyBehaviorTrendChart: View {
    let snapshots: [BehaviorSnapshot]

    var body: some View {
        Chart {
            ForEach(snapshots) { snapshot in
                LineMark(
                    x: .value("Day", snapshot.day.shortTitle),
                    y: .value("Energy", snapshot.energy * 100)
                )
                .foregroundStyle(PaletteTone.apricot.primaryColor)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                LineMark(
                    x: .value("Day", snapshot.day.shortTitle),
                    y: .value("Calmness", snapshot.calmness * 100)
                )
                .foregroundStyle(PaletteTone.lagoon.secondaryColor)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                LineMark(
                    x: .value("Day", snapshot.day.shortTitle),
                    y: .value("Appetite", snapshot.appetite * 100)
                )
                .foregroundStyle(PaletteTone.meadow.secondaryColor)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                BarMark(
                    x: .value("Day", snapshot.day.shortTitle),
                    y: .value("Sleep", min(max((snapshot.sleepHours / 14) * 100, 0), 100))
                )
                .foregroundStyle(PaletteTone.twilight.secondaryColor.opacity(0.40))
                .cornerRadius(8)
            }
        }
        .chartLegend(position: .bottom, alignment: .leading) {
            HStack(spacing: 12) {
                TrendLegend(color: PaletteTone.apricot.primaryColor, title: "Energy")
                TrendLegend(color: PaletteTone.lagoon.secondaryColor, title: "Calm")
                TrendLegend(color: PaletteTone.meadow.secondaryColor, title: "Appetite")
                TrendLegend(color: PaletteTone.twilight.secondaryColor, title: "Sleep score")
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.08))
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartPlotStyle { plot in
            plot
                .background(.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .frame(height: 240)
    }
}

private struct SymptomSeverityChart: View {
    let counts: [(severity: SymptomSeverity, count: Int)]

    var body: some View {
        Chart(counts, id: \.severity.id) { item in
            BarMark(
                x: .value("Severity", item.severity.title),
                y: .value("Count", item.count)
            )
            .foregroundStyle(color(for: item.severity))
            .cornerRadius(12)
            .annotation(position: .top) {
                Text("\(item.count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.08))
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartPlotStyle { plot in
            plot
                .background(.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .frame(height: 180)
    }

    private func color(for severity: SymptomSeverity) -> Color {
        switch severity {
        case .mild: return PaletteTone.meadow.secondaryColor
        case .moderate: return PaletteTone.apricot.primaryColor
        case .urgent: return Color(red: 0.95, green: 0.52, blue: 0.45)
        }
    }
}

private struct TrendLegend: View {
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
        }
    }
}
