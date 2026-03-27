# Velari Mobile App - Functional Requirements Document

**Version:** 1.0
**Date:** 2026-03-27
**Platforms:** iOS (SwiftUI, iOS 17+) and Android (Kotlin, Jetpack Compose, API 26+)

---

## 1. Product Overview

Velari is a mobile news reader for **OpenVelari**, a weekly AI news digest curated by AI. The app consumes static JSON data hosted on GitHub Pages. There is no backend, no user accounts, and no server-side logic. The app is a pure client that fetches, caches, and displays weekly AI news digests.

**Website:** https://openvelari.app
**Data host:** https://jafforgehq.github.io/openvelari/

---

## 2. Data Sources and API Contract

All data is static JSON/XML hosted at a single base URL. There is no authentication, no rate limiting, and no API keys.

### 2.1 Base URL

```
https://jafforgehq.github.io/openvelari
```

### 2.2 Endpoints

| Endpoint | Format | Description |
|---|---|---|
| `/data/latest.json` | JSON | Full current/latest issue (same content as the dated file) |
| `/data/index.json` | JSON | Archive index listing all published issues |
| `/data/{date}.json` | JSON | Individual issue by date (e.g., `/data/2026-03-27.json`) |
| `/feed.xml` | RSS 2.0 | RSS feed with latest stories |
| `/search-index.json` | JSON | Compact search index across all issues |

### 2.3 Issue JSON Schema (`latest.json` and `{date}.json`)

These files share the same schema. `latest.json` is always a copy of the most recent dated file.

```json
{
  "metadata": {
    "generated_date": "2026-03-27T00:00:00Z",
    "week_start": "2026-03-20",
    "week_end": "2026-03-27",
    "total_sources_consulted": 127,
    "id": "preview",
    "issue_number": 0,
    "is_preview": true,
    "total_stories": 19,
    "model_used": "claude-haiku-4-5"
  },
  "stories": [
    {
      "id": "story-001",
      "title": "White House Releases National Policy Framework for AI Regulation",
      "summary": "The White House released a National Policy Framework...",
      "category": "policy",
      "importance": 10,
      "date_published": "2026-03-20",
      "sources": [
        {
          "title": "White House Releases National Policy Framework for AI",
          "url": "https://example.com/article",
          "publisher": "WilmerHale"
        }
      ],
      "tags": ["policy", "regulation", "federal", "preemption", "state-laws"]
    }
  ]
}
```

#### Field Reference: `metadata`

| Field | Type | Description |
|---|---|---|
| `generated_date` | string (ISO 8601) | When this issue was generated |
| `week_start` | string (YYYY-MM-DD) | Start of the coverage week |
| `week_end` | string (YYYY-MM-DD) | End of the coverage week |
| `total_sources_consulted` | integer | Number of sources the AI reviewed |
| `id` | string | Issue identifier (e.g., `"preview"`, `"issue-1"`) |
| `issue_number` | integer | Sequential issue number (0 = preview/first) |
| `is_preview` | boolean | Whether this is a preview issue (not yet finalized) |
| `total_stories` | integer | Number of stories in this issue |
| `model_used` | string | AI model that generated the digest |

#### Field Reference: `stories[]`

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique story identifier (e.g., `"story-001"`) |
| `title` | string | Story headline |
| `summary` | string | Story summary. **Note:** may contain `<cite index="...">` tags that should be stripped or ignored during display |
| `category` | string | Category key (see Section 2.6 for valid values) |
| `importance` | integer (1-10) | Importance score. 10 = critical, 1 = minor |
| `date_published` | string (YYYY-MM-DD) | When the original news was published |
| `sources` | array of Source | Original source articles |
| `sources[].title` | string | Source article title |
| `sources[].url` | string | Source article URL |
| `sources[].publisher` | string | Publisher name |
| `tags` | array of string | Relevant tags/keywords |

### 2.4 Archive Index Schema (`index.json`)

```json
{
  "issues": [
    {
      "id": "preview",
      "date": "2026-03-27",
      "issue_number": 0,
      "total_stories": 19,
      "file": "2026-03-27.json",
      "highlights": [
        "White House Releases National Policy Framework for AI Regulation",
        "OpenAI Releases GPT-5.4 with 1.05M Token Context Window",
        "OpenAI Acquires Six Companies Including Astral and Promptfoo"
      ],
      "is_preview": true
    }
  ],
  "latest": "2026-03-27.json",
  "total_issues": 0
}
```

#### Field Reference: `issues[]`

