import SwiftUI

/// Spacing, radius, type, and the one shadow. Views reach layout only through here.
enum Measure {
    static let unit: CGFloat = 4
    static let s1 = unit
    static let s2 = unit * 2
    static let s3 = unit * 3
    static let s4 = unit * 4
    static let s6 = unit * 6
    static let s8 = unit * 8
    static let s12 = unit * 12
    static let s16 = unit * 16
    static let hit: CGFloat = unit * 11

    static let hairline = unit / 4

    enum Radius {
        static let plate: CGFloat = 18
        static let chip: CGFloat = 8
    }

    enum Shadow {
        static let color = DesignTokens.ink.opacity(0.18)
        static let blur = Radius.chip
        static let y = Measure.s1
    }
}

/// Six Baskerville steps. Quadrant names use tracking. Will uses italic once.
enum Ramp {
    static func display() -> Font {
        .custom(DesignTokens.fontFamily, size: 32, relativeTo: .largeTitle)
    }

    static func title() -> Font {
        .custom(DesignTokens.fontFamily, size: 24, relativeTo: .title2)
    }

    static func headline() -> Font {
        .custom(DesignTokens.fontFamily, size: 20, relativeTo: .headline)
    }

    static func body() -> Font {
        .custom(DesignTokens.fontFamily, size: 17, relativeTo: .body)
    }

    static func caption() -> Font {
        .custom(DesignTokens.fontFamily, size: 14, relativeTo: .caption)
    }

    static func micro() -> Font {
        .custom(DesignTokens.fontFamily, size: 12, relativeTo: .caption2)
    }

    static func quadrant() -> Font {
        .custom(DesignTokens.fontFamily, size: 12, relativeTo: .caption2)
    }

    static func willLine() -> Font {
        .custom(DesignTokens.fontFamily, size: 17, relativeTo: .body).italic()
    }
}

enum Figures {
    static func whole(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

extension View {
    func plateShadow() -> some View {
        shadow(color: Measure.Shadow.color, radius: Measure.Shadow.blur, x: 0, y: Measure.Shadow.y)
    }
}
