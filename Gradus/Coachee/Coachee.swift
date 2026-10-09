import Foundation

/// A coachee on the roster. The desk digit run is how a scanned code focuses this person.
struct Coachee: Identifiable, Sendable, Equatable {
    var id: UUID
    var name: String
    var deskDigits: String

    /// Whole days from the latest seal day key to `day`, using start-of-day boundaries.
    func daysSinceSeal(latestDayKey: Int?, on day: Int, calendar: Calendar = .current) -> Int? {
        guard let latestDayKey else { return nil }
        return DayKey.daysBetween(latestDayKey, day, calendar: calendar)
    }
}

enum DayKey {
    static func from(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10000 + month * 100 + day
    }

    static func date(from key: Int, calendar: Calendar = .current) -> Date? {
        var parts = DateComponents()
        parts.year = key / 10000
        parts.month = (key / 100) % 100
        parts.day = key % 100
        guard let date = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: date)
    }

    static func daysBetween(_ earlier: Int, _ later: Int, calendar: Calendar = .current) -> Int {
        guard
            let start = date(from: earlier, calendar: calendar),
            let end = date(from: later, calendar: calendar)
        else { return 0 }
        let span = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(0, span)
    }
}