| Field | Type | Description |
|---|---|---|
| `id` | string | Issue identifier |
| `date` | string (YYYY-MM-DD) | Issue publication date |
| `issue_number` | integer | Sequential issue number |
| `total_stories` | integer | Number of stories in the issue |
| `file` | string | Filename to fetch (append to `/data/`) |
| `highlights` | array of string | Top 3 story titles for preview |
| `is_preview` | boolean | Whether this is a preview issue |

Top-level fields:
- `latest` (string): Filename of the latest issue
- `total_issues` (integer): Total number of published issues

### 2.5 Search Index Schema (`search-index.json`)

A compact array optimized for client-side search. Each entry is a story with abbreviated field names.

```json
[
  {
    "t": "White House Releases National Policy Framework for AI Regulation",
    "s": "The White House released a National Policy Framework...",
    "u": "https://example.com/article",
    "c": "policy",
    "d": "2026-03-20",
    "i": "2026-03-27",
    "n": 0
  }
]
```

#### Field Reference (search index entries)

| Field | Type | Description |
|---|---|---|
| `t` | string | Story title |
| `s` | string | Summary (truncated, may contain cite tags) |
| `u` | string | Primary source URL |
| `c` | string | Category key |
| `d` | string (YYYY-MM-DD) | Date published |
| `i` | string (YYYY-MM-DD) | Issue date this story belongs to |
| `n` | integer | Issue number |

### 2.6 Categories

These are the valid category keys, their display names, and icons. Hardcode these in the app.

| Key | Display Name | Icon |
|---|---|---|
| `research` | Research & Breakthroughs | U+1F52C (microscope) |
| `industry` | Industry & Business | U+1F4BC (briefcase) |
| `policy` | Policy & Regulation | U+2696 (scales) |
| `tools` | Tools & Developer | U+1F6E0 (wrench) |
| `open_source` | Open Source | U+1F4E6 (package) |
| `safety` | AI Safety & Alignment | U+1F510 (lock) |
| `robotics` | Robotics & Hardware | U+1F916 (robot) |
| `healthcare` | Healthcare & Science | U+1F3E5 (hospital) |
| `models` | Models & Benchmarks | U+1F4CA (chart) |

### 2.7 RSS Feed (`feed.xml`)

Standard RSS 2.0 with Atom self-link. Each `<item>` contains:
- `<title>` -- story title
- `<description>` -- story summary (HTML-encoded, may contain cite tags)
- `<link>` -- primary source URL
- `<guid isPermaLink="false">` -- unique story ID (format: `story-{NNN}-{issue_id}`)
- `<pubDate>` -- date published (YYYY-MM-DD format)
- `<category>` -- category key

The app does NOT need to parse RSS for core functionality (JSON endpoints are preferred). RSS is listed here for completeness and potential future use (e.g., widget, background refresh trigger).

### 2.8 Summary Text Processing

Story summaries may contain `<cite index="...">...</cite>` tags from the AI generation process. The app MUST strip these tags before display, showing only the inner text content. Use a simple regex:

```
// Strip <cite ...> and </cite> tags, keep inner text
summary.replacingOccurrences(of: "<cite[^>]*>", with: "", options: .regularExpression)
         .replacingOccurrences(of: "</cite>", with: "")
```

---

## 3. App Architecture

### 3.1 Pattern

**MVVM (Model-View-ViewModel)** on both platforms.

```
View (SwiftUI / Compose)
  |
ViewModel (ObservableObject / ViewModel)
  |
Repository (single source of truth)
  |
  +-- NetworkDataSource (URLSession / Retrofit+OkHttp)
  +-- LocalDataSource (SwiftData / Room)
```

### 3.2 iOS Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Navigation | NavigationStack with NavigationPath |
| State | @Observable (Observation framework) |
| Networking | URLSession + async/await |
| Local DB | SwiftData |
| Notifications | UserNotifications + BackgroundTasks (BGAppRefreshTask) |
| In-App Purchase | StoreKit 2 |

### 3.3 Android Stack

| Layer | Technology |
|---|---|
| UI | Jetpack Compose + Material 3 |
| Navigation | Compose Navigation (type-safe) |
| State | StateFlow + collectAsState |
| Networking | Retrofit + OkHttp + kotlinx.serialization |
| Local DB | Room |
| Notifications | Firebase Cloud Messaging (optional) or WorkManager polling |
| Ads | Google AdMob (banner) |

### 3.4 Offline-First Strategy

