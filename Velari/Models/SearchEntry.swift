import Foundation

struct SearchEntry: Codable, Identifiable, Sendable {
    let t: String
    let s: String
    let u: String
    let c: String
    let d: String
    let i: String
    let n: Int

    var id: String { "\(i)-\(t)" }

    var title: String { t }
    var summary: String { s }
    var sourceURL: String { u }
    var category: String { c }
    var datePublished: String { d }
    var issueDate: String { i }
    var issueNumber: Int { n }
}
