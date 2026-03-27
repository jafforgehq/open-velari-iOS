import Foundation

@Observable
final class HomeViewModel {
    private let repository: DigestRepository

    var currentIssue: Issue?
    var selectedCategory: StoryCategory?
    var isLoading = false
    var isRefreshing = false
    var errorMessage: String?

    // Bumped on bookmark/read changes to trigger SwiftUI re-render
    private var stateVersion = 0

    var filteredStories: [Story] {
        guard let stories = currentIssue?.stories else { return [] }
        guard let category = selectedCategory else { return stories }
        return stories.filter { $0.category == category }
    }

    init(repository: DigestRepository) {
        self.repository = repository
    }

    func loadLatestIssue() async {
        guard currentIssue == nil else { return }
        isLoading = true
        defer { isLoading = false }

        currentIssue = await repository.loadLatestIssue()
        errorMessage = repository.error
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }

        if let issue = await repository.refreshLatest() {
            currentIssue = issue
        }
        errorMessage = repository.error
    }

    func isRead(storyId: String) -> Bool {
        _ = stateVersion
        return repository.cache.isRead(storyId: storyId)
    }

    func isBookmarked(storyId: String) -> Bool {
        _ = stateVersion
        return repository.cache.isBookmarked(storyId: storyId)
    }

    func toggleBookmark(story: Story) {
        guard let issueDate = currentIssue?.metadata.weekEnd else { return }
        repository.cache.toggleBookmark(story: story, issueDate: issueDate)
        stateVersion += 1
    }

    func markAsRead(story: Story) {
        guard let issueDate = currentIssue?.metadata.weekEnd else { return }
        repository.cache.markAsRead(storyId: story.id, issueDate: issueDate)
        stateVersion += 1
    }
}
