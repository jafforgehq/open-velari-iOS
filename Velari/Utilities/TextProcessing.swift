import Foundation

extension String {
    var strippedOfCiteTags: String {
        self
            .replacingOccurrences(of: "<cite[^>]*>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "</cite>", with: "")
    }
}
