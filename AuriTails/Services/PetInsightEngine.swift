import Foundation

struct PetInsightEngine {
    func generateInsights(
        snapshots: [BehaviorSnapshot],
        routines: [RoutineItem],
        foodPreferences: [FoodPreference],
        pet: PetProfile
    ) -> [CompanionInsight] {
        guard !snapshots.isEmpty else {
            return [
                CompanionInsight(
                    title: "Start with one easy rhythm",
                    detail: "Once \(pet.name)'s week has a few logged routines, AuriTails can turn those patterns into calmer suggestions.",
                    suggestedAction: "Capture meals, a walk, and one recovery ritual first.",
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

        var insights: [CompanionInsight] = []

        if let lowestCalmDay, averageCalmness < 0.8 {
            insights.append(
                CompanionInsight(
                    title: "Evening calm dips after stacked stimulation",
                    detail: "\(pet.name) stays bright and engaged, but calmness drops most on \(lowestCalmDay.day.title) after a fuller activity block.",
                    suggestedAction: "Pair one active evening with a slower lick-mat or sniff session the following night.",
                    priority: .watch,
                    systemImage: "moon.zzz.fill"
                )
            )
        }

        if let lateHighEnergyRoutine {
            insights.append(
                CompanionInsight(
                    title: "Move one energetic ritual earlier",
                    detail: "\"\(lateHighEnergyRoutine.title)\" lands late enough to spill energy into bedtime.",
                    suggestedAction: "Try shifting it 30 minutes earlier or swap it onto a calmer day.",
                    priority: .steady,
                    systemImage: "calendar.badge.clock"
                )
            )
        }

        if averageAppetite < 0.93 || foodPreferences.contains(where: { $0.detail.localizedCaseInsensitiveContains("Chicken") }) {
            insights.append(
                CompanionInsight(
                    title: "Protect the dinner window",
                    detail: "\(pet.name)'s appetite looks strongest when dinner stays predictable and the protein stays gentle.",
                    suggestedAction: "Keep broth dinners before 6:30 PM on high-energy days and limit chicken-heavy extras.",
                    priority: .steady,
                    systemImage: "fork.knife.circle.fill"
                )
            )
        }

        if averageSleep < 11.5 {
            insights.append(
                CompanionInsight(
                    title: "Recovery time needs a little more space",
                    detail: "Sleep is trending slightly short for the busiest weeks, which can show up later as restlessness or clinginess.",
                    suggestedAction: "Protect one low-demand evening after trail days or longer fetch sessions.",
                    priority: .watch,
                    systemImage: "bed.double.fill"
                )
            )
        }

        if completionRate >= 0.35 {
            insights.append(
                CompanionInsight(
                    title: "Your routine consistency is already creating security",
                    detail: "Even partial completion is building a reliable rhythm. That stability matters more than perfection.",
                    suggestedAction: "Keep the same mealtime anchor and one signature bonding ritual each week.",
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
