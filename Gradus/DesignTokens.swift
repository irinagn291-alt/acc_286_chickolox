import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #111827
    static let bg = Color(red: 0.066667, green: 0.094118, blue: 0.152941)
    static let bgHex = "#111827"
    /// #2D3340
    static let surface = Color(red: 0.176471, green: 0.200000, blue: 0.250980)
    static let surfaceHex = "#2D3340"
    /// #FFFFFF
    static let ink = Color(red: 1.000000, green: 1.000000, blue: 1.000000)
    static let inkHex = "#FFFFFF"
    /// #D97706
    static let accent = Color(red: 0.850980, green: 0.466667, blue: 0.023529)
    static let accentHex = "#D97706"
    /// #ABAEB3
    static let muted = Color(red: 0.670588, green: 0.682353, blue: 0.701961)
    static let mutedHex = "#ABAEB3"
    static let fontFamily = "Baskerville"
}
