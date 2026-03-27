import Foundation

struct ArchiveIndex: Codable, Sendable {
    let issues: [ArchiveIssue]
    let latest: String
    let totalIssues: Int
}

struct ArchiveIssue: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let date: String
    let issueNumber: Int
    let totalStories: Int
    let file: String
    let highlights: [String]
    let isPreview: Bool
}
