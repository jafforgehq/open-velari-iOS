import Testing
@testable import Velari

@Suite("Story Category")
struct CategoryTests {
    @Test func allCasesCount() {
        #expect(StoryCategory.allCases.count == 9)
    }

    @Test func allCasesHaveDisplayName() {
        for category in StoryCategory.allCases {
            #expect(!category.displayName.isEmpty)
        }
    }

    @Test func allCasesHaveShortName() {
        for category in StoryCategory.allCases {
            #expect(!category.shortName.isEmpty)
        }
    }

    @Test func allCasesHaveIcon() {
        for category in StoryCategory.allCases {
            #expect(!category.icon.isEmpty)
        }
    }

    @Test func allCasesHaveSystemImage() {
        for category in StoryCategory.allCases {
            #expect(!category.systemImage.isEmpty)
        }
    }

    @Test func rawValueRoundTrip() {
        for category in StoryCategory.allCases {
            let decoded = StoryCategory(rawValue: category.rawValue)
            #expect(decoded == category)
        }
    }
}
