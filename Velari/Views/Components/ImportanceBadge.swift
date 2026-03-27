import SwiftUI

struct ImportanceBadge: View {
    let importance: Int

    private var level: ImportanceLevel {
        ImportanceLevel(score: importance)
    }

    var body: some View {
        Text("\(importance)/10")
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(level.color.opacity(0.15))
            .foregroundStyle(level.color)
            .clipShape(Capsule())
            .accessibilityLabel("Importance: \(importance) out of 10, \(level.label)")
    }
}
