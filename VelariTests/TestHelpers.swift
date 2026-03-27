import Foundation
@testable import Velari

enum TestData {
    static func makeSource(
        title: String = "Test Source",
        url: String = "https://example.com/article",
        publisher: String = "Test Publisher"
    ) -> Source {
        Source(title: title, url: url, publisher: publisher)
    }

    static func makeStory(
        id: String = "story-1",
        title: String = "Test Story",
        summary: String = "A test summary",
        category: StoryCategory = .research,
        importance: Int = 7,
        datePublished: String = "2026-03-20",
        sources: [Source] = [makeSource()],
        tags: [String] = ["ai", "test"]
    ) -> Story {
        Story(
            id: id,
            title: title,
            summary: summary,
            category: category,
            importance: importance,
            datePublished: datePublished,
            sources: sources,
            tags: tags
        )
    }

    static func makeMetadata(
        generatedDate: String = "2026-03-21T12:00:00Z",
        weekStart: String = "2026-03-17",
        weekEnd: String = "2026-03-21",
        totalSourcesConsulted: Int = 25,
        id: String = "issue-1",
        issueNumber: Int = 1,
        isPreview: Bool = false,
        totalStories: Int = 5,
        modelUsed: String = "claude-3"
    ) -> IssueMetadata {
        IssueMetadata(
            generatedDate: generatedDate,
            weekStart: weekStart,
            weekEnd: weekEnd,
            totalSourcesConsulted: totalSourcesConsulted,
            id: id,
            issueNumber: issueNumber,
            isPreview: isPreview,
            totalStories: totalStories,
            modelUsed: modelUsed
        )
    }

    static func makeIssue(
        metadata: IssueMetadata? = nil,
        stories: [Story]? = nil
    ) -> Issue {
        Issue(
            metadata: metadata ?? makeMetadata(),
            stories: stories ?? [
                makeStory(id: "s1", category: .research),
                makeStory(id: "s2", category: .industry),
                makeStory(id: "s3", category: .policy),
            ]
        )
    }

    static func makeSearchEntry(
        title: String = "Search Result",
        summary: String = "Search summary",
        url: String = "https://example.com",
        category: String = "research",
        datePublished: String = "2026-03-20",
        issueDate: String = "2026-03-21",
        issueNumber: Int = 1
    ) -> SearchEntry {
        SearchEntry(
            t: title,
            s: summary,
            u: url,
            c: category,
            d: datePublished,
            i: issueDate,
            n: issueNumber
        )
    }
}
