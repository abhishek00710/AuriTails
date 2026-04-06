import Foundation

struct PetInsightEngine {
    func generateInsights(
        snapshots: [BehaviorSnapshot],
        routines: [RoutineItem],
        foodPreferences: [FoodPreference],
        medications: [MedicationRecord],
        symptoms: [SymptomEntry],
        pet: PetProfile
    ) -> [CompanionInsight] {
        let petName = pet.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? L10n.tr("your pet", default: "your pet")
        : pet.name
        guard !snapshots.isEmpty else {
            return [
                CompanionInsight(
                    title: L10n.tr("Start with one easy rhythm", default: "Start with one easy rhythm"),
                    detail: L10n.format("Once %@'s week has a few logged routines, AuriTails can turn those patterns into calmer suggestions.", default: "Once %@'s week has a few logged routines, AuriTails can turn those patterns into calmer suggestions.", petName),
                    suggestedAction: L10n.tr("Capture meals, a walk, and one recovery ritual first.", default: "Capture meals, a walk, and one recovery ritual first."),
                    priority: .steady,
                    systemImage: "sparkles"
                )
            ]
        }

        let averageCalmness = snapshots.map(\.calmness).average
        let averageAppetite = snapshots.map(\.appetite).average
        let averageSleep = snapshots.map(\.sleepHours).average
        let completionRate = Double(routines.filter(\.isCompleted).count) / Double(max(routines.count, 1))
        let lateHighEnergyRoutine = routines.first { $0.time.hour >= 19 && ($0.category == .training || $0.category == .play) }
        let lowestCalmDay = snapshots.min { $0.calmness < $1.calmness }
        let recentSymptoms = symptoms.filter {
            abs($0.observedAt.timeIntervalSinceNow) <= 60 * 60 * 24 * 5
        }
        let urgentSymptom = recentSymptoms.first { $0.severity == .urgent }
        let moderateSymptoms = recentSymptoms.filter { $0.severity == .moderate }
        let activeMedications = medications.filter { $0.status != .paused }
        let nextMedication = activeMedications.min { $0.nextDose < $1.nextDose }

        var insights: [CompanionInsight] = []

        if let urgentSymptom {
            insights.append(
                CompanionInsight(
                    title: L10n.tr("A fresh symptom needs a closer eye", default: "A fresh symptom needs a closer eye"),
                    detail: L10n.format("%@ logged %@ recently, which makes this a better week for steadier observation than extra experimentation.", default: "%@ logged %@ recently, which makes this a better week for steadier observation than extra experimentation.", petName, urgentSymptom.title.lowercased()),
                    suggestedAction: L10n.tr("Keep routines gentle, note any change in appetite or energy, and follow your vet plan if the symptom lingers or intensifies.", default: "Keep routines gentle, note any change in appetite or energy, and follow your vet plan if the symptom lingers or intensifies."),
                    priority: .watch,
                    systemImage: "cross.case.circle.fill"
                )
            )
        } else if moderateSymptoms.count >= 2 {
            insights.append(
                CompanionInsight(
                    title: L10n.tr("Patterns are stacking in the symptom log", default: "Patterns are stacking in the symptom log"),
                    detail: L10n.format("%@ has had a couple of moderate symptom notes close together, which usually means the week deserves more structure and cleaner context.", default: "%@ has had a couple of moderate symptom notes close together, which usually means the week deserves more structure and cleaner context.", petName),
                    suggestedAction: L10n.tr("Keep meals, meds, and activity timing consistent for a few days so any shift is easier to explain later.", default: "Keep meals, meds, and activity timing consistent for a few days so any shift is easier to explain later."),
                    priority: .watch,
                    systemImage: "waveform.path.ecg.rectangle.fill"
                )
            )
        }

        if let nextMedication,
           nextMedication.nextDose.timeIntervalSinceNow <= 60 * 60 * 18
        {
            insights.append(
                CompanionInsight(
                    title: L10n.tr("Keep the medication rhythm protected", default: "Keep the medication rhythm protected"),
                    detail: L10n.format("%@ has %@ coming up soon, so the clearest read this week will come from keeping food, rest, and observation steady around it.", default: "%@ has %@ coming up soon, so the clearest read this week will come from keeping food, rest, and observation steady around it.", petName, nextMedication.title),
                    suggestedAction: L10n.format("Anchor %@ around %@ and leave a quick note afterward if appetite, calmness, or energy feels different.", default: "Anchor %@ around %@ and leave a quick note afterward if appetite, calmness, or energy feels different.", nextMedication.title, nextMedication.scheduleNote),
                    priority: .steady,
                    systemImage: "pills.fill"
                )
            )
        }

        if let lowestCalmDay, averageCalmness < 0.8 {
            insights.append(
                CompanionInsight(
                    title: L10n.tr("Evening calm dips after stacked stimulation", default: "Evening calm dips after stacked stimulation"),
                    detail: L10n.format("%@ stays bright and engaged, but calmness drops most on %@ after a fuller activity block.", default: "%@ stays bright and engaged, but calmness drops most on %@ after a fuller activity block.", petName, lowestCalmDay.day.title),
                    suggestedAction: L10n.tr("Pair one active evening with a slower lick-mat or sniff session the following night.", default: "Pair one active evening with a slower lick-mat or sniff session the following night."),
                    priority: .watch,
                    systemImage: "moon.zzz.fill"
                )
            )
        }

        if let lateHighEnergyRoutine {
            insights.append(
                CompanionInsight(
                    title: L10n.tr("Move one energetic ritual earlier", default: "Move one energetic ritual earlier"),
                    detail: L10n.format("\"%@\" lands late enough to spill energy into bedtime.", default: "\"%@\" lands late enough to spill energy into bedtime.", lateHighEnergyRoutine.title),
                    suggestedAction: L10n.tr("Try shifting it 30 minutes earlier or swap it onto a calmer day.", default: "Try shifting it 30 minutes earlier or swap it onto a calmer day."),
                    priority: .steady,
                    systemImage: "calendar.badge.clock"
                )
            )
        }

        if averageAppetite < 0.93 || foodPreferences.contains(where: { $0.detail.localizedCaseInsensitiveContains("Chicken") }) {
            insights.append(
                CompanionInsight(
                    title: L10n.tr("Protect the dinner window", default: "Protect the dinner window"),
                    detail: L10n.format("%@'s appetite looks strongest when dinner stays predictable and the protein stays gentle.", default: "%@'s appetite looks strongest when dinner stays predictable and the protein stays gentle.", petName),
                    suggestedAction: L10n.tr("Keep broth dinners before 6:30 PM on high-energy days and limit chicken-heavy extras.", default: "Keep broth dinners before 6:30 PM on high-energy days and limit chicken-heavy extras."),
                    priority: .steady,
                    systemImage: "fork.knife.circle.fill"
                )
            )
        }

        if averageSleep < 11.5 {
            insights.append(
                CompanionInsight(
                    title: L10n.tr("Recovery time needs a little more space", default: "Recovery time needs a little more space"),
                    detail: L10n.tr("Sleep is trending slightly short for the busiest weeks, which can show up later as restlessness or clinginess.", default: "Sleep is trending slightly short for the busiest weeks, which can show up later as restlessness or clinginess."),
                    suggestedAction: L10n.tr("Protect one low-demand evening after trail days or longer fetch sessions.", default: "Protect one low-demand evening after trail days or longer fetch sessions."),
                    priority: .watch,
                    systemImage: "bed.double.fill"
                )
            )
        }

        if completionRate >= 0.35 {
            insights.append(
                CompanionInsight(
                    title: L10n.tr("Your routine consistency is already creating security", default: "Your routine consistency is already creating security"),
                    detail: L10n.tr("Even partial completion is building a reliable rhythm. That stability matters more than perfection.", default: "Even partial completion is building a reliable rhythm. That stability matters more than perfection."),
                    suggestedAction: L10n.tr("Keep the same mealtime anchor and one signature bonding ritual each week.", default: "Keep the same mealtime anchor and one signature bonding ritual each week."),
                    priority: .celebrate,
                    systemImage: "heart.text.square.fill"
                )
            )
        }

        return Array(insights.prefix(4))
    }
}

private extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
