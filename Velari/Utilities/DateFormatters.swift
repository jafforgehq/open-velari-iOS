import Foundation

enum DateFormatting {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoBasicFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    private static let shortDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    private static let weekRangeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    static func parseISO(_ string: String) -> Date? {
        isoFormatter.date(from: string) ?? isoBasicFormatter.date(from: string)
    }

    static func parseDate(_ string: String) -> Date? {
        dateOnlyFormatter.date(from: string)
    }

    static func displayDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else { return dateString }
        return displayFormatter.string(from: date)
    }

    static func shortDisplayDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else { return dateString }
        return shortDisplayFormatter.string(from: date)
    }

    static func relativeDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else { return dateString }
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }

    static func weekRange(start: String, end: String) -> String {
        guard let startDate = parseDate(start),
              let endDate = parseDate(end) else {
            return "\(start) - \(end)"
        }
        let startStr = weekRangeFormatter.string(from: startDate)
        let endYear = Calendar.current.component(.year, from: endDate)
        let endStr = "\(weekRangeFormatter.string(from: endDate)), \(endYear)"
        return "Week of \(startStr) - \(endStr)"
    }
}
