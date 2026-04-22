import BackgroundTasks
import Foundation

enum BackgroundRefreshService {
    static let taskIdentifier = "com.velari.refresh"

    static func registerTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleRefresh(refreshTask)
        }
    }

    static func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        // Workflow publishes Sunday 14:00 UTC; check 1 hour later
        request.earliestBeginDate = nextSunday1500UTC()
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handleRefresh(_ task: BGAppRefreshTask) {
        // Always schedule the next one first
        scheduleRefresh()

        let refreshOperation = Task {
            do {
                let index = try await NetworkService.fetchArchiveIndex()
                let storedLatest = UserDefaults.standard.string(forKey: "lastKnownLatest")

                if index.latest != storedLatest {
                    UserDefaults.standard.set(index.latest, forKey: "lastKnownLatest")
                    _ = try await NetworkService.fetchLatestIssue()
                }

                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            refreshOperation.cancel()
        }
    }

    private static func nextSunday1500UTC() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let now = Date()

        guard let nextSunday = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 15, minute: 0, weekday: 1),
            matchingPolicy: .nextTime
        ) else {
            return now.addingTimeInterval(7 * 24 * 60 * 60)
        }

        return nextSunday
    }
}
