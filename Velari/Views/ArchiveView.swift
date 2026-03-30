import SwiftUI

struct ArchiveView: View {
    let repository: DigestRepository
    @State private var viewModel: ArchiveViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    archiveContent(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Archive")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ArchiveViewModel(repository: repository)
            }
        }
        .task {
            await viewModel?.loadArchive()
        }
    }

    @ViewBuilder
    private func archiveContent(_ vm: ArchiveViewModel) -> some View {
        if vm.isLoading && vm.archiveIndex == nil {
            ProgressView()
        } else if let index = vm.archiveIndex {
            List(index.issues) { issue in
                NavigationLink {
                    IssueView(archiveIssue: issue, repository: repository)
                } label: {
                    issueRow(issue)
                }
            }
            .listStyle(.plain)
        } else if let error = vm.errorMessage {
            EmptyStateView(
                systemImage: "wifi.slash",
                title: "Unable to Load",
                subtitle: error,
                action: { Task { await vm.loadArchive() } },
                actionLabel: "Retry"
            )
        } else {
            EmptyStateView(
                systemImage: "clock",
                title: "No Archives",
                subtitle: "Past issues will appear here"
            )
        }
    }

    private func issueRow(_ issue: ArchiveIssue) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(DateFormatting.shortDisplayDate(issue.date))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text((issue.isPreview ?? false) ? "Preview" : "Issue #\(issue.issueNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("\(issue.totalStories) stories")
                .font(.caption)
                .foregroundStyle(.secondary)

            if !issue.highlights.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(issue.highlights.prefix(3), id: \.self) { highlight in
                        HStack(alignment: .top, spacing: 4) {
                            Text("\u{2022}")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text(highlight)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}
