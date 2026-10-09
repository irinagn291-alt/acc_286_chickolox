import SwiftUI

/// Full-page empty or error. One cutout, one headline, one line, one bottom button.
struct EmptyPage: View {
    var art: String
    var headline: String
    var line: String
    var action: String
    var perform: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Measure.s4) {
            Image(art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Measure.s16 * 4, maxHeight: Measure.s16 * 4)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text(headline)
                .font(Ramp.display())
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
            Text(line)
                .font(Ramp.body())
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: Measure.s4)
            Button(action, action: perform)
                .buttonStyle(VerbButtonStyle(prominent: false, loading: false))
        }
        .padding(Measure.s6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(DesignTokens.bg)
    }
}