1. On launch, display cached data from local DB immediately.
2. In background, fetch `/data/latest.json` and compare `metadata.generated_date` with cached version.
3. If newer, download and update local DB, then update UI.
4. Cache the last 4 issues locally. Older issues are evicted on a FIFO basis.
5. The search index (`search-index.json`) is cached entirely and refreshed weekly.
6. The archive index (`index.json`) is always fetched fresh (it is tiny).

### 3.5 Data Flow for Launch

```
1. App opens
2. Load latest issue from local DB -> display immediately
3. Fetch /data/latest.json in background
4. Compare metadata.generated_date
5a. If same -> no-op
5b. If newer -> save to DB, update UI, show "New issue available" badge
6. Fetch /data/index.json -> update archive list
7. Fetch /search-index.json -> update local search index
```

---

## 4. Screens and Features

### 4.1 Home Screen (Latest Issue)

**Route:** `/` (root)

**Layout:**
- Top app bar: "Velari" title with app icon, settings gear icon (trailing)
- AI disclaimer banner (subtle, persistent): "AI-curated digest. Verify claims with original sources."
- Issue metadata header: "Week of Mar 20 - Mar 27, 2026" with story count and source count
- Category filter chips: horizontally scrollable row of category pills. "All" selected by default. Tapping a category filters the story list.
- Story card list: vertically scrollable list of story cards

**Behavior:**
- Pull-to-refresh triggers a fresh fetch of `latest.json`
- Category chips filter stories by `category` field
- Stories the user has already read are displayed with reduced opacity (0.6) and a subtle "Read" indicator
- On first launch with no cache, show a skeleton/shimmer loading state

### 4.2 Story Card

Each story is rendered as a card with:

| Element | Source Field | Notes |
|---|---|---|
| Importance badge | `importance` | Color-coded pill: 10 = red, 8-9 = orange, 6-7 = yellow, <6 = gray. Display as "10/10", "9/10", etc. |
| Category pill | `category` | Show icon + display name using the category map |
| Title | `title` | Bold, primary text. Max 3 lines, truncate with ellipsis. |
| Summary | `summary` | Secondary text. Max 4 lines in list view. Strip cite tags first. |
| Date | `date_published` | Relative format: "3 days ago", "1 week ago" |
| Source pills | `sources` | Horizontal row of publisher name pills. Tapping a pill opens the source URL in the system browser. |
| Tags | `tags` | Small chips below the summary. Tappable (filters stories by that tag within the current issue). |
| Share button | -- | Native share sheet with story title + primary source URL |
| Bookmark button | -- | Toggle bookmark state (local storage) |

**Tap behavior:** Tapping the card body opens the Story Detail screen. Mark the story as read in local storage.

### 4.3 Story Detail Screen

**Route:** `/story/{storyId}`

**Layout:**
- Full importance badge and category at top
- Full title (large text)
- Date published (formatted: "March 20, 2026")
- Full summary text (all cite tags stripped, full text displayed with no truncation)
- "Sources" section heading
- List of source cards, each showing:
  - Publisher name (bold)
  - Article title
  - Tapping opens URL in system browser (SFSafariViewController on iOS, Chrome Custom Tabs on Android)
- Tags section: full list of tags as chips
- Share button (floating or in toolbar)
- Bookmark button

**Footer:** "This summary was generated by AI (claude-haiku-4-5). Always verify claims with original sources."

### 4.4 Archive Screen

**Route:** `/archive`

**Access:** Bottom navigation tab or navigation drawer item.

**Layout:**
- List of all issues from `index.json`, sorted by date descending (newest first)
- Each row shows:
  - Issue date formatted: "Mar 27, 2026"
  - Issue number: "Issue #0" (or "Preview" if `is_preview` is true)
  - Story count: "19 stories"
  - Highlights: up to 3 bullet points from `highlights` array
- Tapping an issue row fetches `/data/{file}` and opens the Issue View

### 4.5 Issue View

**Route:** `/issue/{date}`

**Layout:** Same as Home Screen but for a specific past issue. Shows the same category filter chips and story card list. The header shows the issue date range and metadata.

**Caching:** If the issue is one of the last 4, load from local DB. Otherwise, fetch from network and display (do not cache beyond the 4-issue window).

### 4.6 Search Screen

**Route:** `/search`

**Access:** Bottom navigation tab or search icon in the top app bar.

**Data source:** `/search-index.json` (cached locally, refreshed when app launches).

**Layout:**
- Search text field at top with clear button
- Results list below, showing matching stories as compact cards (title, category pill, date, issue date)
- Empty state: "Search across all AI news digests"
- No results state: "No stories matching '{query}'"

