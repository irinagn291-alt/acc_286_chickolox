import Foundation
import Observation

/// In-memory source of truth for the GROW chart. Views talk to this type, never to UserDefaults.
@MainActor
@Observable
final class PracticeStore {
    private var chart: ChartRecord
    private let vault: ChartVault
    private let seedsDemo: Bool
    private var pendingSave: Task<Void, Never>?
    private(set) var recoveryMessage: String?
    private(set) var didLoad = false

    init(bank: ChartVault.Bank = .standard, seedsDemo: Bool = true) {
        chart = .empty()
        vault = ChartVault(bank: bank)
        self.seedsDemo = seedsDemo
    }

    var coachees: [Coachee] {
        chart.islands.map { Coachee(id: $0.id, name: $0.name, deskDigits: $0.deskDigits) }
    }

    var notes: [SessionNote] {
        chart.sessions.map(Self.note(from:))
    }

    var onboardingComplete: Bool { chart.onboardingComplete }
    var rosterPassed: Bool { chart.rosterPassed }

    var openCanvas: Canvas? {
        guard let id = chart.runs.openCanvasID else { return nil }
        return canvas(id: id)
    }

    func load() async {
        let loaded = await vault.load()
        chart = loaded.record
        recoveryMessage = loaded.notice
        if seedsDemo {
            await seedDemoIfNeeded()
        }
        didLoad = true
    }

    func finishOnboarding() {
        chart.onboardingComplete = true
        scheduleSave()
    }

    func replayOnboarding() {
        chart.onboardingComplete = false
        scheduleSave()
    }

    func passRoster() {
        chart.rosterPassed = true
        scheduleSave()
    }

    func flush() async {
        pendingSave?.cancel()
        pendingSave = nil
        await vault.persist(chart)
    }

    func noteScenePhaseInactiveOrBackground() {
        commitNow()
    }

    func resetAllData() async {
        pendingSave?.cancel()
        pendingSave = nil
        chart = .empty()
        recoveryMessage = nil
        await vault.persist(chart)
    }

    @discardableResult
    func addCoachee(name: String, deskDigits: String) -> Coachee {
        let coachee = Coachee(id: UUID(), name: name, deskDigits: deskDigits)
        chart.islands.append(IslandRow(id: coachee.id, name: name, deskDigits: deskDigits))
        let canvas = Canvas.blank(coacheeID: coachee.id)
        chart.books.append(book(from: canvas))
        chart.runs.openCanvasID = canvas.id
        let blank = BlankMark(id: UUID(), canvasID: canvas.id)
        chart.runs.marks.append(.blank(blank))
        scheduleSave()
        return coachee
    }

    func focus(coacheeID: UUID) {
        if let open = chart.books.last(where: { $0.coacheeID == coacheeID && $0.phase != .sealed }) {
            chart.runs.openCanvasID = open.id
        } else {
            let canvas = Canvas.blank(coacheeID: coacheeID)
            chart.books.append(book(from: canvas))
            chart.runs.openCanvasID = canvas.id
            chart.runs.marks.append(.blank(BlankMark(id: UUID(), canvasID: canvas.id)))
        }
        scheduleSave()
    }

    func inkGoal(_ text: String) -> FoldReport {
        ink(\.goalInk, text, field: "goal")
    }

    func inkReality(_ text: String) -> FoldReport {
        ink(\.realityInk, text, field: "reality")
    }

