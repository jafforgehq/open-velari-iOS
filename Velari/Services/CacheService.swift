import Foundation
import SwiftData

// MARK: - SwiftData Models

@Model
final class CachedIssue {
    @Attribute(.unique) var issueDate: String
    var issueData: Data
    var generatedDate: String
    var cachedAt: Date

    init(issueDate: String, issueData: Data, generatedDate: String) {
        self.issueDate = issueDate
        self.issueData = issueData
        self.generatedDate = generatedDate
        self.cachedAt = Date()
    }
}

@Model
final class BookmarkedStory {
    @Attribute(.unique) var storyId: String
    var issueDate: String
    var storyData: Data
    var bookmarkedAt: Date

    init(storyId: String, issueDate: String, storyData: Data) {
        self.storyId = storyId
        self.issueDate = issueDate
        self.storyData = storyData
        self.bookmarkedAt = Date()
    }
}

@Model
final class ReadStoryRecord {
    @Attribute(.unique) var storyId: String
    var issueDate: String
    var readAt: Date

    init(storyId: String, issueDate: String) {
        self.storyId = storyId
        self.issueDate = issueDate
        self.readAt = Date()
    }
}

@Model
final class CachedSearchIndex {
    var indexData: Data
    var fetchedAt: Date

    init(indexData: Data) {
        self.indexData = indexData
        self.fetchedAt = Date()
    }
}

// MARK: - Cache Service

@Observable
final class CacheService {
    private let modelContext: ModelContext
    private let encoder = JSONEncoder()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    private let maxCachedIssues = 4

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Issues

    func saveIssue(_ issue: Issue) {
        guard let data = try? encoder.encode(issue) else { return }
        let date = issue.metadata.weekEnd

        let descriptor = FetchDescriptor<CachedIssue>(
            predicate: #Predicate { $0.issueDate == date }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.issueData = data
            existing.generatedDate = issue.metadata.generatedDate
            existing.cachedAt = Date()
        } else {
            let cached = CachedIssue(
                issueDate: date,
                issueData: data,
                generatedDate: issue.metadata.generatedDate
            )
            modelContext.insert(cached)
        }

        evictOldIssues()
        try? modelContext.save()
    }

    func loadLatestIssue() -> Issue? {
        var descriptor = FetchDescriptor<CachedIssue>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        guard let data = try? modelContext.fetch(descriptor).first?.issueData else { return nil }
        return decodeIssue(from: data)
    }

    func loadIssue(date: String) -> Issue? {
        let descriptor = FetchDescriptor<CachedIssue>(
            predicate: #Predicate { $0.issueDate == date }
        )
        guard let data = try? modelContext.fetch(descriptor).first?.issueData else { return nil }
        return decodeIssue(from: data)
    }

    private func decodeIssue(from data: Data) -> Issue? {
        try? decoder.decode(Issue.self, from: data)
    }

    func latestGeneratedDate() -> String? {
        var descriptor = FetchDescriptor<CachedIssue>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.generatedDate
    }

    private func evictOldIssues() {
        let descriptor = FetchDescriptor<CachedIssue>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )
        guard let allIssues = try? modelContext.fetch(descriptor),
              allIssues.count > maxCachedIssues else { return }