**Search logic:**
- Client-side search across the `t` (title) and `s` (summary) fields
- Case-insensitive substring match
- Debounce input by 300ms before searching
- Show results grouped by issue date (`i` field), newest first
- Tapping a result opens the Story Detail screen. If the issue is cached, load the full story from local DB. If not, fetch `/data/{issue_date}.json` first.

### 4.7 Bookmarks Screen

**Route:** `/bookmarks`

**Access:** Bottom navigation tab.

**Layout:**
- List of bookmarked stories as full story cards
- Empty state: "No saved stories yet. Tap the bookmark icon on any story to save it."
- Swipe to remove bookmark

**Storage:** Bookmarked stories are stored as full story objects in the local database, independent of the 4-issue cache window. They persist until explicitly removed.

### 4.8 Settings Screen

**Route:** `/settings`

**Access:** Gear icon in the top app bar on the Home screen.

**Sections:**

#### Appearance
- Theme toggle: Dark / Light / System (default: System)

#### Notifications
- Toggle: "New issue alerts" (default: on)
- Description: "Get notified when a new weekly digest is published (Sundays after 2 PM UTC)"

#### Data
- "Clear reading history" -- button, confirmation dialog
- "Clear cache" -- button, confirmation dialog, clears all cached issues and search index
- Cache size indicator: "Using X MB"

#### About
- App version and build number
- "Velari - AI News Digest"
- "Powered by OpenVelari"
- Link: "View on GitHub" -> opens https://github.com/jafforgehq/openvelari
- Link: "Privacy Policy" -> opens privacy policy URL
- Link: "Terms of Use" -> opens terms URL
- Link: "Open Source Licenses" -> shows third-party license list

#### iOS Only
- "Support Velari" section with tip jar (see Section 6.2)

#### Android Only
- No additional settings (ads are shown automatically)

---

## 5. Navigation Structure

### 5.1 Bottom Navigation (both platforms)

| Tab | Icon | Label | Route |
|---|---|---|---|
| Home | house | Home | `/` |
| Search | magnifying glass | Search | `/search` |
| Bookmarks | bookmark | Saved | `/bookmarks` |
| Archive | clock/history | Archive | `/archive` |

### 5.2 iOS Navigation

- `TabView` with 4 tabs
- Each tab has its own `NavigationStack`
- Story detail is pushed onto the stack from any tab
- Settings is presented as a sheet from the Home tab

### 5.3 Android Navigation

- `Scaffold` with `NavigationBar` (Material 3 bottom nav)
- Single `NavHost` with nested navigation graphs per tab
- Settings is a separate destination navigated from the top app bar

---

## 6. Monetization

### 6.1 Android: AdMob Banner Ads

- Show a single AdMob banner ad at the bottom of the screen, below the content area and above the bottom navigation bar.
- Ad unit: standard banner (320x50 dp).
- The ad is persistent across all screens except Settings and Story Detail.
- Use adaptive banner sizing.
- Do NOT show interstitial or rewarded ads.
- Do NOT show ads on first launch (wait until the user has opened at least 3 stories).
- Include an AdMob app ID in `AndroidManifest.xml`.
- Comply with AdMob policies: include GDPR consent dialog if the user is in the EU (use Google UMP SDK).

### 6.2 iOS: Tip Jar (In-App Purchase)

- Located in Settings > "Support Velari" section.
- Three non-consumable tip options:
  - "Small Tip" -- $0.99 (product ID: `com.velari.tip.small`)
  - "Medium Tip" -- $2.99 (product ID: `com.velari.tip.medium`)
  - "Large Tip" -- $4.99 (product ID: `com.velari.tip.large`)
- Use StoreKit 2 (`Product.products(for:)` and `product.purchase()`).
- Show a thank-you message after successful purchase.
- Tips are consumable (user can tip multiple times).
- No content is gated behind tips. The entire app is free.

### 6.3 No Paywalled Content

All content is free and open. There are no premium features, no subscriptions, and no content gates. Monetization is purely optional (tips on iOS, unobtrusive ads on Android).

---

## 7. Push Notifications

### 7.1 Trigger Logic

New issues are published every Sunday at 2 PM UTC (defined by `schedule.cron: "0 14 * * 0"` in the site config).

The app checks for new content using a background task:

1. Schedule a repeating background task for every Sunday at 2:30 PM UTC (30-minute buffer).
2. The task fetches `/data/index.json`.
3. Compare `index.latest` with the locally stored latest filename.
4. If different, a new issue is available. Send a local notification.

