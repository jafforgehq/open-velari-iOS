import UserNotifications

enum NotificationService {

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

    static func scheduleNewIssueNotification(storyCount: Int, sourceCount: Int) {
        guard UserDefaults.standard.bool(forKey: "notifications_enabled") else { return }

        let content = UNMutableNotificationContent()
        content.title = "New AI Digest Available"
        content.body = "This week's digest is ready — \(storyCount) stories from \(sourceCount) sources."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "new-issue-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // fire immediately
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cleanup

    static func removeAllPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
