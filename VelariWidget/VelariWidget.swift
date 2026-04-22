import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct VelariProvider: TimelineProvider {
    func placeholder(in context: Context) -> VelariEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (VelariEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VelariEntry>) -> Void) {
        let entry = currentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> VelariEntry {
        guard let data = WidgetDataStore.load() else { return .placeholder }
        return VelariEntry(
            date: data.updatedAt,
            issueNumber: data.issueNumber,
            weekEnd: data.weekEnd,
            totalStories: data.totalStories,
            stories: data.topStories
        )
    }
}

// MARK: - Timeline Entry

struct VelariEntry: TimelineEntry {
    let date: Date
    let issueNumber: Int
    let weekEnd: String
    let totalStories: Int
    let stories: [WidgetStory]

    var isPlaceholder: Bool { stories.isEmpty }

    static let placeholder = VelariEntry(
        date: Date(),
        issueNumber: 0,
        weekEnd: "",
        totalStories: 0,
        stories: []
    )
}

// MARK: - Widget Views

struct VelariWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: VelariEntry

    var body: some View {
        switch family {
        case .systemSmall:
            if entry.isPlaceholder { placeholderView } else { smallView }
        case .systemMedium:
            if entry.isPlaceholder { placeholderView } else { mediumView }
        case .systemLarge:
            if entry.isPlaceholder { placeholderView } else { largeView }
        case .accessoryCircular:
            accessoryCircularView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryInline:
            accessoryInlineView
        default:
            if entry.isPlaceholder { placeholderView } else { smallView }
        }
    }

    // MARK: - Accessory (Lock Screen / StandBy)

    private var accessoryInlineView: some View {
        if entry.isPlaceholder {
            Text("Velari — Open app to sync")
        } else {
            Text("Velari #\(entry.issueNumber) — \(entry.totalStories) stories")
        }
    }

    private var accessoryCircularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "newspaper.fill")
                    .font(.caption2)
                Text("\(entry.totalStories)")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.5)
            }
            .widgetAccentable()
        }
    }

    private var accessoryRectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "newspaper.fill")
                    .font(.caption2)
                Text(entry.issueNumber > 0 ? "VELARI #\(entry.issueNumber)" : "VELARI")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .widgetAccentable()
            if entry.isPlaceholder {
                Text("Open the app to load this week's digest.")
                    .font(.caption2)
                    .lineLimit(2)
            } else if let story = entry.stories.first {
                Text(story.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(2)
            }
        }
    }

    // MARK: - Small

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            header
            Spacer(minLength: 0)
            if let story = entry.stories.first {
                Text(story.categoryIcon + " " + story.category.capitalized)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: 0x8B5CF6))
                Text(story.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(3)
                    .foregroundStyle(.primary)
            }
            Spacer(minLength: 0)
            Text("\(entry.totalStories) stories this week")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Medium

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                header
                Spacer()
                Text("\(entry.totalStories) stories")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            ForEach(entry.stories.prefix(3), id: \.id) { story in
                HStack(spacing: 8) {
                    Text(story.categoryIcon)
                        .font(.caption)
                    Text(story.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Spacer()
                    importanceDot(story.importance)
                }
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Large

    private var largeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                header
                Spacer()
                Text("\(entry.totalStories) stories")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Divider()
            ForEach(entry.stories.prefix(5), id: \.id) { story in
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(story.categoryIcon)
                            .font(.caption)
                        Text(story.category.capitalized)
                            .font(.caption2)
                            .foregroundStyle(Color(hex: 0x8B5CF6))
                        Spacer()
                        importanceDot(story.importance)
                    }
                    Text(story.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }
                if story.id != entry.stories.prefix(5).last?.id {
                    Divider()
                }
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Components

    private var header: some View {
        HStack(spacing: 4) {
            Text("VELARI")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: 0x8B5CF6))
            if entry.issueNumber > 0 {
                Text("#\(entry.issueNumber)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "newspaper.fill")
                .font(.title2)
                .foregroundStyle(Color(hex: 0x8B5CF6))
            Text("Open Velari to load\nyour weekly digest")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private func importanceDot(_ importance: Int) -> some View {
        Circle()
            .fill(importanceColor(importance))
            .frame(width: 6, height: 6)
    }

    private func importanceColor(_ score: Int) -> Color {
        switch score {
        case 10: Color(hex: 0xEF4444)
        case 8...9: Color(hex: 0xF59E0B)
        case 6...7: Color(hex: 0xEAB308)
        default: Color(hex: 0x9CA3AF)
        }
    }
}

// MARK: - Color Extension (widget target)

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

// MARK: - Widget Definition

struct VelariWidget: Widget {
    let kind: String = "VelariWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VelariProvider()) { entry in
            VelariWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Velari Digest")
        .description("This week's top AI news stories at a glance.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    VelariWidget()
} timeline: {
    VelariEntry(
        date: .now,
        issueNumber: 13,
        weekEnd: "2026-03-29",
        totalStories: 9,
        stories: [
            WidgetStory(id: "1", title: "AI Policy Framework Gets White House Backing", category: "policy", categoryIcon: "\u{2696}\u{FE0F}", importance: 9)
        ]
    )
}

#Preview("Medium", as: .systemMedium) {
    VelariWidget()
} timeline: {
    VelariEntry(
        date: .now,
        issueNumber: 13,
        weekEnd: "2026-03-29",
        totalStories: 9,
        stories: [
            WidgetStory(id: "1", title: "AI Policy Framework Gets White House Backing", category: "policy", categoryIcon: "\u{2696}\u{FE0F}", importance: 9),
            WidgetStory(id: "2", title: "GPT-5 Benchmark Results Leaked Online", category: "models", categoryIcon: "\u{1F4CA}", importance: 8),
            WidgetStory(id: "3", title: "Open Source LLM Surpasses Commercial Models", category: "open_source", categoryIcon: "\u{1F4E6}", importance: 8)
        ]
    )
}

#Preview("Large", as: .systemLarge) {
    VelariWidget()
} timeline: {
    VelariEntry(
        date: .now,
        issueNumber: 13,
        weekEnd: "2026-03-29",
        totalStories: 9,
        stories: [
            WidgetStory(id: "1", title: "AI Policy Framework Gets White House Backing", category: "policy", categoryIcon: "\u{2696}\u{FE0F}", importance: 9),
            WidgetStory(id: "2", title: "GPT-5 Benchmark Results Leaked Online", category: "models", categoryIcon: "\u{1F4CA}", importance: 8),
            WidgetStory(id: "3", title: "Open Source LLM Surpasses Commercial Models", category: "open_source", categoryIcon: "\u{1F4E6}", importance: 8),
            WidgetStory(id: "4", title: "New Robotics Startup Raises $500M Series A", category: "robotics", categoryIcon: "\u{1F916}", importance: 7),
            WidgetStory(id: "5", title: "DeepMind Publishes Safety Alignment Research", category: "safety", categoryIcon: "\u{1F510}", importance: 7)
        ]
    )
}
