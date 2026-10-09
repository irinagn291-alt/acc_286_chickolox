import Foundation

/// Written when options or will are edited before the canvas is Grounded. The edit is refused.
struct EarlyMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var canvasID: UUID
    var attempt: String
}
