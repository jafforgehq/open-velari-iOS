import Foundation

@Observable
final class ArchiveViewModel {
    private let repository: DigestRepository

    var archiveIndex: ArchiveIndex?
    var isLoading = false
    var errorMessage: String?

    init(repository: DigestRepository) {
        self.repository = repository
    }

    func loadArchive() async {
        isLoading = true
        defer { isLoading = false }

        archiveIndex = await repository.loadArchiveIndex()
        errorMessage = repository.error
    }
}
