import Foundation

@Observable
final class SearchViewModel {
    private let repository: DigestRepository
    private var searchIndex: [SearchEntry] = []
    private var searchTask: Task<Void, Never>?

    var query = "" {
        didSet { debouncedSearch() }
    }
    var groupedResults: [(issueDate: String, entries: [SearchEntry])] = []
    var isSearching = false
    var isLoaded = false

    init(repository: DigestRepository) {
        self.repository = repository
    }

    func loadIndex() async {
        guard !isLoaded else { return }
        searchIndex = await repository.loadSearchIndex()
        isLoaded = true
    }

    private func debouncedSearch() {
        searchTask?.cancel()
        let currentQuery = query

        guard !currentQuery.isEmpty else {
            groupedResults = []
            return
        }

        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(300))
            } catch { return }

            isSearching = true

            let matches = searchIndex.filter { entry in
                entry.title.localizedCaseInsensitiveContains(currentQuery) ||
                entry.summary.localizedCaseInsensitiveContains(currentQuery)
            }

            // Group by issue date
            let grouped = Dictionary(grouping: matches) { $0.issueDate }
            groupedResults = grouped
                .sorted { $0.key > $1.key }
                .map { (issueDate: $0.key, entries: $0.value) }

            isSearching = false
        }
    }
}
