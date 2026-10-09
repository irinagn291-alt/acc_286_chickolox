import Foundation

/// Written when Ground is tapped while goal or reality is still empty. Phase stays Draft.
struct ThinMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var canvasID: UUID
}
