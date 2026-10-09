import Foundation

/// The open GROW board for one coachee. Folds Draft, Grounded, Branched, and Sealed.
struct Canvas: Identifiable, Sendable, Equatable {
    struct Line: Identifiable, Sendable, Equatable {
        var id: UUID
        var ink: String
        var starred: Bool
    }

    var id: UUID
    var coacheeID: UUID
    var goalInk: String
    var realityInk: String
    var phase: CanvasPhase
    var lines: [Line]

    var quadrants: [Quadrant] {
        [
            Quadrant(kind: .goal, ink: goalInk),
            Quadrant(kind: .reality, ink: realityInk),
            Quadrant(kind: .options, ink: lines.map(\.ink).joined(separator: "\n")),
            Quadrant(kind: .will, ink: lines.first(where: \.starred)?.ink ?? "")
        ]
    }

    var goalHoldsInk: Bool { !goalInk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var realityHoldsInk: Bool { !realityInk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var starredLineID: UUID? { lines.first(where: \.starred)?.id }

    static func blank(id: UUID = UUID(), coacheeID: UUID) -> Canvas {
        Canvas(id: id, coacheeID: coacheeID, goalInk: "", realityInk: "", phase: .draft, lines: [])
    }
}

/// Result of one fold step. A refusal leaves the canvas unchanged except for the recorded mark.
struct FoldReport: Sendable, Equatable {
    var mark: ChartMark?
    var refused: Bool
    var notice: String

    static func accepted(_ mark: ChartMark?, notice: String) -> FoldReport {
        FoldReport(mark: mark, refused: false, notice: notice)
    }

    static func refused(_ mark: ChartMark?, notice: String) -> FoldReport {
        FoldReport(mark: mark, refused: true, notice: notice)
    }
}