        for issue in allIssues.dropFirst(maxCachedIssues) {
            modelContext.delete(issue)
        }
    }

    // MARK: - Bookmarks

    func toggleBookmark(story: Story, issueDate: String) {
        if isBookmarked(storyId: story.id) {
            removeBookmark(storyId: story.id)
        } else {
            addBookmark(story: story, issueDate: issueDate)
        }
    }

    func isBookmarked(storyId: String) -> Bool {
        let descriptor = FetchDescriptor<BookmarkedStory>(
            predicate: #Predicate { $0.storyId == storyId }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }

    func allBookmarkedStoryIDs() -> Set<String> {
        let descriptor = FetchDescriptor<BookmarkedStory>()
        guard let bookmarks = try? modelContext.fetch(descriptor) else { return [] }
        return Set(bookmarks.map(\.storyId))
    }

    func allBookmarks() -> [(story: Story, issueDate: String)] {
        let descriptor = FetchDescriptor<BookmarkedStory>(
            sortBy: [SortDescriptor(\.bookmarkedAt, order: .reverse)]
        )
        guard let bookmarks = try? modelContext.fetch(descriptor) else { return [] }
        return bookmarks.compactMap { bookmark in
            guard let story = try? decoder.decode(Story.self, from: bookmark.storyData) else { return nil }
            return (story: story, issueDate: bookmark.issueDate)
        }
    }

    private func addBookmark(story: Story, issueDate: String) {
        guard let data = try? encoder.encode(story) else { return }
        let bookmark = BookmarkedStory(storyId: story.id, issueDate: issueDate, storyData: data)
        modelContext.insert(bookmark)
        try? modelContext.save()
    }

    func removeBookmark(storyId: String) {
        let descriptor = FetchDescriptor<BookmarkedStory>(
            predicate: #Predicate { $0.storyId == storyId }
        )
        guard let bookmark = try? modelContext.fetch(descriptor).first else { return }
        modelContext.delete(bookmark)
        try? modelContext.save()
    }

    // MARK: - Reading History

    func markAsRead(storyId: String, issueDate: String) {
        guard !isRead(storyId: storyId) else { return }
        let record = ReadStoryRecord(storyId: storyId, issueDate: issueDate)
        modelContext.insert(record)
        try? modelContext.save()
    }

    func markAsUnread(storyId: String) {
        let descriptor = FetchDescriptor<ReadStoryRecord>(
            predicate: #Predicate { $0.storyId == storyId }
        )
        guard let records = try? modelContext.fetch(descriptor) else { return }
        for record in records {
            modelContext.delete(record)
        }
        try? modelContext.save()
    }

    func isRead(storyId: String) -> Bool {
        let descriptor = FetchDescriptor<ReadStoryRecord>(
            predicate: #Predicate { $0.storyId == storyId }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }

    func allReadStoryIDs() -> Set<String> {
        let descriptor = FetchDescriptor<ReadStoryRecord>()
        guard let records = try? modelContext.fetch(descriptor) else { return [] }
        return Set(records.map(\.storyId))
    }

    func clearReadingHistory() {
        let descriptor = FetchDescriptor<ReadStoryRecord>()
        guard let records = try? modelContext.fetch(descriptor) else { return }
        for record in records {
            modelContext.delete(record)
        }
        try? modelContext.save()
    }

    // MARK: - Search Index

    func saveSearchIndex(_ entries: [SearchEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }

        let descriptor = FetchDescriptor<CachedSearchIndex>()
        if let existing = try? modelContext.fetch(descriptor) {
            for item in existing { modelContext.delete(item) }
        }

        modelContext.insert(CachedSearchIndex(indexData: data))
        try? modelContext.save()
    }

    func loadSearchIndex() -> [SearchEntry]? {
        let descriptor = FetchDescriptor<CachedSearchIndex>()
        guard let cached = try? modelContext.fetch(descriptor).first else { return nil }
        return try? JSONDecoder().decode([SearchEntry].self, from: cached.indexData)
    }

    // MARK: - Cache Management

    func clearCache() {
        let issueDescriptor = FetchDescriptor<CachedIssue>()
        let searchDescriptor = FetchDescriptor<CachedSearchIndex>()

        if let issues = try? modelContext.fetch(issueDescriptor) {
            for issue in issues { modelContext.delete(issue) }
        }
        if let indices = try? modelContext.fetch(searchDescriptor) {
            for index in indices { modelContext.delete(index) }
        }
        try? modelContext.save()
    }

    func cacheSize() -> String {
        var totalBytes: Int64 = 0

        let issueDescriptor = FetchDescriptor<CachedIssue>()
        if let issues = try? modelContext.fetch(issueDescriptor) {
            totalBytes += issues.reduce(0) { $0 + Int64($1.issueData.count) }
        }

        let searchDescriptor = FetchDescriptor<CachedSearchIndex>()
        if let indices = try? modelContext.fetch(searchDescriptor) {
            totalBytes += indices.reduce(0) { $0 + Int64($1.indexData.count) }
        }

        let bookmarkDescriptor = FetchDescriptor<BookmarkedStory>()
        if let bookmarks = try? modelContext.fetch(bookmarkDescriptor) {
            totalBytes += bookmarks.reduce(0) { $0 + Int64($1.storyData.count) }
        }

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalBytes)
    }
}
