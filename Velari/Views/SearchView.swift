import SwiftUI

struct SearchView: View {
    let repository: DigestRepository
    @State private var viewModel: SearchViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    searchContent(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Search")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SearchViewModel(repository: repository)
            }
        }
        .task {
            await viewModel?.loadIndex()
        }
    }

    @ViewBuilder
    private func searchContent(_ vm: SearchViewModel) -> some View {
        List {
            if vm.query.isEmpty {
                ContentUnavailableView {
                    Label("Search", systemImage: "magnifyingglass")
                } description: {
                    Text("Search across all AI news digests")
                }
                .listRowSeparator(.hidden)
            } else if vm.groupedResults.isEmpty && !vm.isSearching {
                ContentUnavailableView.search(text: vm.query)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(vm.groupedResults, id: \.issueDate) { group in
                    Section(DateFormatting.shortDisplayDate(group.issueDate)) {
                        ForEach(group.entries) { entry in
                            searchResultRow(entry)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: Binding(
            get: { vm.query },
            set: { vm.query = $0 }
        ), prompt: "Search stories...")
    }

    private func searchResultRow(_ entry: SearchEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            HStack(spacing: 8) {
                if let category = StoryCategory(rawValue: entry.category) {
                    Text("\(category.icon) \(category.shortName)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(DateFormatting.relativeDate(entry.datePublished))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
