import SwiftUI

@Observable
final class SettingsViewModel {
    private let cache: CacheService

    var showClearHistoryConfirmation = false
    var showClearCacheConfirmation = false

    var cacheSize: String {
        cache.cacheSize()
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    init(cache: CacheService) {
        self.cache = cache
    }

    func clearReadingHistory() {
        cache.clearReadingHistory()
    }

    func clearCache() {
        cache.clearCache()
    }
}
