import SwiftUI

/// Roster sheet. Names appear only after the Face ID gate has passed.
struct ClientsSheet: View {
    var openScan: () -> Void

    @Environment(PracticeStore.self) private var practice
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var digits = ""
    @State private var notice = ""
    @State private var gateNotice = ""

    var body: some View {
        NavigationStack {
            Group {
                if let message = practice.recoveryMessage, practice.coachees.isEmpty {
                    EmptyPage(
                        art: "grd_EmptyList",
                        headline: "The roster could not be read.",
                        line: message,
                        action: "Try again"
                    ) {
                        Task { await practice.load() }
                    }
                } else if !practice.rosterPassed {
                    EmptyPage(
                        art: "grd_EmptyHome",
                        headline: "Client records are sealed.",
                        line: gateNotice.isEmpty ? "Unlock, then pick a client." : gateNotice,
                        action: "Continue"
                    ) {
                        Task {
                            if await RosterGate.confirm() {
                                gateNotice = ""
                                practice.passRoster()
                            } else {
                                gateNotice = RosterGate.denied
                            }
                        }
                    }
                } else if practice.coachees.isEmpty {
                    EmptyPage(
                        art: "grd_EmptyList",
                        headline: "The tray is empty.",
                        line: "Add a client, or scan a desk code.",
                        action: "Scan a desk",
                        perform: openScan
                    )
                } else {
                    populated
                }
            }
            .background(DesignTokens.bg)
            .navigationTitle("Clients")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var populated: some View {
        List {
            Section {
                ForEach(practice.coachees) { coachee in
                    Button {
                        practice.focus(coacheeID: coachee.id)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: Measure.s1) {
                            Text(coachee.name)
                                .font(Ramp.body())
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(1)
                            Text(Figures.whole(coachee.deskDigits.count) + " desk digits")
                                .font(Ramp.caption())
                                .foregroundStyle(DesignTokens.muted)
                        }
                        .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Add a client") {
                TextField("Name", text: $name)
                    .font(Ramp.body())
                TextField("Desk digits", text: $digits)
                    .font(Ramp.body())
                    .keyboardType(.numberPad)
                    .onChange(of: digits) { _, newValue in
                        let filtered = newValue.filter(\.isNumber)
                        if filtered != newValue { digits = filtered }
                    }
                Button("Add client") {
                    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else {
                        notice = "Write a name first."
                        return
                    }
                    _ = practice.addCoachee(name: trimmed, deskDigits: digits)
                    name = ""
                    digits = ""
                    notice = "Client added. Their board is open."
                }
                .frame(minHeight: Measure.hit)
            }
            Section {
                Button("Scan a desk", action: openScan)
                    .frame(minHeight: Measure.hit)
            }
            if !notice.isEmpty {
                Section {
                    Text(notice)
                        .font(Ramp.caption())
                        .foregroundStyle(DesignTokens.muted)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }
}

struct ClientsView: View {
    var openScan: () -> Void

    var body: some View {
        ClientsSheet(openScan: openScan)
    }
}
