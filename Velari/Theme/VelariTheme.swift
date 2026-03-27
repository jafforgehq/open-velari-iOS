import SwiftUI

enum VelariColors {
    static let primary = Color(hex: 0x8B5CF6)
    static let primaryVariant = Color(hex: 0x7C3AED)

    static let lightBackground = Color.white
    static let darkBackground = Color(hex: 0x0F0F0F)

    static let lightSurface = Color(hex: 0xF8F8F8)
    static let darkSurface = Color(hex: 0x1A1A1A)

    static let error = Color(hex: 0xEF4444)
    static let warning = Color(hex: 0xF59E0B)
    static let mediumImportance = Color(hex: 0xEAB308)
    static let lowImportance = Color(hex: 0x9CA3AF)
}

enum ImportanceLevel {
    case critical
    case high
    case medium
    case low

    init(score: Int) {
        switch score {
        case 10: self = .critical
        case 8...9: self = .high
        case 6...7: self = .medium
        default: self = .low
        }
    }

    var color: Color {
        switch self {
        case .critical: VelariColors.error
        case .high: VelariColors.warning
        case .medium: VelariColors.mediumImportance
        case .low: VelariColors.lowImportance
        }
    }

    var label: String {
        switch self {
        case .critical: "Critical"
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        }
    }
}

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
