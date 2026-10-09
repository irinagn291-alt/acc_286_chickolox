import Foundation

/// A sealed GROW note. Quadrant text is frozen. Days since the seal are computed, not stored.
struct SessionNote: Identifiable, Sendable, Equatable {
    static let sectionTitles = Quadrant.titles

    var id: UUID
    var coacheeID: UUID
    var canvasID: UUID
    var goal: String
    var reality: String
    var optionLines: [String]
    var will: String
    var readiness: Int
    var dayKey: Int

    var sectionBodies: [String] {
        let options = optionLines.joined(separator: "\n")
        return [goal, reality, options, will]
    }

    var sectionsMatchTitles: Bool {
        sectionBodies.count == Self.sectionTitles.count
    }

    var readinessInRange: Bool {
        (1...5).contains(readiness)
    }
}

/// Next session line: the latest sealed note plus days since that seal.
struct NextSessionBrief: Sendable, Equatable {
    var latest: SessionNote
    var daysSinceSeal: Int

    static func make(notes: [SessionNote], on day: Int, calendar: Calendar = .current) -> NextSessionBrief? {
        guard let latest = notes.max(by: { lhs, rhs in
            if lhs.dayKey == rhs.dayKey { return lhs.id.uuidString < rhs.id.uuidString }
            return lhs.dayKey < rhs.dayKey
        }) else { return nil }
        return NextSessionBrief(
            latest: latest,
            daysSinceSeal: DayKey.daysBetween(latest.dayKey, day, calendar: calendar)
        )
    }
}
