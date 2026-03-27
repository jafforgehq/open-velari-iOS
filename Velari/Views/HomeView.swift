import SwiftUI

struct HomeView: View {
    let repository: DigestRepository
    @State private var viewModel: HomeViewModel?
    @State private var showSettings = false
    @State private var selectedStory: Story?
    @State private var bookmarkedStoryIDs: Set<String> = []

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    issueContent(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Velari")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(cache: repository.cache)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HomeViewModel(repository: repository)
            }
        }
        .task {
            await viewModel?.loadLatestIssue()
            syncBookmarkedIDs()
        }
        .onChange(of: viewModel?.currentIssue?.stories) {
            syncBookmarkedIDs()
        }
    }

    @ViewBuilder
    private func issueContent(_ vm: HomeViewModel) -> some View {
        if vm.isLoading && vm.currentIssue == nil {
            ShimmerView()
        } else if let issue = vm.currentIssue {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    DisclaimerBanner()

                    // Issue header
                    issueHeader(issue.metadata)
                        .padding(.horizontal)
                        .padding(.top, 12)

                    // Category filters
                    categoryFilters(vm)
                        .padding(.top, 8)

                    // Story cards
                    LazyVStack(spacing: 12) {
                        ForEach(vm.filteredStories) { story in
                            StoryCardView(
                                story: story,
                                issueDate: issue.metadata.weekEnd,
                                isRead: vm.isRead(storyId: story.id),
                                isBookmarked: Binding(
                                    get: { bookmarkedStoryIDs.contains(story.id) },
                                    set: { newValue in
                                        if newValue {
                                            bookmarkedStoryIDs.insert(story.id)
                                        } else {
                                            bookmarkedStoryIDs.remove(story.id)
                                        }
                                    }
                                ),
                                onTap: { selectedStory = story },
                                onBookmarkTap: {
                                    vm.toggleBookmark(story: story)
                                }
                            )
                        }
                    }
                    .navigationDestination(item: $selectedStory) { story in
                        StoryDetailView(
                            story: story,
                            issueDate: issue.metadata.weekEnd,
                            modelUsed: issue.metadata.modelUsed,
                            cache: repository.cache
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
            }
            .refreshable {
                await vm.refresh()
            }
        } else if let error = vm.errorMessage {
            EmptyStateView(
                systemImage: "wifi.slash",
                title: "Unable to Load",
                subtitle: error,
                action: { Task { await vm.refresh() } },
                actionLabel: "Retry"
            )
        } else {
            EmptyStateView(
                systemImage: "newspaper",
                title: "No Digest Available",
                subtitle: "Pull to refresh or check your connection.",
                action: { Task { await vm.refresh() } },
                actionLabel: "Retry"
            )
        }
    }

    private func issueHeader(_ metadata: IssueMetadata) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DateFormatting.weekRange(start: metadata.weekStart, end: metadata.weekEnd))
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("\(metadata.totalStories) stories from \(metadata.totalSourcesConsulted) sources")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func categoryFilters(_ vm: HomeViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    vm.selectedCategory = nil
                } label: {
                    Text("All")
                        .font(.caption)
                        .fontWeight(vm.selectedCategory == nil ? .semibold : .regular)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(vm.selectedCategory == nil ? VelariColors.primary : Color(.systemGray5))
                        .foregroundStyle(vm.selectedCategory == nil ? .white : .primary)
                        .clipShape(Capsule())
                }

                ForEach(StoryCategory.allCases) { category in
                    Button {
                        vm.selectedCategory = vm.selectedCategory == category ? nil : category
                    } label: {
                        CategoryPill(
                            category: category,
                            isSelected: vm.selectedCategory == category
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    private func syncBookmarkedIDs() {
        guard let stories = viewModel?.currentIssue?.stories else { return }
        bookmarkedStoryIDs = Set(
            stories.map(\.id).filter { repository.cache.isBookmarked(storyId: $0) }
        )
    }
}
