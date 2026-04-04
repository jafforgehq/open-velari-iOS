import Foundation

// MARK: - App Group

enum AppGroup {
    static let identifier = "group.com.jafforge.Velari"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    static var widgetDataURL: URL? {
        containerURL?.appendingPathComponent("widget_data.json")
    }
}

// MARK: - Lightweight widget models (no SwiftData dependency)

struct WidgetStory: Codable {
    let id: String
    let title: String
    let category: String
    let categoryIcon: String
    let importance: Int
}

struct WidgetIssueData: Codable {
    let issueNumber: Int
    let weekEnd: String
    let totalStories: Int
    let topStories: [WidgetStory]
    let updatedAt: Date
}

// MARK: - Read / Write

enum WidgetDataStore {
    static func save(_ data: WidgetIssueData) {
        guard let url = AppGroup.widgetDataURL else { return }
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        try? encoded.write(to: url, options: .atomic)
    }

    static func load() -> WidgetIssueData? {
        guard let url = AppGroup.widgetDataURL else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(WidgetIssueData.self, from: data)
    }
}