### 7.2 iOS Implementation

- Use `BGAppRefreshTask` registered with identifier `com.velari.refresh`.
- Schedule with `BGTaskScheduler.shared.submit()`.
- On trigger, fetch index, compare, and post `UNNotificationRequest` if new.
- Request notification permission on first launch (after showing the home screen, not before).

### 7.3 Android Implementation

- Use `WorkManager` with a `PeriodicWorkRequest` (minimum 15-minute interval; schedule for Sundays).
- On trigger, fetch index, compare, and post notification via `NotificationManager`.
- Create a notification channel: "New Issues" with default importance.

### 7.4 Notification Content

```
Title: "New Velari Digest"
Body: "This week's AI news digest is ready. {total_stories} stories inside."
```

Tapping the notification opens the app to the Home screen with the new issue.

---

## 8. Offline Support

### 8.1 Caching Strategy

| Data | Cache Duration | Storage |
|---|---|---|
| Latest issue | Until replaced by newer issue | Local DB (SwiftData/Room) |
| Last 4 issues | Rolling window, FIFO eviction | Local DB |
| Search index | Refreshed on each app launch | Local DB or file |
| Archive index | Always fetched fresh | In-memory only |
| Bookmarked stories | Permanent until user removes | Local DB |
| Reading history | Permanent until user clears | Local DB |

### 8.2 Offline Behavior

- If the device is offline and cached data exists, display cached data normally with no error banner.
- If the device is offline and no cached data exists (first launch with no network), show an empty state: "No internet connection. Connect to load your first digest."
- Pull-to-refresh while offline shows a brief toast/snackbar: "No internet connection."

---

## 9. Reading History

### 9.1 Data Model

```
ReadStory {
  storyId: String       // e.g., "story-001"
  issueDate: String     // e.g., "2026-03-27"
  readAt: Date          // timestamp when marked as read
}
```

### 9.2 Behavior

- A story is marked as read when the user taps to open the Story Detail screen.
- Read stories appear with reduced opacity (0.6 alpha) and a small "Read" checkmark overlay in the story card list.
- Reading history persists across app launches (stored in local DB).
- Users can clear all reading history from Settings.
- Reading history is per-story, not per-issue.

---

## 10. Bookmarks / Saved Stories

### 10.1 Data Model

```
BookmarkedStory {
  storyId: String
  issueDate: String
  title: String
  summary: String
  category: String
  importance: Int
  datePublished: String
  sources: [Source]
  tags: [String]
  bookmarkedAt: Date
}
```

Bookmarked stories store the full story data so they remain accessible even if the issue is evicted from cache.

### 10.2 Behavior

- Tap the bookmark icon on any story card or detail screen to toggle bookmark state.
- Bookmarked stories appear in the Bookmarks tab.
- Swipe-to-delete removes a bookmark (with undo snackbar on Android, swipe action on iOS).
- Bookmarks persist indefinitely until the user removes them.

---

## 11. Sharing

### 11.1 Share Content Format

When the user taps the share button on a story:

```
{story.title}

Read more: {sources[0].url}

Shared via Velari - AI News Digest
```

### 11.2 Platform Implementation

- **iOS:** Use `ShareLink` (SwiftUI) or `UIActivityViewController`.
- **Android:** Use `Intent.ACTION_SEND` with `text/plain` MIME type.

---

## 12. External Links

All source URLs open in the system browser, NOT in an in-app webview.

- **iOS:** Use `SFSafariViewController` for a smooth in-app browser experience, or `openURL` for the default browser. Prefer `SFSafariViewController`.
- **Android:** Use Chrome Custom Tabs (`CustomTabsIntent`). Fall back to `Intent.ACTION_VIEW` if Chrome is not available.

---

## 13. Theme and UI/UX

### 13.1 Brand Colors

| Token | Value | Usage |
|---|---|---|
| Primary | `#8B5CF6` (violet) | App bar, buttons, accents, links |
| Primary variant | `#7C3AED` | Pressed states |
| Background (light) | `#FFFFFF` | Main background |
| Background (dark) | `#0F0F0F` | Main background |
| Surface (light) | `#F8F8F8` | Card backgrounds |
| Surface (dark) | `#1A1A1A` | Card backgrounds |
| On Primary | `#FFFFFF` | Text on primary color |
| Error | `#EF4444` | Importance 10 badge, errors |
| Warning | `#F59E0B` | Importance 8-9 badge |

### 13.2 Typography

