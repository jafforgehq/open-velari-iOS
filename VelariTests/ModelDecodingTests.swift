import Testing
import Foundation
@testable import Velari

@Suite("Model Decoding")
struct ModelDecodingTests {
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - Issue

    @Test func decodeIssueFromJSON() throws {
        let json = """
        {
            "metadata": {
                "generated_date": "2026-03-21T12:00:00Z",
                "week_start": "2026-03-17",
                "week_end": "2026-03-21",
                "total_sources_consulted": 25,
                "id": "issue-1",
                "issue_number": 1,
                "is_preview": false,
                "total_stories": 1,
                "model_used": "claude-3"
            },
            "stories": [{
                "id": "s1",
                "title": "Test Story",
                "summary": "Summary text",
                "category": "research",
                "importance": 8,
                "date_published": "2026-03-20",
                "sources": [{
                    "title": "Source Title",
                    "url": "https://example.com",
                    "publisher": "Publisher"
                }],
                "tags": ["ai", "ml"]
            }]
        }
        """.data(using: .utf8)!

        let issue = try decoder.decode(Issue.self, from: json)
        #expect(issue.metadata.issueNumber == 1)
        #expect(issue.metadata.totalSourcesConsulted == 25)
        #expect(issue.metadata.isPreview == false)
        #expect(issue.stories.count == 1)
        #expect(issue.stories[0].title == "Test Story")
        #expect(issue.stories[0].category == .research)
        #expect(issue.stories[0].importance == 8)
        #expect(issue.stories[0].sources.count == 1)
        #expect(issue.stories[0].tags == ["ai", "ml"])
    }

    @Test func storyCleanSummaryStripesCiteTags() {
        let story = TestData.makeStory(summary: "Text <cite>ref</cite> more")
        #expect(story.cleanSummary == "Text ref more")
    }

    @Test func issueIdDerivedFromMetadata() {
        let issue = TestData.makeIssue()
        #expect(issue.id == issue.metadata.id)
    }

    // MARK: - SearchEntry

    @Test func decodeSearchEntry() throws {
        let json = """
        {"t":"Title","s":"Summary","u":"https://example.com","c":"industry","d":"2026-03-20","i":"2026-03-21","n":5}
        """.data(using: .utf8)!

        let entry = try JSONDecoder().decode(SearchEntry.self, from: json)
        #expect(entry.title == "Title")
        #expect(entry.summary == "Summary")
        #expect(entry.issueDate == "2026-03-21")
        #expect(entry.issueNumber == 5)
    }

    // MARK: - ArchiveIndex

    @Test func decodeArchiveIndex() throws {
        let json = """
        {
            "issues": [{
                "id": "a1",
                "date": "2026-03-21",
                "issue_number": 1,
                "total_stories": 10,
                "file": "2026-03-21.json",
                "highlights": ["highlight 1"],
                "is_preview": false
            }],
            "latest": "2026-03-21",
            "total_issues": 1
        }
        """.data(using: .utf8)!

        let index = try decoder.decode(ArchiveIndex.self, from: json)
        #expect(index.totalIssues == 1)
        #expect(index.latest == "2026-03-21")
        #expect(index.issues[0].issueNumber == 1)
        #expect(index.issues[0].highlights == ["highlight 1"])
    }

    // MARK: - ImportanceLevel

    @Test func importanceLevelMapping() {
        #expect(ImportanceLevel(score: 10) == .critical)
        #expect(ImportanceLevel(score: 9) == .high)
        #expect(ImportanceLevel(score: 8) == .high)
        #expect(ImportanceLevel(score: 7) == .medium)
        #expect(ImportanceLevel(score: 6) == .medium)
        #expect(ImportanceLevel(score: 5) == .low)
        #expect(ImportanceLevel(score: 1) == .low)
    }

    @Test func importanceLevelHasNonEmptyLabels() {
        let levels: [ImportanceLevel] = [.critical, .high, .medium, .low]
        for level in levels {
            #expect(!level.label.isEmpty)
        }
    }
}
