import UserNotifications

enum NotificationService {

    private static let weeklyReminderIdentifier = "weekly-reminder"

    // MARK: - Permission

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func isSystemPermissionGranted() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // MARK: - Scheduling

    /// Schedules a repeating local notification for Sunday 15:00 UTC (one hour after OpenVelari
    /// publishes). Guaranteed to fire regardless of whether the BGAppRefreshTask gets a slot from
    /// iOS — which for a weekly app it often won't.
    static func scheduleWeeklyReminder() {
        guard UserDefaults.standard.bool(forKey: "notifications_enabled") else { return }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [weeklyReminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "New AI Digest"
        content.body = "This week's digest is ready to read."
        content.sound = .default

        var components = DateComponents()
        components.weekday = 1
        components.hour = 15
        components.minute = 0
        components.timeZone = TimeZone(identifier: "UTC")

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: weeklyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    static func cancelWeeklyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [weeklyReminderIdentifier])
    }

    // MARK: - Cleanup

    static func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