- **iOS:** Use system Dynamic Type. SF Pro as default. Support all accessibility text sizes.
- **Android:** Use Material 3 type scale. Roboto as default. Support `fontScale` accessibility.

### 13.3 Importance Badge Colors

| Importance | Color | Label |
|---|---|---|
| 10 | Red (`#EF4444`) | "Critical" |
| 8-9 | Orange (`#F59E0B`) | "High" |
| 6-7 | Yellow (`#EAB308`) | "Medium" |
| 1-5 | Gray (`#9CA3AF`) | "Low" |

### 13.4 Platform-Specific Conventions

**iOS:**
- Use native `NavigationStack`, `TabView`, `List`, `Sheet`
- Haptic feedback on bookmark toggle, pull-to-refresh, and share
- Support Dynamic Type and VoiceOver
- Respect `UIUserInterfaceStyle` for system theme

**Android:**
- Use Material 3 components: `Scaffold`, `NavigationBar`, `LazyColumn`, `Card`
- Follow Material Design 3 spacing and elevation guidelines
- Support TalkBack accessibility
- Respect system dark mode via `isSystemInDarkTheme()`
- Edge-to-edge display with proper insets

### 13.5 Gestures

- Pull-to-refresh on all list screens
- Swipe-to-delete on Bookmarks screen
- Back gesture navigation (native on both platforms)

### 13.6 Loading States

- Skeleton/shimmer placeholders while loading story lists
- Circular progress indicator for individual issue loads
- No full-screen blocking loaders -- always show cached content first

### 13.7 Error States

- Network error: snackbar/toast with retry button
- Empty search results: illustration + "No stories found" text
- Empty bookmarks: illustration + "No saved stories" text
- First launch offline: full-screen message with retry button

---

## 14. Legal and Compliance

### 14.1 AI Content Disclaimer

Every screen that displays AI-generated content MUST include a visible disclaimer. Implementation:

- **Home screen / Issue view:** Subtle banner below the header: "AI-curated digest. Verify claims with original sources."
- **Story detail:** Footer text: "This summary was generated by AI ({model_used}). Always verify claims with original sources."
- The disclaimer must not be dismissible.

### 14.2 Privacy Policy and Terms

- Link to Privacy Policy in Settings > About
- Link to Terms of Use in Settings > About
- Both must also be included in App Store / Play Store listings

### 14.3 GDPR Compliance

- The app collects NO personal data on the server (there is no server).
- All user data (reading history, bookmarks, preferences) is stored locally on-device only.
- No cookies, no analytics SDKs, no tracking.
- **Android only:** If AdMob is used, integrate Google UMP (User Messaging Platform) SDK for EU consent.

### 14.4 App Store Privacy Labels

**iOS App Store Privacy Nutrition Label:**
- Data Not Collected: The app does not collect any data.
- Data Not Linked to You: No identifiers, no analytics.

**Google Play Data Safety:**
- No data shared with third parties (except AdMob on Android, which must be disclosed).
- No data collected beyond what AdMob requires (advertising ID on Android).
- Data is not used to track users across apps.

---

## 15. Settings Persistence

All settings are stored in platform-native key-value storage:

- **iOS:** `UserDefaults` (or `@AppStorage` in SwiftUI)
- **Android:** Jetpack DataStore (Preferences)

| Key | Type | Default |
|---|---|---|
| `theme` | string (`"dark"`, `"light"`, `"system"`) | `"system"` |
| `notifications_enabled` | boolean | `true` |

---

## 16. Background Sync

### 16.1 iOS

Register a `BGAppRefreshTask` with identifier `com.velari.refresh`:

```swift
BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.velari.refresh", using: nil) { task in
    // Fetch latest index, compare, post notification if new
}
```

Schedule it to run on Sundays after 14:00 UTC. iOS will determine the exact execution time.

### 16.2 Android

Use WorkManager with a `PeriodicWorkRequest`:

```kotlin
val refreshWork = PeriodicWorkRequestBuilder<DigestRefreshWorker>(7, TimeUnit.DAYS)
    .setInitialDelay(calculateDelayUntilSunday1430UTC(), TimeUnit.MILLISECONDS)
    .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
    .build()
WorkManager.getInstance(context).enqueueUniquePeriodicWork("digest_refresh", ExistingPeriodicWorkPolicy.KEEP, refreshWork)
```

---

## 17. Not In Scope (v1)

The following features are explicitly excluded from v1:

