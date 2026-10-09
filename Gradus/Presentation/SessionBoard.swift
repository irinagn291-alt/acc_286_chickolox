import LocalAuthentication
import SwiftUI
import UIKit

/// Home mechanic. The open canvas is a fold the coach grounds, branches, and seals.
struct SessionBoard: View {
    var openClients: () -> Void
    var openProgress: () -> Void
    var openSettings: () -> Void
    var openScan: () -> Void
    var openLadder: () -> Void

    @Environment(PracticeStore.self) private var practice
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var notice = ""
    @State private var optionDraft = ""
    @State private var readiness = 4
    @State private var working = false
    @State private var revealed = false
    @State private var showMark = false
    @FocusState private var focus: Quadrant.Kind?
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Group {
            if let message = practice.recoveryMessage, practice.coachees.isEmpty {
                EmptyPage(
                    art: "grd_EmptyHome",
                    headline: "The chart could not be read.",
                    line: message,
                    action: "Try again"
                ) {
                    Task { await practice.load() }
                }
            } else if !practice.rosterPassed {
                lockedRoster
            } else if practice.coachees.isEmpty {
                EmptyPage(
                    art: "grd_EmptyHome",
                    headline: "No client on the tray yet.",
                    line: "Add a client, then ground today's goal and reality.",
                    action: "Add a client",
                    perform: openClients
                )
            } else {
                board
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.bg.ignoresSafeArea())
        .onAppear { revealed = true }
    }

    private var lockedRoster: some View {
        EmptyPage(
            art: "grd_EmptyHome",
            headline: "Client records are sealed.",
            line: notice.isEmpty ? "Unlock, then pick a client." : notice,
            action: "Continue"
        ) {
            Task { await confirmRoster() }
        }
    }

