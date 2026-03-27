import SwiftUI

struct StoryCardView: View {
    let story: Story
    let issueDate: String
    let isRead: Bool
    @Binding var isBookmarked: Bool
    var onTap: () -> Void
    var onBookmarkTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Tappable content area — triggers navigation
            VStack(alignment: .leading, spacing: 10) {
                // Top row: importance + category + date
                HStack(spacing: 8) {
                    ImportanceBadge(importance: story.importance)
                    CategoryPill(category: story.category)
                    Spacer()
                    Text(DateFormatting.relativeDate(story.datePublished))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                // Title
                Text(story.title)
                    .font(.headline)
                    .lineLimit(3)
                    .foregroundStyle(isRead ? .secondary : .primary)

                // Summary
                Text(story.cleanSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)

                // Source pills
                if !story.sources.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(story.sources, id: \.url) { source in
                                SourcePill(source: source)
                            }
                        }
                    }
                }

                // Tags
                if !story.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(story.tags, id: \.self) { tag in
                                TagChip(tag: tag)
                            }
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }

            // Action bar — buttons handle their own taps, NOT part of navigation
            HStack {
                ShareLink(
                    item: shareText,
                    subject: Text(story.title),
                    message: Text(story.cleanSummary)
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .foregroundStyle(.secondary)

                Spacer()

                if isRead {
                    Label("Read", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Button {
                    HapticService.bookmarkToggle()
                    isBookmarked.toggle()
                    onBookmarkTap()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.subheadline)
                        .foregroundStyle(isBookmarked ? VelariColors.primary : .secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isRead ? 0.75 : 1.0)
    }

    private var shareText: String {
        let url = story.sources.first?.url ?? ""
        return "\(story.title)\n\nRead more: \(url)\n\nShared via Velari - AI News Digest"
    }
}
