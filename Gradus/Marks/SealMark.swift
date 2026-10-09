import Foundation

/// Written when Seal files a SessionNote and opens the next canvas.
struct SealMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var canvasID: UUID
    var sessionID: UUID
    var readiness: Int
    var dayKey: Int
    /// The blank canvas this seal opened. Retract peels only while that canvas is still the open empty board.
    var successorID: UUID?
}
