import SwiftUI

enum StoryCategory: String, Codable, CaseIterable, Identifiable {
    case research
    case industry
    case policy
    case tools
    case openSource = "open_source"
    case safety
    case robotics
    case healthcare
    case models

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .research: "Research & Breakthroughs"
        case .industry: "Industry & Business"
        case .policy: "Policy & Regulation"
        case .tools: "Tools & Developer"
        case .openSource: "Open Source"
        case .safety: "AI Safety & Alignment"
        case .robotics: "Robotics & Hardware"
        case .healthcare: "Healthcare & Science"
        case .models: "Models & Benchmarks"
        }
    }

    var shortName: String {
        switch self {
        case .research: "Research"
        case .industry: "Industry"
        case .policy: "Policy"
        case .tools: "Tools"
        case .openSource: "Open Source"
        case .safety: "Safety"
        case .robotics: "Robotics"
        case .healthcare: "Healthcare"
        case .models: "Models"
        }
    }

    var icon: String {
        switch self {
        case .research: "\u{1F52C}"
        case .industry: "\u{1F4BC}"
        case .policy: "\u{2696}\u{FE0F}"
        case .tools: "\u{1F6E0}\u{FE0F}"
        case .openSource: "\u{1F4E6}"
        case .safety: "\u{1F510}"
        case .robotics: "\u{1F916}"
        case .healthcare: "\u{1F3E5}"
        case .models: "\u{1F4CA}"
        }
    }

    var systemImage: String {
        switch self {
        case .research: "microscope"
        case .industry: "briefcase.fill"
        case .policy: "building.columns.fill"
        case .tools: "wrench.and.screwdriver.fill"
        case .openSource: "shippingbox.fill"
        case .safety: "lock.shield.fill"
        case .robotics: "cpu.fill"
        case .healthcare: "cross.case.fill"
        case .models: "chart.bar.fill"
        }
    }
}