    func groundTheReality(dayKey: Int = DayKey.from(Date())) -> FoldReport {
        guard var book = openBook() else {
            return .refused(nil, notice: "Pick a client, then Ground.")
        }
        if book.phase == .grounded {
            return .refused(nil, notice: "Ground already locked this board. Add an option next.")
        }
        if book.phase != .draft {
            return .refused(nil, notice: "Ground is only for a draft board.")
        }
        if book.goalInk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || book.realityInk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let mark = ThinMark(id: UUID(), canvasID: book.id)
            chart.runs.marks.append(.thin(mark))
            scheduleSave()
            return .refused(.thin(mark), notice: "Write both Goal and Reality, then Ground.")
        }
        book.phase = .grounded
        replace(book)
        let mark = GroundMark(id: UUID(), canvasID: book.id, dayKey: dayKey)
        chart.runs.marks.append(.ground(mark))
        scheduleSave()
        return .accepted(.ground(mark), notice: "Goal and Reality are locked. Add options.")
    }

    func addOption(ink: String) -> FoldReport {
        guard var book = openBook() else {
            return .refused(nil, notice: "Pick a client first.")
        }
        let trimmed = ink.trimmingCharacters(in: .whitespacesAndNewlines)
        if book.phase == .draft || book.phase == .sealed {
            return refuseEarly(canvasID: book.id, attempt: "option")
        }
        guard !trimmed.isEmpty else {
            return .refused(nil, notice: "Write an option line first.")
        }
        let lineID = UUID()
        chart.rhumbs.append(RhumbRow(id: lineID, canvasID: book.id, ink: trimmed, starred: false))
        if book.phase == .grounded && optionCount(book.id) >= 2 {
            book.phase = .branched
            replace(book)
        }
        let mark = OptionMark(id: UUID(), canvasID: book.id, lineID: lineID, ink: trimmed)
        chart.runs.marks.append(.option(mark))
        scheduleSave()
        return .accepted(.option(mark), notice: "Option added.")
    }

    func starAsWill(lineID: UUID) -> FoldReport {
        guard let book = openBook() else {
            return .refused(nil, notice: "Pick a client first.")
        }
        if book.phase == .draft || book.phase == .sealed {
            return refuseEarly(canvasID: book.id, attempt: "will")
        }
        guard optionCount(book.id) >= 2 else {
            return .refused(nil, notice: "Add a second option, then star a will.")
        }
        guard chart.rhumbs.contains(where: { $0.id == lineID && $0.canvasID == book.id }) else {
            return .refused(nil, notice: "That option is not on this board.")
        }
        for index in chart.rhumbs.indices where chart.rhumbs[index].canvasID == book.id {
            chart.rhumbs[index].starred = chart.rhumbs[index].id == lineID
        }
        scheduleSave()
        return .accepted(nil, notice: "Will is starred.")
    }

    func sealTheWill(readiness: Int, dayKey: Int = DayKey.from(Date())) -> FoldReport {
        guard var book = openBook() else {
            return .refused(nil, notice: "Pick a client first.")
        }
        guard book.phase == .branched else {
            return .refused(nil, notice: "Branch at least two options before Seal.")
        }
        let lines = chart.rhumbs.filter { $0.canvasID == book.id }
        guard let starred = lines.first(where: \.starred) else {
            let mark = Aimless(id: UUID(), canvasID: book.id)
            chart.runs.marks.append(.aimless(mark))
            scheduleSave()
            return .refused(.aimless(mark), notice: "Star one option as Will, then Seal.")
        }
        guard (1...5).contains(readiness) else {
            return .refused(nil, notice: "Readiness is a number from 1 to 5.")
        }
        let sessionID = UUID()
        let session = SessionRow(
            id: sessionID,
            coacheeID: book.coacheeID,
            canvasID: book.id,
            goal: book.goalInk,
            reality: book.realityInk,
            optionLines: lines.map(\.ink),
            will: starred.ink,
            readiness: readiness,
            dayKey: dayKey
        )
        chart.sessions.append(session)
        book.phase = .sealed
        replace(book)
        let next = Canvas.blank(coacheeID: book.coacheeID)
        let seal = SealMark(
            id: UUID(),
            canvasID: book.id,
            sessionID: sessionID,
            readiness: readiness,
            dayKey: dayKey,
            successorID: next.id
        )
        chart.runs.marks.append(.seal(seal))
        chart.books.append(self.book(from: next))
        chart.runs.openCanvasID = next.id
        let blank = BlankMark(id: UUID(), canvasID: next.id)
        chart.runs.marks.append(.blank(blank))
        commitNow()
        return .accepted(.seal(seal), notice: "Session filed. The next board is open.")
    }

    func retractLastSeal() -> FoldReport {
        guard let sealIndex = chart.runs.marks.lastIndex(where: {
            if case .seal = $0 { return true }
            return false
        }), case .seal(let seal) = chart.runs.marks[sealIndex] else {
            return .refused(nil, notice: "There is no seal to retract.")
        }
        let refused = FoldReport.refused(nil, notice: "Retract only while the next board is empty.")
        guard let successorID = seal.successorID, chart.runs.openCanvasID == successorID else {
            return refused
        }
        guard let sealed = chart.books.first(where: { $0.id == seal.canvasID }),
              let successor = chart.books.first(where: { $0.id == successorID }),
              successor.coacheeID == sealed.coacheeID,
              successorIsEmpty(successor) else {
            return refused
        }
        chart.runs.marks.remove(at: sealIndex)
        chart.runs.marks.removeAll { mark in
            if case .blank(let blank) = mark { return blank.canvasID == successorID }
            return false
        }
        chart.books.removeAll { $0.id == successorID }
        chart.rhumbs.removeAll { $0.canvasID == successorID }
        chart.sessions.removeAll { $0.id == seal.sessionID }
        if let index = chart.books.firstIndex(where: { $0.id == seal.canvasID }) {
            chart.books[index].phase = .branched
        }
        chart.runs.openCanvasID = seal.canvasID
        commitNow()
        return .accepted(nil, notice: "Last seal peeled. The board is branched again.")
    }

    func nextSessionBrief(on day: Int = DayKey.from(Date()), calendar: Calendar = .current) -> NextSessionBrief? {
        NextSessionBrief.make(notes: notes, on: day, calendar: calendar)
    }

    func coachee(matching raw: String) -> Coachee? {
        DeskLookup.coachee(matching: raw, roster: coachees)
    }

    func installCorruptPrimaryForTests() async {
        await flush()
        await vault.writeCorruptPrimary()
    }

    func installCorruptPairForTests() async {
        await vault.writeCorruptPair()
    }

    private func seedDemoIfNeeded() async {
        #if targetEnvironment(simulator)
        if await vault.demoAlreadySeeded() { return }
        applyDemoSeed()
        await vault.markDemoSeeded()
        await flush()
        #endif
    }

    private func applyDemoSeed() {
        chart = .empty()
        let today = DayKey.from(Date())
        let people: [(String, String)] = [
            ("Mira Calder", "4815162342"),
            ("Jonah Peck", "2048102481"),
            ("Adele Voss", "7731946201"),
            ("Chris Lang", "9155001844")
        ]
        for person in people {
            chart.islands.append(IslandRow(id: UUID(), name: person.0, deskDigits: person.1))
        }
        guard chart.islands.count >= 2 else { return }
        fileSealed(
            coachee: chart.islands[0],
            goal: "Ship the brief before Friday.",
            reality: "The brief is still a stack of loose notes.",
            options: ["Block Thursday morning.", "Ask Mira to draft the outline."],
            willIndex: 0,
            readiness: 4,
            dayKey: DayKey.shifted(today, by: -6)
        )
        fileSealed(
            coachee: chart.islands[1],
            goal: "Hold a quieter one to one.",
            reality: "The last meeting ran long and stayed vague.",
            options: ["Send questions the day before.", "End with one next step."],
            willIndex: 1,
            readiness: 3,
            dayKey: DayKey.shifted(today, by: -1)
        )
        let openID = UUID()
        chart.books.append(BookRow(
            id: openID,
            coacheeID: chart.islands[0].id,
            goalInk: "Name the next promotion case in one sentence.",
            realityInk: "The case is still a list of tasks, not a story.",
            phase: .draft
        ))
        chart.runs.openCanvasID = openID
        for island in chart.islands where !chart.books.contains(where: { $0.coacheeID == island.id && $0.phase != .sealed }) {
            let canvasID = UUID()
            chart.books.append(BookRow(
                id: canvasID,
                coacheeID: island.id,
                goalInk: "",
                realityInk: "",
                phase: .draft
            ))
            chart.runs.marks.append(.blank(BlankMark(id: UUID(), canvasID: canvasID)))
        }
        chart.onboardingComplete = true
        chart.rosterPassed = true
    }

    private func fileSealed(
        coachee: IslandRow,
        goal: String,
        reality: String,
        options: [String],
        willIndex: Int,
        readiness: Int,
        dayKey: Int
    ) {
        let canvasID = UUID()
        chart.books.append(BookRow(
            id: canvasID,
            coacheeID: coachee.id,
            goalInk: goal,
            realityInk: reality,
            phase: .sealed
        ))
        var lines: [RhumbRow] = []
        for (index, ink) in options.enumerated() {
            let lineID = UUID()
            lines.append(RhumbRow(id: lineID, canvasID: canvasID, ink: ink, starred: index == willIndex))
            chart.runs.marks.append(.option(OptionMark(id: UUID(), canvasID: canvasID, lineID: lineID, ink: ink)))
        }
        chart.rhumbs.append(contentsOf: lines)
        chart.runs.marks.append(.ground(GroundMark(id: UUID(), canvasID: canvasID, dayKey: dayKey)))
        let sessionID = UUID()
        let will = options.indices.contains(willIndex) ? options[willIndex] : ""
        chart.sessions.append(SessionRow(
            id: sessionID,
            coacheeID: coachee.id,
            canvasID: canvasID,
            goal: goal,
            reality: reality,
            optionLines: options,
            will: will,
            readiness: readiness,
            dayKey: dayKey
        ))
        let successorID = UUID()
        chart.runs.marks.append(.seal(SealMark(
            id: UUID(),
            canvasID: canvasID,
            sessionID: sessionID,
            readiness: readiness,
            dayKey: dayKey,
            successorID: successorID
        )))
        chart.books.append(BookRow(
            id: successorID,
            coacheeID: coachee.id,
            goalInk: "",
            realityInk: "",
            phase: .draft
        ))
        chart.runs.marks.append(.blank(BlankMark(id: UUID(), canvasID: successorID)))
    }

    private func ink(_ keyPath: WritableKeyPath<BookRow, String>, _ text: String, field: String) -> FoldReport {
        guard var book = openBook() else {
            return .refused(nil, notice: "Pick a client first.")
        }
        if book.phase != .draft {
            return .refused(nil, notice: "Goal and Reality stay locked after Ground.")
        }
        book[keyPath: keyPath] = text
        replace(book)
        scheduleSave()
        return .accepted(nil, notice: "Wrote \(field).")
    }

    private func refuseEarly(canvasID: UUID, attempt: String) -> FoldReport {
        let mark = EarlyMark(id: UUID(), canvasID: canvasID, attempt: attempt)
        chart.runs.marks.append(.early(mark))
        scheduleSave()
        return .refused(.early(mark), notice: "Ground Goal and Reality before \(attempt).")
    }

    private func openBook() -> BookRow? {
        guard let id = chart.runs.openCanvasID else { return nil }
        return chart.books.first { $0.id == id }
    }

    private func replace(_ book: BookRow) {
        guard let index = chart.books.firstIndex(where: { $0.id == book.id }) else { return }
        chart.books[index] = book
    }

    private func optionCount(_ canvasID: UUID) -> Int {
        chart.rhumbs.filter { $0.canvasID == canvasID }.count
    }

    private func successorIsEmpty(_ book: BookRow) -> Bool {
        book.phase == .draft
            && book.goalInk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && book.realityInk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && optionCount(book.id) == 0
    }

    private func canvas(id: UUID) -> Canvas? {
        guard let book = chart.books.first(where: { $0.id == id }) else { return nil }
        let lines = chart.rhumbs.filter { $0.canvasID == id }.map {
            Canvas.Line(id: $0.id, ink: $0.ink, starred: $0.starred)
        }
        return Canvas(
            id: book.id,
            coacheeID: book.coacheeID,
            goalInk: book.goalInk,
            realityInk: book.realityInk,
            phase: book.phase,
            lines: lines
        )
    }

    private func book(from canvas: Canvas) -> BookRow {
        BookRow(
            id: canvas.id,
            coacheeID: canvas.coacheeID,
            goalInk: canvas.goalInk,
            realityInk: canvas.realityInk,
            phase: canvas.phase
        )
    }

    private static func note(from row: SessionRow) -> SessionNote {
        SessionNote(
            id: row.id,
            coacheeID: row.coacheeID,
            canvasID: row.canvasID,
            goal: row.goal,
            reality: row.reality,
            optionLines: row.optionLines,
            will: row.will,
            readiness: row.readiness,
            dayKey: row.dayKey
        )
    }

    private func scheduleSave() {
        pendingSave?.cancel()
        let snapshot = chart
        let vault = self.vault
        pendingSave = Task {
            do {
                try await Task.sleep(nanoseconds: 400_000_000)
            } catch {
                return
            }
            await vault.persist(snapshot)
        }
    }

    private func commitNow() {
        pendingSave?.cancel()
        let snapshot = chart
        let vault = self.vault
        pendingSave = Task {
            await vault.persist(snapshot)
        }
    }
}

extension DayKey {
    static func shifted(_ key: Int, by days: Int, calendar: Calendar = .current) -> Int {
        guard let date = date(from: key, calendar: calendar),
              let moved = calendar.date(byAdding: .day, value: days, to: date) else {
            return key
        }
        return from(moved, calendar: calendar)
    }
}
