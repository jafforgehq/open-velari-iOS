import SwiftUI
import SwiftData

@main
struct VelariApp: App {
    @AppStorage("theme") private var theme = "system"

    init() {
        BackgroundRefreshService.registerTask()
        // Default notifications_enabled to true if never set
        if UserDefaults.standard.object(forKey: "notifications_enabled") == nil {
            UserDefaults.standard.set(true, forKey: "notifications_enabled")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
                .onAppear {
                    BackgroundRefreshService.scheduleRefresh()
                    NotificationService.scheduleWeeklyReminder()
                    NotificationService.clearBadge()
                }
        }
        .modelContainer(for: [
            CachedIssue.self,
            BookmarkedStory.self,
            ReadStoryRecord.self,
            CachedSearchIndex.self
        ])
    }

    private var colorScheme: ColorScheme? {
        switch theme {
        case "dark": .dark
        case "light": .light
        default: nil
        }
    }
}
