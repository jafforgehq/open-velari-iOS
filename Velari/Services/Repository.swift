import Foundation

@Observable
final class DigestRepository {
    let cache: CacheService

    var isRefreshing = false
    var error: String?

    init(cache: CacheService) {
        self.cache = cache
    }

    // MARK: - Issues

    func loadLatestIssue() async -> Issue? {
        if let cached = cache.loadLatestIssue() {
            Task {
                await refreshLatestIfNeeded(currentDate: cached.metadata.generatedDate)
            }
            return cached
        }
        return await fetchAndCacheLatest()
    }

    func refreshLatest() async -> Issue? {
        isRefreshing = true
        defer { isRefreshing = false }
        error = nil
        return await fetchAndCacheLatest()
    }

    func loadIssue(date: String) async -> Issue? {
        if let cached = cache.loadIssue(date: date) {
            return cached
        }
        do {
            let issue = try await NetworkService.fetchIssue(date: date)
            cache.saveIssue(issue)
            return issue
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // MARK: - Archive

    func loadArchiveIndex() async -> ArchiveIndex? {
        do {
            return try await NetworkService.fetchArchiveIndex()
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // MARK: - Search

    func loadSearchIndex() async -> [SearchEntry] {
        if let cached = cache.loadSearchIndex() {
            Task { await refreshSearchIndex() }
            return cached
        }
        return await refreshSearchIndex() ?? []
    }

    @discardableResult
    private func refreshSearchIndex() async -> [SearchEntry]? {
        do {
            let entries = try await NetworkService.fetchSearchIndex()
            cache.saveSearchIndex(entries)
            return entries
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private func refreshLatestIfNeeded(currentDate: String) async {
        do {
            let latest = try await NetworkService.fetchLatestIssue()
            if latest.metadata.generatedDate != currentDate {
                cache.saveIssue(latest)
            }
        } catch {
            // Silent — cached data available
        }
    }

    private func fetchAndCacheLatest() async -> Issue? {
        do {
            let issue = try await NetworkService.fetchLatestIssue()
            cache.saveIssue(issue)
            error = nil
            return issue
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
}