    private var board: some View {
        VStack(alignment: .leading, spacing: 0) {
            chrome
            if sizeClass == .regular {
                HStack(alignment: .top, spacing: Measure.s4) {
                    trayColumn
                        .frame(maxWidth: Measure.s16 * 5)
                    canvas
                }
                .padding(.horizontal, Measure.s4)
                .padding(.top, Measure.s3)
            } else {
                VStack(alignment: .leading, spacing: Measure.s3) {
                    trayRow
                    canvas
                }
                .padding(.horizontal, Measure.s4)
                .padding(.top, Measure.s3)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: Measure.s2) {
            verbs
                .padding(.horizontal, Measure.s4)
                .padding(.bottom, Measure.s2)
                .background(DesignTokens.bg)
        }
    }

    private var chrome: some View {
        VStack(alignment: .leading, spacing: Measure.s2) {
            Text("Chickolox")
                .font(Ramp.title())
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Measure.s2) {
                    tool("Clients", system: "person.2", action: openClients)
                    tool("Progress", system: "list.bullet", action: openProgress)
                    tool("Path", system: "arrow.triangle.branch", action: openLadder)
                    tool("Scan", system: "qrcode.viewfinder", action: openScan)
                    tool("Settings", system: "gearshape", action: openSettings)
                }
            }
        }
        .padding(.horizontal, Measure.s4)
        .padding(.top, Measure.s2)
    }

    private func tool(_ title: String, system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Measure.s1) {
                Image(systemName: system)
                    .font(Ramp.caption())
                    .accessibilityHidden(true)
                Text(title)
                    .font(Ramp.caption())
                    .lineLimit(1)
            }
            .foregroundStyle(DesignTokens.ink)
            .padding(.horizontal, Measure.s3)
            .frame(minHeight: Measure.hit)
            .background(DesignTokens.surface)
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
    }

    private var trayRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Measure.s2) {
                ForEach(Array(practice.coachees.enumerated()), id: \.element.id) { index, coachee in
                    trayButton(coachee)
                        .modifier(StaggerIn(index: index, revealed: revealed, reduceMotion: reduceMotion))
                }
            }
        }
        .frame(minHeight: Measure.hit)
    }

    private var trayColumn: some View {
        ScrollView {
            VStack(spacing: Measure.s2) {
                ForEach(Array(practice.coachees.enumerated()), id: \.element.id) { index, coachee in
                    trayButton(coachee)
                        .modifier(StaggerIn(index: index, revealed: revealed, reduceMotion: reduceMotion))
                }
            }
        }
    }

    private func trayButton(_ coachee: Coachee) -> some View {
        let selected = practice.openCanvas?.coacheeID == coachee.id
        return Button {
            practice.focus(coacheeID: coachee.id)
        } label: {
            Text(coachee.name)
                .font(Ramp.caption())
                .lineLimit(1)
                .frame(minHeight: Measure.hit)
        }
        .buttonStyle(PlateButtonStyle(focused: false, loading: false, failed: false, selected: selected))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var canvas: some View {
        let phase = practice.openCanvas?.phase ?? .draft
        return ScrollView {
            VStack(alignment: .leading, spacing: Measure.s4) {
                header
                sealStrip
                upperPlates
                    .modifier(StaggerIn(index: 0, revealed: revealed, reduceMotion: reduceMotion))
                optionBlock
                    .disabled(phase == .draft || phase == .sealed)
                    .modifier(StaggerIn(index: 1, revealed: revealed, reduceMotion: reduceMotion))
                willBlock
                    .disabled(phase != .branched && phase != .grounded)
                    .modifier(StaggerIn(index: 2, revealed: revealed, reduceMotion: reduceMotion))
                if !notice.isEmpty {
                    Text(notice)
                        .font(Ramp.caption())
                        .foregroundStyle(DesignTokens.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Measure.s2) {
            Text(activeName)
                .font(Ramp.display())
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
            Text(jobLine)
                .font(Ramp.headline())
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
        }
    }

    private var sealStrip: some View {
        let filed = Figures.whole(practice.notes.count)
        return HStack(alignment: .firstTextBaseline, spacing: Measure.s4) {
            VStack(alignment: .leading, spacing: Measure.s1) {
                Text(daysFigure)
                    .font(Ramp.title())
                    .foregroundStyle(DesignTokens.accent)
                    .monospacedDigit()
                    .lineLimit(1)
                Text(daysCaption)
                    .font(Ramp.caption())
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(2)
            }
            Spacer(minLength: Measure.s2)
            Text(filed + " filed")
                .font(Ramp.caption())
                .foregroundStyle(DesignTokens.ink)
                .monospacedDigit()
                .lineLimit(1)
        }
        .padding(Measure.s4)
        .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: Measure.Radius.plate, style: .continuous))
        .plateShadow()
    }

    private var upperPlates: some View {
        let goal = inkPlate(.goal, title: "Goal", text: practice.openCanvas?.goalInk ?? "", wide: true)
        let reality = inkPlate(.reality, title: "Reality", text: practice.openCanvas?.realityInk ?? "", wide: false)
        return Group {
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Measure.s3) {
                    goal
                    reality
                }
            } else {
                HStack(alignment: .top, spacing: Measure.s3) {
                    goal
                    reality
                }
            }
        }
    }

    private func inkPlate(_ kind: Quadrant.Kind, title: String, text: String, wide: Bool) -> some View {
        let phase = practice.openCanvas?.phase ?? .draft
        return VStack(alignment: .leading, spacing: Measure.s2) {
            Text(title.uppercased())
                .font(Ramp.quadrant())
                .tracking(Measure.s1)
                .foregroundStyle(DesignTokens.muted)
                .lineLimit(1)
            TextField(title, text: binding(kind), axis: .vertical)
                .font(Ramp.body())
                .foregroundStyle(DesignTokens.ink)
                .focused($focus, equals: kind)
                .disabled(phase != .draft)
                .lineLimit(3...6)
        }
        .padding(Measure.s4)
        .frame(maxWidth: .infinity, minHeight: wide ? Measure.s16 * 3 : Measure.s16 * 2, alignment: .topLeading)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: Measure.Radius.plate, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Measure.Radius.plate, style: .continuous)
                .stroke(focus == kind ? DesignTokens.ink : DesignTokens.muted, lineWidth: Measure.hairline)
        }
        .plateShadow()
        .layoutPriority(wide ? 2 : 1)
        .frame(maxWidth: wide || typeSize.isAccessibilitySize ? .infinity : Measure.s16 * 4)
    }

    private var optionBlock: some View {
        VStack(alignment: .leading, spacing: Measure.s2) {
            Text("OPTIONS")
                .font(Ramp.quadrant())
                .tracking(Measure.s1)
                .foregroundStyle(DesignTokens.muted)
            ForEach(practice.openCanvas?.lines ?? []) { line in
                Button {
                    let report = practice.starAsWill(lineID: line.id)
                    notice = report.notice
                } label: {
                    HStack {
                        Text(line.ink)
                            .font(line.starred ? Ramp.willLine() : Ramp.body())
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(2)
                        Spacer()
                        if line.starred {
                            Text("Will")
                                .font(Ramp.micro())
                                .padding(.horizontal, Measure.s2)
                                .padding(.vertical, Measure.s1)
                                .background(DesignTokens.bg)
                                .clipShape(RoundedRectangle(cornerRadius: Measure.Radius.chip, style: .continuous))
                        }
                    }
                }
                .buttonStyle(PlateButtonStyle(
                    focused: false,
                    loading: false,
                    failed: false,
                    selected: line.starred
                ))
                .disabled((practice.openCanvas?.lines.count ?? 0) < 2)
            }
            HStack(spacing: Measure.s2) {
                TextField("Add an option line", text: $optionDraft)
                    .font(Ramp.body())
                    .foregroundStyle(DesignTokens.ink)
                    .padding(Measure.s3)
                    .frame(minHeight: Measure.hit)
                    .background(DesignTokens.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Measure.Radius.chip, style: .continuous))
                    .plateShadow()
                Button {
                    let report = practice.addOption(ink: optionDraft)
                    notice = report.notice
                    if !report.refused { optionDraft = "" }
                } label: {
                    Image(systemName: "plus")
                        .font(Ramp.headline())
                        .foregroundStyle(DesignTokens.ink)
                        .frame(width: Measure.hit, height: Measure.hit)
                        .background(DesignTokens.surface)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                        .plateShadow()
                }
                .accessibilityLabel("Add")
            }
            Text(optionCountLine)
                .font(Ramp.micro())
                .foregroundStyle(DesignTokens.muted)
        }
    }

    private var willBlock: some View {
        VStack(alignment: .leading, spacing: Measure.s2) {
            Text("WILL")
                .font(Ramp.quadrant())
                .tracking(Measure.s1)
                .foregroundStyle(DesignTokens.muted)
            HStack(alignment: .firstTextBaseline, spacing: Measure.s2) {
                Image(systemName: willInk.isEmpty ? "star" : "star.fill")
                    .font(Ramp.body())
                    .foregroundStyle(willInk.isEmpty ? DesignTokens.muted : DesignTokens.ink)
                    .accessibilityHidden(true)
                Text(willInk.isEmpty ? "Star one option as the path." : willInk)
                    .font(willInk.isEmpty ? Ramp.body() : Ramp.willLine())
                    .foregroundStyle(willInk.isEmpty ? DesignTokens.muted : DesignTokens.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
            }
            .frame(minHeight: Measure.hit, alignment: .leading)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(DesignTokens.muted)
                    .frame(height: Measure.hairline)
            }
            Stepper(value: $readiness, in: 1...5) {
                Text(readinessLine)
                    .font(Ramp.body())
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
            }
            .frame(minHeight: Measure.hit)
        }
    }

    private var verbs: some View {
        let phase = practice.openCanvas?.phase ?? .draft
        let groundLive = phase == .draft
        return VStack(spacing: Measure.s3) {
            if showMark {
                Image("grd_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Measure.s16, height: Measure.s16)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
            if groundLive {
                Button("Ground") { commitGround() }
                    .buttonStyle(VerbButtonStyle(prominent: true, loading: working))
                    .disabled(working)
                    .accessibilityHint("Locks goal and reality")
            } else {
                Button("Seal") { commitSeal() }
                    .buttonStyle(VerbButtonStyle(prominent: true, loading: working))
                    .disabled(working || phase != .branched)
                    .accessibilityHint("Files the starred will")
            }
            if !practice.notes.isEmpty {
                Button("Retract") {
                    let report = practice.retractLastSeal()
                    notice = report.notice
                }
                .buttonStyle(DestructiveButtonStyle())
            }
        }
    }

    private var activeName: String {
        let id = practice.openCanvas?.coacheeID
        return practice.coachees.first { $0.id == id }?.name ?? "Today's session"
    }

    private var jobLine: String {
        switch practice.openCanvas?.phase {
        case .draft:
            return "Ground this goal and reality."
        case .grounded:
            return "Add two options, then star one path."
        case .branched:
            return "Seal the starred path."
        case .sealed:
            return "This session is filed."
        case nil:
            return "Pick a client."
        }
    }

    private var optionCountLine: String {
        let count = Figures.whole(practice.openCanvas?.lines.count ?? 0)
        return count + " options"
    }

    private var readinessLine: String {
        let current = Figures.whole(readiness)
        let cap = Figures.whole(5)
        return "Readiness \(current) of \(cap)"
    }

    private var daysFigure: String {
        guard let latest = practice.notes.map(\.dayKey).max() else { return "None" }
        return Figures.whole(DayKey.daysBetween(latest, DayKey.from(Date())))
    }

    private var daysCaption: String {
        practice.notes.isEmpty ? "No seal filed yet." : "days since the last seal"
    }

    private var willInk: String {
        practice.openCanvas?.lines.first(where: \.starred)?.ink ?? ""
    }

    private func binding(_ kind: Quadrant.Kind) -> Binding<String> {
        Binding(
            get: {
                switch kind {
                case .goal: practice.openCanvas?.goalInk ?? ""
                case .reality: practice.openCanvas?.realityInk ?? ""
                case .options, .will: ""
                }
            },
            set: { value in
                let report: FoldReport
                switch kind {
                case .goal: report = practice.inkGoal(value)
                case .reality: report = practice.inkReality(value)
                case .options, .will: return
                }
                if report.refused { notice = report.notice }
            }
        )
    }

    private func commitGround() {
        working = true
        let report = practice.groundTheReality()
        notice = report.notice
        if !report.refused {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            flashMark()
        }
        working = false
    }

    private func commitSeal() {
        working = true
        let report = practice.sealTheWill(readiness: readiness)
        notice = report.notice
        if !report.refused {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            readiness = 4
            flashMark()
        }
        working = false
    }

    private func flashMark() {
        showMark = true
        Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            showMark = false
        }
    }

    private func confirmRoster() async {
        if await RosterGate.confirm() {
            notice = ""
            practice.passRoster()
        } else {
            notice = RosterGate.denied
        }
    }
}

