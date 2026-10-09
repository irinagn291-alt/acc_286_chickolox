import SwiftUI

/// Sealed notes, readiness, and days since the last seal.
struct ProgressSheet: View {
    @Environment(PracticeStore.self) private var practice
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let message = practice.recoveryMessage, practice.notes.isEmpty {
                    EmptyPage(
                        art: "grd_EmptyList",
                        headline: "Progress could not be read.",
                        line: message,
                        action: "Try again"
                    ) {
                        Task { await practice.load() }
                    }
                } else if practice.notes.isEmpty {
                    EmptyPage(
                        art: "grd_EmptyList",
                        headline: "No session is filed yet.",
                        line: "Seal a will on the board, then it shows up here.",
                        action: "Close"
                    ) { dismiss() }
                } else {
                    populated
                }
            }
            .background(DesignTokens.bg)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var populated: some View {
        List {
            if let brief = practice.nextSessionBrief() {
                Section {
                    Text(summary(brief))
                        .font(Ramp.body())
                        .foregroundStyle(DesignTokens.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Section {
                ForEach(practice.notes) { note in
                    VStack(alignment: .leading, spacing: Measure.s2) {
                        Text(name(note.coacheeID))
                            .font(Ramp.headline())
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(1)
                        Text(note.will)
                            .font(Ramp.willLine())
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(2)
                        Text(readinessLine(note.readiness))
                            .font(Ramp.caption())
                            .foregroundStyle(DesignTokens.muted)
                            .monospacedDigit()
                        Text(daysLine(note))
                            .font(Ramp.caption())
                            .foregroundStyle(DesignTokens.muted)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, Measure.s2)
                }
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func summary(_ brief: NextSessionBrief) -> String {
        let who = name(brief.latest.coacheeID)
        let days = Figures.whole(brief.daysSinceSeal)
        return "\(who): \(brief.latest.will). \(days) days since the last seal."
    }

    private func readinessLine(_ value: Int) -> String {
        let current = Figures.whole(value)
        let cap = Figures.whole(5)
        return "Readiness \(current) of \(cap)"
    }

    private func daysLine(_ note: SessionNote) -> String {
        let days = DayKey.daysBetween(note.dayKey, DayKey.from(Date()))
        let count = Figures.whole(days)
        return "\(count) days since this seal"
    }

    private func name(_ id: UUID) -> String {
        practice.coachees.first { $0.id == id }?.name ?? "Client"
    }
}

struct ProgressScreen: View {
    var body: some View {
        ProgressSheet()
    }
}
