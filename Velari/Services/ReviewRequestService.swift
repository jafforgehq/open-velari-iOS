import Foundation
import StoreKit
import SwiftUI

enum ReviewRequestService {
    private static let countKey = "review_stories_read_count"
    private static let lastVersionKey = "review_last_requested_version"
    private static let minimumReads = 5

    @MainActor
    static func registerReadAndMaybePrompt(request: RequestReviewAction) {
        let newCount = UserDefaults.standard.integer(forKey: countKey) + 1
        UserDefaults.standard.set(newCount, forKey: countKey)

        guard newCount >= minimumReads else { return }

        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let lastVersion = UserDefaults.standard.string(forKey: lastVersionKey) ?? ""
        guard currentVersion != lastVersion else { return }

        request()
        UserDefaults.standard.set(currentVersion, forKey: lastVersionKey)
    }
}
