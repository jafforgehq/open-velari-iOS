import SwiftUI

struct CategoryPill: View {
    let category: StoryCategory
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Text(category.icon)
                .font(.caption2)
            Text(category.shortName)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isSelected ? VelariColors.primary : Color(.systemGray5))
        .foregroundStyle(isSelected ? .white : .primary)
        .clipShape(Capsule())
        .accessibilityLabel("Category: \(category.displayName)")
    }
}
