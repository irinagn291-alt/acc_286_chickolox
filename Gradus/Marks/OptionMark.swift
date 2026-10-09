import Foundation

/// Written for one option line. Starring a line is `starAsWill` on the canvas.
struct OptionMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var canvasID: UUID
    var lineID: UUID
    var ink: String

    static func starAsWill(lineID: UUID) -> UUID {
        lineID
    }
}
