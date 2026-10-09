import SwiftUI

/// Three pages that write the completion flag. Skip still writes the same defaults.
struct OnboardingPages: View {
    var finish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pages: [(art: String, title: String, line: String)] = [
        ("grd_Onboarding1", "A board for one session.", "Goal and reality stay on this device, with the client you picked."),
        ("grd_Onboarding2", "Ground, then branch.", "Lock Goal and Reality before options and will can move."),
        ("grd_Onboarding3", "Seal files the will.", "Two options, one starred path, then the next board opens.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Measure.s4) {
            HStack {
                Spacer()
                Button("Skip", action: finish)
                    .font(Ramp.caption())
                    .foregroundStyle(DesignTokens.muted)
                    .frame(minHeight: Measure.hit)
            }
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    pageBody(pages[index], index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            Button(page == pages.count - 1 ? "Continue" : "Next") {
                if page == pages.count - 1 {
                    finish()
                } else {
                    page += 1
                }
            }
            .buttonStyle(VerbButtonStyle(prominent: false, loading: false))
        }
        .padding(Measure.s6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.bg.ignoresSafeArea())
        .animation(reduceMotion ? .none : .easeOut(duration: 0.2), value: page)
    }

    private func pageBody(_ item: (art: String, title: String, line: String), index: Int) -> some View {
        VStack(alignment: .leading, spacing: Measure.s4) {
            Image(item.art)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: Measure.s16 * 5)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text(item.title)
                .font(Ramp.display())
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
            Text(item.line)
                .font(Ramp.body())
                .foregroundStyle(DesignTokens.muted)
            Spacer()
        }
        .opacity(1)
        .accessibilityElement(children: .combine)
    }
}
