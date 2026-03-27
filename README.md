# Velari

[![CI](https://github.com/jafforgehq/open-velari-iOS/actions/workflows/ci.yml/badge.svg)](https://github.com/jafforgehq/open-velari-iOS/actions/workflows/ci.yml)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-F05138.svg?style=flat&logo=swift)](https://swift.org)
[![iOS 18.6+](https://img.shields.io/badge/iOS-18.6+-007AFF.svg?style=flat&logo=apple)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF.svg?style=flat&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An AI-curated weekly news digest for artificial intelligence, delivered as a native iOS app. Velari aggregates stories from dozens of sources, summarizes them with AI, and presents them in a clean, offline-capable reader.

## Features

- **Weekly AI Digest** — Curated stories across research, industry, policy, tools, safety, robotics, healthcare, and models
- **Offline-First** — Issues are cached locally via SwiftData so you can read without a connection
- **Full-Text Search** — Search across all past issues with a compact, bandwidth-efficient index
- **Bookmarks** — Save stories for later and access them from the Saved tab
- **Background Refresh** — New issues are fetched automatically and trigger a local notification
- **Tip Jar** — Support the project via StoreKit 2 in-app purchases
- **Dark Mode** — System, light, and dark theme support
- **Open Data** — All digest data is served from a public GitHub repository

## Screenshots

<!-- Add screenshots here -->

## Architecture

Velari follows **MVVM** with a repository pattern and uses only first-party Apple frameworks.

```
Velari/
├── Models/                  # Codable, Sendable data structs
│   ├── Issue.swift          # Issue, IssueMetadata, Story, Source
│   ├── Category.swift       # StoryCategory enum (9 categories)
│   ├── ArchiveIndex.swift   # Archive listing models
│   └── SearchEntry.swift    # Compact search index entry
│
├── Services/                # Data layer
│   ├── NetworkService.swift # Static API client (URLSession)
│   ├── CacheService.swift   # SwiftData persistence layer
│   ├── Repository.swift     # DigestRepository — cache-first coordinator
│   ├── BackgroundRefreshService.swift
│   ├── NotificationService.swift
│   └── StoreKitService.swift
│
├── ViewModels/              # @Observable view models
│   ├── HomeViewModel.swift
│   ├── SearchViewModel.swift
│   ├── ArchiveViewModel.swift
│   ├── BookmarksViewModel.swift
│   └── SettingsViewModel.swift
│
├── Views/                   # SwiftUI views
│   ├── MainTabView.swift    # Root TabView (Home, Search, Saved, Archive)
│   ├── HomeView.swift       # Latest issue feed
│   ├── StoryDetailView.swift
│   ├── StoryCardView.swift
│   ├── SearchView.swift
│   ├── ArchiveView.swift
│   ├── BookmarksView.swift
│   ├── SettingsView.swift
│   ├── IssueView.swift
│   ├── Components/          # Reusable UI components
│   └── Onboarding/          # First-launch onboarding flow
│
├── Theme/
│   └── VelariTheme.swift    # Colors, importance levels
│
├── Utilities/
│   ├── DateFormatters.swift # Date parsing & display
│   ├── HapticService.swift  # Haptic feedback
│   └── TextProcessing.swift # HTML cite tag stripping
│
├── VelariApp.swift          # App entry point & SwiftData container
└── ContentView.swift        # Onboarding gate
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| UI | SwiftUI |
| State | `@Observable` (Observation framework) |
| Persistence | SwiftData |
| Networking | URLSession (async/await) |
| Background | BGAppRefreshTask |
| Notifications | UserNotifications |
| Payments | StoreKit 2 |
| Concurrency | Swift Concurrency (MainActor default isolation) |
| Dependencies | None (zero third-party) |

## Data Source

Velari reads from the [OpenVelari](https://github.com/jafforgehq/openvelari) public dataset:

- **Issues:** `https://raw.githubusercontent.com/jafforgehq/openvelari/main/data/latest.json`
- **Archive:** `https://raw.githubusercontent.com/jafforgehq/openvelari/main/data/index.json`
- **Search Index:** `https://openvelari.app/search-index.json`

## Requirements

- iOS 18.6+
- Xcode 16.4+
- No external dependencies

## Getting Started

```bash
git clone https://github.com/jafforgehq/open-velari-iOS.git
cd open-velari-iOS
open Velari.xcodeproj
```

Select a simulator and press **Cmd+R** to build and run.

## Testing

The project includes unit tests covering models, utilities, and error handling.

```bash
xcodebuild test \
  -project Velari.xcodeproj \
  -scheme Velari \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Tests run automatically on every push and pull request via GitHub Actions.

### Test Coverage

| Suite | Tests | What's Covered |
|-------|-------|---------------|
| Text Processing | 6 | HTML cite tag stripping |
| Date Formatting | 11 | ISO parsing, display formatting, week ranges |
| Category | 6 | Enum completeness, computed properties, raw value round-trip |
| Model Decoding | 7 | JSON decode for Issue, Story, SearchEntry, ArchiveIndex, ImportanceLevel |
| Network Errors | 4 | Error descriptions for all NetworkError cases |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Data powered by [OpenVelari](https://github.com/jafforgehq/openvelari)
- Built with Apple's SwiftUI, SwiftData, and StoreKit 2
