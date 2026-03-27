import SwiftUI

@Observable
final class BookmarksViewModel {
    private let cache: CacheService

    var bookmarks: [(story: Story, issueDate: String)] = []

    init(cache: CacheService) {
        self.cache = cache
    }

    func loadBookmarks() {
        bookmarks = cache.allBookmarks()
    }

    func removeBookmark(at offsets: IndexSet) {
        for index in offsets {
            cache.removeBookmark(storyId: bookmarks[index].story.id)
        }
        bookmarks.remove(atOffsets: offsets)
    }
}
