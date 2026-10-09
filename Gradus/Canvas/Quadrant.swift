import Foundation

/// One GROW quadrant. Section titles stay aligned with SessionNote bodies.
struct Quadrant: Sendable, Equatable, Identifiable {
    enum Kind: String, Sendable, Equatable {
        case goal
        case reality
        case options
        case will
    }

    static let titles = ["Goal", "Reality", "Options", "Will"]

    var id: Kind { kind }
    var kind: Kind
    var ink: String
}
