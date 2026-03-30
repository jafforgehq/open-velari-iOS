import Foundation

struct Issue: Codable, Identifiable, Hashable, Sendable {
    let metadata: IssueMetadata
    let stories: [Story]

    var id: String { metadata.id }
}

struct IssueMetadata: Codable, Hashable, Sendable {
    let generatedDate: String
    let weekStart: String
    let weekEnd: String
    let totalSourcesConsulted: Int
    let id: String
    let issueNumber: Int
    let isPreview: Bool?
    let totalStories: Int
    let modelUsed: String
}

struct Story: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let summary: String
    let category: StoryCategory
    let importance: Int
    let datePublished: String
    let sources: [Source]
    let tags: [String]

    var cleanSummary: String {
        summary.strippedOfCiteTags
    }
}

struct Source: Codable, Hashable, Sendable {
    let title: String
    let url: String
    let publisher: String
}
