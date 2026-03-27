import SwiftUI

struct TagChip: View {
    let tag: String
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            Text(tag)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .foregroundStyle(.secondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }
}