enum RosterGate {
    static let denied = "Face ID did not confirm. Try again."

    static func confirm() async -> Bool {
        let context = LAContext()
        var error: NSError?
        let policy: LAPolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication
        let reason = "Confirm it is you before client names appear."
        do {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                context.evaluatePolicy(policy, localizedReason: reason) { success, authError in
                    if let authError {
                        continuation.resume(throwing: authError)
                    } else {
                        continuation.resume(returning: success)
                    }
                }
            }
        } catch {
            return false
        }
    }
}

struct CanvasView: View {
    var openClients: () -> Void
    var openProgress: () -> Void
    var openSettings: () -> Void
    var openScan: () -> Void
    var openLadder: () -> Void

    var body: some View {
        SessionBoard(
            openClients: openClients,
            openProgress: openProgress,
            openSettings: openSettings,
            openScan: openScan,
            openLadder: openLadder
        )
    }
}

private struct StaggerIn: ViewModifier {
    var index: Int
    var revealed: Bool
    var reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(revealed ? 1 : 0)
            .offset(y: revealed || reduceMotion ? 0 : Measure.s2)
            .animation(animation, value: revealed)
    }

    private var animation: Animation {
        if reduceMotion { return .easeOut(duration: 0.2) }
        let delay = min(Double(index) * 0.05, 0.15)
        return .easeOut(duration: 0.2).delay(delay)
    }
}
