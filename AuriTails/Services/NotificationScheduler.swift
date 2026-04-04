import Foundation
import UserNotifications

struct NotificationScheduler {
    private let center: UNUserNotificationCenter
    private let calendar: Calendar

    init(
        center: UNUserNotificationCenter = .current(),
        calendar: Calendar = .current
    ) {
        self.center = center
        self.calendar = calendar
    }

    func requestAuthorizationIfNeeded() async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func refreshNotifications(for state: PersistedAppState) async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }

        let identifiers = await pendingIdentifiers()
        let managedIdentifiers = identifiers.filter { $0.hasPrefix("auritails.") }
        center.removePendingNotificationRequests(withIdentifiers: managedIdentifiers)

        let requests = buildRequests(for: state)
        for request in requests.prefix(48) {
            try? await center.add(request)
        }
    }

    private func pendingIdentifiers() async -> [String] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests.map(\.identifier))
            }
        }
    }

    private func buildRequests(for state: PersistedAppState) -> [UNNotificationRequest] {
        routineRequests(for: state) + vaccineRequests(for: state) + memoryRequests(for: state)
    }

    private func routineRequests(for state: PersistedAppState) -> [UNNotificationRequest] {
        guard state.notificationPreferences.routinesEnabled else { return [] }
        return state.routines.compactMap { routine in
            guard routine.notificationsEnabled else { return nil }
            guard let nextDate = nextDate(for: routine.day, time: routine.time) else { return nil }
            let fireDate = calendar.date(byAdding: .minute, value: -state.notificationPreferences.routineLeadMinutes, to: nextDate) ?? nextDate
            guard fireDate > .now else { return nil }

            let content = UNMutableNotificationContent()
            content.title = "\(state.pet.name)'s \(routine.title)"
            content.body = routine.subtitle
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            return UNNotificationRequest(
                identifier: "auritails.routine.\(routine.id.uuidString)",
                content: content,
                trigger: trigger
            )
        }
    }

    private func vaccineRequests(for state: PersistedAppState) -> [UNNotificationRequest] {
        guard state.notificationPreferences.vaccinesEnabled else { return [] }
        return state.vaccinations.compactMap { vaccine in
            guard vaccine.notificationsEnabled else { return nil }
            let dueDate = calendar.startOfDay(for: vaccine.nextDue)
            guard dueDate >= calendar.startOfDay(for: .now) else { return nil }

            let leadDate = calendar.date(byAdding: .day, value: -state.notificationPreferences.vaccineLeadDays, to: dueDate) ?? dueDate
            let fireDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: leadDate) ?? leadDate
            guard fireDate > .now else { return nil }
            let content = UNMutableNotificationContent()
            content.title = "\(vaccine.title) due soon"
            content.body = "Wellness passport reminder for \(state.pet.name). \(vaccine.note)"
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            return UNNotificationRequest(
                identifier: "auritails.vaccine.\(vaccine.id.uuidString)",
                content: content,
                trigger: trigger
            )
        }
    }

    private func memoryRequests(for state: PersistedAppState) -> [UNNotificationRequest] {
        guard state.notificationPreferences.memoriesEnabled else { return [] }
        return state.memories.compactMap { memory in
            guard memory.isAnnualCelebration,
                  memory.notificationsEnabled,
                  let celebrationDate = nextCelebrationDate(for: memory.date)
            else { return nil }
            let fireDate = calendar.date(byAdding: .day, value: -state.notificationPreferences.memoryLeadDays, to: celebrationDate) ?? celebrationDate
            guard fireDate > .now else { return nil }

            let content = UNMutableNotificationContent()
            content.title = memory.title
            content.body = "A memory moment for \(state.owner.name) and \(state.pet.name): \(memory.caption)"
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            return UNNotificationRequest(
                identifier: "auritails.memory.\(memory.id.uuidString)",
                content: content,
                trigger: trigger
            )
        }
    }

    private func nextDate(for day: Weekday, time: ClockTime) -> Date? {
        let now = Date()
        let targetWeekday = systemWeekday(for: day)
        var components = DateComponents()
        components.weekday = targetWeekday
        components.hour = time.hour
        components.minute = time.minute

        return calendar.nextDate(
            after: now.addingTimeInterval(-60),
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )
    }

    private func nextCelebrationDate(for originalDate: Date) -> Date? {
        let month = calendar.component(.month, from: originalDate)
        let day = calendar.component(.day, from: originalDate)
        let now = Date()
        let currentYear = calendar.component(.year, from: now)

        for year in [currentYear, currentYear + 1] {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            components.hour = 10
            components.minute = 0
            if let candidate = calendar.date(from: components), candidate >= now {
                return candidate
            }
        }

        return nil
    }

    private func systemWeekday(for weekday: Weekday) -> Int {
        switch weekday {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}
