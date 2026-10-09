import Foundation

/// Phase of one coachee canvas in the GROW fold.
/// Draft accepts goal and reality ink. Grounded has both quadrants locked.
/// Branched has at least two option lines. Sealed has filed a session note.
enum CanvasPhase: String, Codable, Sendable, Equatable {
    case draft
    case grounded
    case branched
    case sealed
}
