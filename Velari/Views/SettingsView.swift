import SwiftUI

struct SettingsView: View {
    let cache: CacheService
    @AppStorage("theme") private var theme = "system"
    @AppStorage("notifications_enabled") private var notificationsEnabled = true
    @AppStorage("content_font_size") private var contentFontSize = "large"
    @State private var viewModel: SettingsViewModel?
    @State private var systemPermissionGranted = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                readingSection
                notificationsSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(cache: cache)
            }
        }
        .task {
            systemPermissionGranted = await NotificationService.isSystemPermissionGranted()
        }
    }

    // MARK: - Sections

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $theme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
        }
    }

    private var readingSection: some View {
        Section {
            Picker("Text Size", selection: $contentFontSize) {
                Text("S").tag("small")
                Text("M").tag("medium")
                Text("L").tag("large")
                Text("XL").tag("xLarge")
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Reading")
        } footer: {
            Text("Adjusts the summary text size in story detail.")
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("New issue alerts", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, enabled in
                    if enabled {
                        Task {
                            let granted = await NotificationService.requestPermission()
                            systemPermissionGranted = granted
                            if granted {
                                NotificationService.scheduleWeeklyReminder()
                            } else {
                                notificationsEnabled = false
                            }
                        }
                    } else {
                        NotificationService.cancelWeeklyReminder()
                    }
                }

            if !systemPermissionGranted {
                Button("Open System Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.subheadline)
            }
        } header: {
            Text("Notifications")
        } footer: {
            if !systemPermissionGranted {
                Text("Notifications are disabled in System Settings. Tap above to enable them.")
            } else {
                Text("Get notified when a new weekly digest is published (Sundays after 2 PM UTC).")
            }
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button("Clear Reading History", role: .destructive) {
                viewModel?.showClearHistoryConfirmation = true
            }
            .confirmationDialog(
                "Clear Reading History",
                isPresented: Binding(
                    get: { viewModel?.showClearHistoryConfirmation ?? false },
                    set: { viewModel?.showClearHistoryConfirmation = $0 }
                ),
                titleVisibility: .visible
            ) {
                Button("Clear", role: .destructive) {
                    viewModel?.clearReadingHistory()
                }
            } message: {
                Text("This will reset all stories to unread. This cannot be undone.")
            }

            Button("Clear Cache", role: .destructive) {
                viewModel?.showClearCacheConfirmation = true
            }
            .confirmationDialog(
                "Clear Cache",
                isPresented: Binding(
                    get: { viewModel?.showClearCacheConfirmation ?? false },
                    set: { viewModel?.showClearCacheConfirmation = $0 }
                ),
                titleVisibility: .visible
            ) {
                Button("Clear", role: .destructive) {
                    viewModel?.clearCache()
                }
            } message: {
                Text("This will remove all cached issues and search data. This cannot be undone.")
            }

            HStack {
                Text("Cache Size")
                Spacer()
                Text(viewModel?.cacheSize ?? "0 KB")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(viewModel?.appVersion ?? "1.0")
                    .foregroundStyle(.secondary)
            }

            Link("View on GitHub", destination: URL(string: "https://github.com/jafforgehq/openvelari")!)

            Link("Privacy Policy", destination: URL(string: "https://openvelari.app/privacy")!)

            Link("Terms of Use", destination: URL(string: "https://openvelari.app/terms")!)
        }
    }
}
