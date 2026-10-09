import Foundation

/// Roster lookup for a desk code. No remote catalog. The user agent is defined and never sent.
enum DeskLookup {
    static let userAgent = "Gradus/1.0 (iOS; +https://gradus-canvas.pro)"

    static func digitRun(from raw: String) -> String? {
        let digits = raw.filter(\.isNumber)
        guard (8...14).contains(digits.count) else { return nil }
        return digits
    }

    static func coachee(matching raw: String, roster: [Coachee]) -> Coachee? {
        guard let digits = digitRun(from: raw) else { return nil }
        var tries = [digits]
        if digits.count == 12 {
            tries.append("0" + digits)
        }
        return roster.first { tries.contains($0.deskDigits) }
    }
}
