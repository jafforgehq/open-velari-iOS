import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var repository: DigestRepository?

    var body: some View {
        Group {
            if let repository {
                TabView {
                    Tab("Home", systemImage: "house.fill") {
                        HomeView(repository: repository)
                    }

                    Tab("Search", systemImage: "magnifyingglass") {
                        SearchView(repository: repository)
                    }

                    Tab("Saved", systemImage: "bookmark.fill") {
                        BookmarksView(cache: repository.cache)
                    }

                    Tab("Archive", systemImage: "clock.fill") {
                        ArchiveView(repository: repository)
                    }
                }
                .tint(VelariColors.primary)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if repository == nil {
                let cache = CacheService(modelContext: modelContext)
                repository = DigestRepository(cache: cache)
            }
        }
    }
}
