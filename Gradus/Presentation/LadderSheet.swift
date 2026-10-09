import SwiftUI

/// Twist screen. Shows where this canvas sits on the ground-then-branch ladder.
struct LadderSheet: View {
    @Environment(PracticeStore.self) private var practice
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Image("grd_TwistHero")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: Measure.s16 * 4, maxHeight: Measure.s16 * 4)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                    Text("Ground, then branch.")
                        .font(Ramp.title())
                        .foregroundStyle(DesignTokens.ink)
                    Text(phaseLine)
                        .font(Ramp.body())
                        .foregroundStyle(DesignTokens.muted)
                }
                Section {
                    row("Draft", detail: "Goal and reality take ink.", on: phase == .draft)
                    row("Grounded", detail: "Both plates are locked.", on: phase == .grounded)
                    row("Branched", detail: "At least two options exist.", on: phase == .branched)
                    row("Sealed", detail: "The will is filed and the next board is open.", on: phase == .sealed)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignTokens.bg)
            .navigationTitle("Path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: Measure.hit, height: Measure.hit)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    private var phase: CanvasPhase {
        practice.openCanvas?.phase ?? .draft
    }

    private var phaseLine: String {
        switch phase {
        case .draft:
            return "This board is still a draft. Ground is the live tap."
        case .grounded:
            return "Reality is locked. Add option lines next."
        case .branched:
            return "The board is branched. Star a will, then Seal."
        case .sealed:
            return "The last board is sealed."
        }
    }

    private func row(_ title: String, detail: String, on: Bool) -> some View {
        VStack(alignment: .leading, spacing: Measure.s1) {
            Text(on ? "\(title), current" : title)
                .font(Ramp.headline())
                .foregroundStyle(DesignTokens.ink)
            Text(detail)
                .font(Ramp.caption())
                .foregroundStyle(DesignTokens.muted)
        }
        .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
        .listRowBackground(on ? DesignTokens.surface : DesignTokens.bg)
    }
}
