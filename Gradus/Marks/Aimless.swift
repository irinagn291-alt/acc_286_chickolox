import Foundation

/// Written when Seal is tapped on a Branched canvas with no starred will. Phase stays Branched.
struct Aimless: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var canvasID: UUID
}