- User accounts or authentication
- Social features (comments, reactions, user profiles)
- In-app commenting
- Custom RSS feed subscriptions
- Newsletter signup
- Widget (iOS or Android)
- iPad / tablet-optimized layout
- watchOS / Wear OS companion app
- Analytics or crash reporting SDKs
- Content personalization or recommendation engine
- Push notifications via a push server (local notifications only)
- Localization / i18n (English only for v1)

---

## 18. Project Structure (Recommended)

### 18.1 iOS

```
Velari/
  VelariApp.swift              // @main entry point
  Models/
    Issue.swift                // Codable models for issue JSON
    SearchEntry.swift          // Codable model for search index
    ArchiveIndex.swift         // Codable model for index.json
    Category.swift             // Category enum with display names and icons
  ViewModels/
    HomeViewModel.swift
    ArchiveViewModel.swift
    SearchViewModel.swift
    BookmarksViewModel.swift
    SettingsViewModel.swift
  Views/
    HomeView.swift
    StoryCardView.swift
    StoryDetailView.swift
    ArchiveView.swift
    IssueView.swift
    SearchView.swift
    BookmarksView.swift
    SettingsView.swift
    Components/
      ImportanceBadge.swift
      CategoryPill.swift
      SourcePill.swift
      TagChip.swift
      DisclaimerBanner.swift
  Services/
    NetworkService.swift       // URLSession-based API client
    CacheService.swift         // SwiftData operations
    NotificationService.swift  // UNUserNotificationCenter
    StoreKitService.swift      // Tip jar IAP
  Utilities/
    DateFormatters.swift
    TextProcessing.swift       // Cite tag stripping
  Resources/
    Assets.xcassets
```

### 18.2 Android

```
app/src/main/java/com/velari/app/
  VelariApp.kt                // Application class
  MainActivity.kt
  data/
    model/
      Issue.kt                // Data classes for issue JSON
      SearchEntry.kt
      ArchiveIndex.kt
      Category.kt             // Enum with display names and icons
    local/
      VelariDatabase.kt       // Room database
      IssueDao.kt
      BookmarkDao.kt
      ReadHistoryDao.kt
    remote/
      VelariApi.kt            // Retrofit interface
      NetworkModule.kt        // Hilt DI module
    repository/
      DigestRepository.kt
      BookmarkRepository.kt
      SearchRepository.kt
  ui/
    home/
      HomeScreen.kt
      HomeViewModel.kt
    story/
      StoryCard.kt
      StoryDetailScreen.kt
    archive/
      ArchiveScreen.kt
      ArchiveViewModel.kt
    search/
      SearchScreen.kt
      SearchViewModel.kt
    bookmarks/
      BookmarksScreen.kt
      BookmarksViewModel.kt
    settings/
      SettingsScreen.kt
      SettingsViewModel.kt
    components/
      ImportanceBadge.kt
      CategoryPill.kt
      SourcePill.kt
      TagChip.kt
      DisclaimerBanner.kt
    theme/
      Theme.kt
      Color.kt
      Type.kt
  worker/
    DigestRefreshWorker.kt     // WorkManager periodic check
  navigation/
    VelariNavGraph.kt
  di/
    AppModule.kt               // Hilt modules
```

---

## 19. Testing Requirements

### 19.1 Unit Tests

- JSON parsing: Verify all models parse correctly from sample JSON (include test fixtures from the actual API responses above).
- Cite tag stripping: Verify `<cite index="...">text</cite>` becomes `text`.
- Search logic: Verify case-insensitive matching, debounce behavior.
- Cache eviction: Verify FIFO eviction of old issues beyond the 4-issue window.
- Relative date formatting: Verify "3 days ago", "1 week ago" logic.

### 19.2 UI Tests

- Home screen loads and displays story cards.
- Category filtering shows only matching stories.
- Tapping a story card navigates to detail screen and marks as read.
- Bookmark toggle persists across app restarts.
- Pull-to-refresh triggers network fetch.
- Offline mode shows cached content without errors.
- Search returns relevant results and handles empty state.

---

## 20. App Store Metadata

### 20.1 App Name
**Velari - AI News Digest**

### 20.2 Subtitle (iOS) / Short Description (Android)
"Weekly AI news, curated by AI"

### 20.3 Description
"Stay informed on the latest in artificial intelligence with Velari. Every week, our AI-powered system reviews hundreds of sources to bring you the most important AI news -- from research breakthroughs and policy changes to new models and open source releases. Free, open, and transparent."

### 20.4 Keywords (iOS)
`AI, artificial intelligence, news, digest, weekly, machine learning, LLM, tech news, AI models, open source`

