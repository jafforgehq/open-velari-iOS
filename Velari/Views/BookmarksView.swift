import SwiftUI

struct BookmarksView: View {
    let cache: CacheService
    @State private var viewModel: BookmarksViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    bookmarksContent(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Saved")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = BookmarksViewModel(cache: cache)
            }
            viewModel?.loadBookmarks()
        }
    }

    @ViewBuilder
    private func bookmarksContent(_ vm: BookmarksViewModel) -> some View {
        if vm.bookmarks.isEmpty {
            EmptyStateView(
                systemImage: "bookmark",
                title: "No Saved Stories",
                subtitle: "Tap the bookmark icon on any story to save it."
            )
        } else {
            List {
                ForEach(vm.bookmarks, id: \.story.id) { item in
                    NavigationLink {
                        StoryDetailView(
                            story: item.story,
                            issueDate: item.issueDate,
                            modelUsed: "AI",
                            cache: cache
                        )
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                ImportanceBadge(importance: item.story.importance)
                                CategoryPill(category: item.story.category)
                            }

                            Text(item.story.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(2)

                            Text(item.story.cleanSummary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { offsets in
                    vm.removeBookmark(at: offsets)
                }
            }
            .listStyle(.plain)
        }
    }
}
