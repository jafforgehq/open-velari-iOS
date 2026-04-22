import SwiftUI

struct IssueView: View {
    let archiveIssue: ArchiveIssue
    let repository: DigestRepository

    @State private var issue: Issue?
    @State private var isLoading = true
    @State private var selectedCategory: StoryCategory?
    @State private var selectedStory: Story?
    @State private var bookmarkedStoryIDs: Set<String> = []
    @State private var readStoryIDs: Set<String> = []

    private var filteredStories: [Story] {
        guard let stories = issue?.stories else { return [] }
        guard let category = selectedCategory else { return stories }
        return stories.filter { $0.category == category }
    }

    var body: some View {
        Group {
            if isLoading && issue == nil {
                ProgressView()
            } else if let issue {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        DisclaimerBanner()

                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text(DateFormatting.weekRange(
                                start: issue.metadata.weekStart,
                                end: issue.metadata.weekEnd
                            ))
                            .font(.subheadline)
                            .fontWeight(.semibold)

                            Text("\(issue.metadata.totalStories) stories from \(issue.metadata.totalSourcesConsulted) sources")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)

                        // Category filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button {
                                    selectedCategory = nil
                                } label: {
                                    Text("All")
                                        .font(.caption)
                                        .fontWeight(selectedCategory == nil ? .semibold : .regular)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedCategory == nil ? VelariColors.primary : Color(.systemGray5))
                                        .foregroundStyle(selectedCategory == nil ? .white : .primary)
                                        .clipShape(Capsule())
                                }

                                ForEach(StoryCategory.allCases) { category in
                                    Button {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    } label: {
                                        CategoryPill(
                                            category: category,
                                            isSelected: selectedCategory == category
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)

                        // Stories
                        LazyVStack(spacing: 12) {
                            ForEach(filteredStories) { story in
                                StoryCardView(
                                    story: story,
                                    issueDate: issue.metadata.weekEnd,
                                    isRead: readStoryIDs.contains(story.id),
                                    isBookmarked: Binding(
                                        get: { bookmarkedStoryIDs.contains(story.id) },
                                        set: { newValue in
                                            if newValue {
                                                bookmarkedStoryIDs.insert(story.id)
                                            } else {
                                                bookmarkedStoryIDs.remove(story.id)
                                            }
                                        }
                                    ),
                                    onTap: { selectedStory = story },
                                    onBookmarkTap: {
                                        repository.cache.toggleBookmark(story: story, issueDate: issue.metadata.weekEnd)
                                    },
                                    onToggleRead: {
                                        HapticService.bookmarkToggle()
                                        if readStoryIDs.contains(story.id) {
                                            repository.cache.markAsUnread(storyId: story.id)
                                        } else {
                                            repository.cache.markAsRead(storyId: story.id, issueDate: issue.metadata.weekEnd)
                                        }
                                        syncBookmarkedIDs()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                }
                .navigationDestination(item: $selectedStory) { story in
                    StoryDetailView(
                        story: story,
                        issueDate: issue.metadata.weekEnd,
                        modelUsed: issue.metadata.modelUsed,
                        cache: repository.cache
                    )
                }
            } else {
                EmptyStateView(
                    systemImage: "exclamationmark.triangle",
                    title: "Unable to Load Issue",
                    subtitle: "Check your connection and try again."
                )
            }
        }
        .navigationTitle((archiveIssue.isPreview ?? false) ? "Preview" : "Issue #\(archiveIssue.issueNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let date = archiveIssue.date
            issue = await repository.loadIssue(date: date)
            isLoading = false
            syncBookmarkedIDs()
        }
        .onChange(of: selectedStory) { _, newValue in
            if newValue == nil {
                syncBookmarkedIDs()
            }
        }
    }

    private func syncBookmarkedIDs() {
        bookmarkedStoryIDs = repository.cache.allBookmarkedStoryIDs()
        readStoryIDs = repository.cache.allReadStoryIDs()
    }
}