### 20.5 Category
News (primary), Technology (secondary)

---

## Appendix A: Complete Example API Response

### A.1 `/data/latest.json` (truncated to 2 stories)

```json
{
  "metadata": {
    "generated_date": "2026-03-27T00:00:00Z",
    "week_start": "2026-03-20",
    "week_end": "2026-03-27",
    "total_sources_consulted": 127,
    "id": "preview",
    "issue_number": 0,
    "is_preview": true,
    "total_stories": 19,
    "model_used": "claude-haiku-4-5"
  },
  "stories": [
    {
      "id": "story-001",
      "title": "White House Releases National Policy Framework for AI Regulation",
      "summary": "<cite index=\"21-2\">The White House released a National Policy Framework for Artificial Intelligence on March 20, 2026, outlining policy recommendations to guide Congress in developing a unified federal approach to artificial intelligence legislation and regulation.</cite> This represents a landmark attempt to establish federal preemption over fragmented state AI laws, signaling industry-wide impact on compliance requirements and competitive advantage for startups navigating the regulatory landscape.",
      "category": "policy",
      "importance": 10,
      "date_published": "2026-03-20",
      "sources": [
        {
          "title": "White House Releases National Policy Framework for Artificial Intelligence",
          "url": "https://www.wilmerhale.com/en/insights/blogs/wilmerhale-privacy-and-cybersecurity-law/20260323-white-house-releases-national-policy-framework-for-artificial-intelligence",
          "publisher": "WilmerHale"
        },
        {
          "title": "President Donald J. Trump Unveils National AI Legislative Framework",
          "url": "https://www.whitehouse.gov/releases/2026/03/president-donald-j-trump-unveils-national-ai-legislative-framework/",
          "publisher": "The White House"
        }
      ],
      "tags": ["policy", "regulation", "federal", "preemption", "state-laws"]
    },
    {
      "id": "story-002",
      "title": "OpenAI Releases GPT-5.4 with 1.05M Token Context Window",
      "summary": "<cite index=\"4-1\">On March 5, 2026, OpenAI released GPT-5.4, its \"most capable and efficient frontier model for professional work\".</cite> <cite index=\"38-20\">The API supports context windows up to 1.05 million tokens, the largest OpenAI has ever offered commercially.</cite> This release narrows the competitive gap with rival models and demonstrates continued scaling in frontier AI capabilities despite concerns about diminishing returns.",
      "category": "models",
      "importance": 10,
      "date_published": "2026-03-05",
      "sources": [
        {
          "title": "AI Breakthroughs March 2026: GPT-5.4, Gemini Models & More",
          "url": "https://www.devflokers.com/blog/ai-breakthroughs-march-2026",
          "publisher": "devFlokers"
        },
        {
          "title": "12+ AI Models in March 2026: The Week That Changed AI",
          "url": "https://www.buildfastwithai.com/blogs/ai-models-march-2026-releases",
          "publisher": "Build Fast with AI"
        }
      ],
      "tags": ["GPT-5.4", "context-window", "frontier-models", "language-models"]
    }
  ]
}
```

### A.2 `/data/index.json`

```json
{
  "issues": [
    {
      "id": "preview",
      "date": "2026-03-27",
      "issue_number": 0,
      "total_stories": 19,
      "file": "2026-03-27.json",
      "highlights": [
        "White House Releases National Policy Framework for AI Regulation",
        "OpenAI Releases GPT-5.4 with 1.05M Token Context Window",
        "OpenAI Acquires Six Companies Including Astral and Promptfoo"
      ],
      "is_preview": true
    }
  ],
  "latest": "2026-03-27.json",
  "total_issues": 0
}
```

### A.3 `/search-index.json` (truncated to 2 entries)

```json
[
  {
    "t": "White House Releases National Policy Framework for AI Regulation",
    "s": "The White House released a National Policy Framework...",
    "u": "https://www.wilmerhale.com/en/insights/blogs/wilmerhale-privacy-and-cybersecurity-law/20260323-white-house-releases-national-policy-framework-for-artificial-intelligence",
    "c": "policy",
    "d": "2026-03-20",
    "i": "2026-03-27",
    "n": 0
  },
  {
    "t": "OpenAI Releases GPT-5.4 with 1.05M Token Context Window",
    "s": "On March 5, 2026, OpenAI released GPT-5.4...",
    "u": "https://www.devflokers.com/blog/ai-breakthroughs-march-2026",
    "c": "models",
    "d": "2026-03-05",
    "i": "2026-03-27",
    "n": 0
  }
]
```
