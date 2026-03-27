import Testing
import Foundation
@testable import Velari

@Suite("Date Formatting")
struct DateFormattingTests {
    @Test func parseISOWithFractionalSeconds() {
        let date = DateFormatting.parseISO("2026-03-20T15:30:00.000Z")
        #expect(date != nil)
    }

    @Test func parseISOWithoutFractionalSeconds() {
        let date = DateFormatting.parseISO("2026-03-20T15:30:00Z")
        #expect(date != nil)
    }

    @Test func parseISOReturnsNilForInvalid() {
        #expect(DateFormatting.parseISO("not-a-date") == nil)
    }

    @Test func parseDateWithValidFormat() {
        let date = DateFormatting.parseDate("2026-03-20")
        #expect(date != nil)
    }

    @Test func parseDateReturnsNilForInvalid() {
        #expect(DateFormatting.parseDate("March 20") == nil)
    }

    @Test func displayDateFormatsCorrectly() {
        let result = DateFormatting.displayDate("2026-03-20")
        #expect(result.contains("March"))
        #expect(result.contains("20"))
        #expect(result.contains("2026"))
    }

    @Test func displayDateReturnsInputForInvalid() {
        #expect(DateFormatting.displayDate("bad") == "bad")
    }

    @Test func shortDisplayDateFormatsCorrectly() {
        let result = DateFormatting.shortDisplayDate("2026-03-20")
        #expect(result.contains("Mar"))
        #expect(result.contains("20"))
    }

    @Test func weekRangeFormatsCorrectly() {
        let result = DateFormatting.weekRange(start: "2026-03-17", end: "2026-03-21")
        #expect(result.contains("Week of"))
        #expect(result.contains("Mar"))
        #expect(result.contains("2026"))
    }

    @Test func weekRangeFallsBackForInvalidDates() {
        let result = DateFormatting.weekRange(start: "bad", end: "dates")
        #expect(result == "bad - dates")
    }
}
