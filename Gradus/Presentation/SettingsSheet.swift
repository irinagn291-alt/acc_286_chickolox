import SwiftUI

/// Contact, local PDF, onboarding again, and a confirmed erase.
struct SettingsSheet: View {
    @Environment(PracticeStore.self) private var practice
    @Environment(\.dismiss) private var dismiss
    @State private var confirmErase = false
    @State private var exportFile: FolioFile?
    @State private var showExporter = false
    @State private var notice = ""

    private var contact: URL? {
        URL(string: "https://gradus-canvas.pro/contact-us")
    }

    var body: some View {
        NavigationStack {
            Group {
                if let message = practice.recoveryMessage, practice.coachees.isEmpty && practice.notes.isEmpty {
                    EmptyPage(
                        art: "grd_EmptyList",
                        headline: "Settings could not load the chart.",
                        line: message,
                        action: "Try again"
                    ) {
                        Task { await practice.load() }
                    }
                } else {
                    form
                }
            }
            .background(DesignTokens.bg)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .confirmationDialog(
            "Erase the roster?",
            isPresented: $confirmErase,
            titleVisibility: .visible
        ) {
            Button("Erase roster", role: .destructive) {
                Task { await practice.resetAllData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Clients, boards, and sealed sessions leave this device.")
        }
        .fileExporter(
            isPresented: $showExporter,
            document: exportFile,
            contentType: .pdf,
            defaultFilename: "Gradus-sessions"
        ) { result in
            if case .failure = result {
                notice = "The PDF could not be saved. Try again."
            }
        }
    }

    private var form: some View {
        Form {
            if practice.notes.isEmpty && practice.coachees.isEmpty {
                Section {
                    Text("Nothing is stored yet. Ground a session, then export it from here.")
                        .font(Ramp.body())
                        .foregroundStyle(DesignTokens.muted)
                }
            }
            Section("Contact") {
                if let contact {
                    Link("Contact Gradus", destination: contact)
                        .font(Ramp.body())
                        .frame(minHeight: Measure.hit)
                }
            }
            Section("Sessions") {
                Button("Export sealed sessions") {
                    let names = Dictionary(uniqueKeysWithValues: practice.coachees.map { ($0.id, $0.name) })
                    exportFile = FolioFile(data: SessionFolio.document(notes: practice.notes, names: names))
                    showExporter = true
                }
                .frame(minHeight: Measure.hit)
                .disabled(practice.notes.isEmpty)
            }
            Section {
                Button("Show onboarding again") {
                    practice.replayOnboarding()
                    dismiss()
                }
                .frame(minHeight: Measure.hit)
                Button("Erase roster", role: .destructive) {
                    confirmErase = true
                }
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
    }
}

struct SettingsView: View {
    var body: some View {
        SettingsSheet()
    }
}
