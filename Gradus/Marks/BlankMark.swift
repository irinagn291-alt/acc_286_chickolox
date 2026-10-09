import Foundation

/// Written when a canvas is opened with no ink.
struct BlankMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var canvasID: UUID
}
