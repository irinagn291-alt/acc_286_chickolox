import Foundation

/// Written when Ground locks goal and reality and folds Draft to Grounded.
struct GroundMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var canvasID: UUID
    var dayKey: Int
}
