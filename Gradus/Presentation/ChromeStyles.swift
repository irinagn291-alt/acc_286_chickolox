import SwiftUI
import UIKit

/// Filled capsule for Ground and Seal. Default, pressed, disabled, and loading.
struct VerbButtonStyle: ButtonStyle {
    var prominent: Bool
    var loading: Bool

    func makeBody(configuration: Configuration) -> some View {
        VerbFace(configuration: configuration, prominent: prominent, loading: loading)
    }
}

private struct VerbFace: View {
    @Environment(\.isEnabled) private var isEnabled
    var configuration: ButtonStyleConfiguration
    var prominent: Bool
    var loading: Bool

    var body: some View {
        configuration.label
            .font(Ramp.headline())
            .foregroundStyle(prominent ? DesignTokens.bg : DesignTokens.ink)
            .frame(maxWidth: .infinity, minHeight: Measure.hit)
            .background(prominent ? DesignTokens.accent : DesignTokens.surface)
            .clipShape(Capsule())
            .contentShape(Capsule())
            .opacity(face)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .overlay {
                if loading {
                    ProgressView()
                        .tint(prominent ? DesignTokens.bg : DesignTokens.ink)
                }
            }
            .plateShadow()
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var face: Double {
        if loading { return 0.7 }
        if !isEnabled { return 0.4 }
        if configuration.isPressed { return 0.82 }
        return 1
    }
}

/// Retract and erase. Destructive, never the accent colour.
struct DestructiveButtonStyle: ButtonStyle {
    var loading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        DestructiveFace(configuration: configuration, loading: loading)
    }
}

private struct DestructiveFace: View {
    @Environment(\.isEnabled) private var isEnabled
    var configuration: ButtonStyleConfiguration
    var loading: Bool

    var body: some View {
        configuration.label
            .font(Ramp.headline())
            .foregroundStyle(DesignTokens.ink)
            .frame(maxWidth: .infinity, minHeight: Measure.hit)
            .background(DesignTokens.bg)
            .overlay {
                Capsule().stroke(DesignTokens.muted, lineWidth: Measure.hairline)
            }
            .clipShape(Capsule())
            .contentShape(Capsule())
            .opacity(loading ? 0.7 : (isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4))
            .plateShadow()
    }
}

/// Quadrant plates and tray rows. Default, pressed, focused, disabled, loading, error, selected.
struct PlateButtonStyle: ButtonStyle {
    var focused: Bool
    var loading: Bool
    var failed: Bool
    var selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        PlateFace(
            configuration: configuration,
            focused: focused,
            loading: loading,
            failed: failed,
            selected: selected
        )
    }
}

private struct PlateFace: View {
    @Environment(\.isEnabled) private var isEnabled
    var configuration: ButtonStyleConfiguration
    var focused: Bool
    var loading: Bool
    var failed: Bool
    var selected: Bool

    var body: some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Measure.s4)
            .frame(minHeight: Measure.hit)
            .background(DesignTokens.surface)
            .foregroundStyle(DesignTokens.ink)
            .clipShape(RoundedRectangle(cornerRadius: Measure.Radius.plate, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: Measure.Radius.plate, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Measure.Radius.plate, style: .continuous)
                    .stroke(stroke, lineWidth: focused || selected || failed ? Measure.s1 / 2 : Measure.hairline)
            }
            .opacity(opacity)
            .overlay {
                if loading {
                    ProgressView().tint(DesignTokens.ink)
                }
            }
            .plateShadow()
    }

    private var stroke: Color {
        if failed { return DesignTokens.ink }
        if selected || focused || configuration.isPressed { return DesignTokens.ink }
        return DesignTokens.muted
    }

    private var opacity: Double {
        if loading { return 0.65 }
        if !isEnabled { return 0.45 }
        if configuration.isPressed { return 0.8 }
        return 1
    }
}
