import XCTest
@testable import Gradus

@MainActor
final class GradusTests: XCTestCase {
    private func makeStore() -> PracticeStore {
        let name = "grd.tests.\(UUID().uuidString)"
        return PracticeStore(bank: .suite(name), seedsDemo: false)
    }

    func testReviewLaunchParsesArgument() {
        let screen = ReviewLaunch.screen
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: ReviewLaunch.argument), index + 1 < arguments.count {
            XCTAssertEqual(screen, arguments[index + 1])
        } else {
            XCTAssertNil(screen)
        }
        XCTAssertEqual(ReviewLaunch.argument, "-ReviewScreen")
    }

    /// SOAP, GROW, and DAP notes share this rule: section count matches titles.
    func testSectionCountMatchesTitlesAndReadinessRange() async {
        let store = makeStore()
        await store.load()
        let coachee = store.addCoachee(name: "Mira Calder", deskDigits: "4815162342")
        _ = store.inkGoal("Ship the brief.")
        _ = store.inkReality("Notes are still loose.")
        _ = store.groundTheReality(dayKey: 20260920)
        _ = store.addOption(ink: "Block Thursday.")
        let second = store.addOption(ink: "Draft the outline.")
        if case .option(let mark) = second.mark {
            _ = store.starAsWill(lineID: OptionMark.starAsWill(lineID: mark.lineID))
        }
        _ = store.sealTheWill(readiness: 4, dayKey: 20260920)
        let note = store.notes[0]
        XCTAssertEqual(note.sectionBodies.count, SessionNote.sectionTitles.count)
        XCTAssertEqual(SessionNote.sectionTitles, Quadrant.titles)
        XCTAssertTrue(note.readinessInRange)
        XCTAssertEqual(note.coacheeID, coachee.id)
        let brief = store.nextSessionBrief(on: 20260927)
        XCTAssertEqual(brief?.latest.id, note.id)
        XCTAssertEqual(brief?.daysSinceSeal, DayKey.daysBetween(note.dayKey, 20260927))
        XCTAssertEqual(coachee.daysSinceSeal(latestDayKey: note.dayKey, on: 20260927), brief?.daysSinceSeal)
    }

    func testGroundEmptyPopulatedAndSecondGround() async {
        let store = makeStore()
        await store.load()
        _ = store.addCoachee(name: "Jonah Peck", deskDigits: "2048102481")
        let thin = store.groundTheReality(dayKey: 20260927)
        XCTAssertTrue(thin.refused)
        if case .thin = thin.mark {} else { XCTFail("expected thin") }
        XCTAssertEqual(store.openCanvas?.phase, .draft)

        _ = store.inkGoal("Hold a quieter meeting.")
        let stillThin = store.groundTheReality(dayKey: 20260927)
        XCTAssertTrue(stillThin.refused)
        XCTAssertEqual(store.openCanvas?.phase, .draft)

        _ = store.inkReality("The last meeting stayed vague.")
        let grounded = store.groundTheReality(dayKey: 20260927)
        XCTAssertFalse(grounded.refused)
        XCTAssertEqual(store.openCanvas?.phase, .grounded)
        if case .ground = grounded.mark {} else { XCTFail("expected ground") }

        let again = store.groundTheReality(dayKey: 20260927)
        XCTAssertTrue(again.refused)
        XCTAssertNil(again.mark)
        XCTAssertEqual(store.openCanvas?.phase, .grounded)
    }

    func testGroundThenBranchTwist() async {
        let store = makeStore()
        await store.load()
        _ = store.addCoachee(name: "Adele Voss", deskDigits: "7731946201")
        let early = store.addOption(ink: "Too soon.")
        XCTAssertTrue(early.refused)
        if case .early = early.mark {} else { XCTFail("expected early") }
        XCTAssertEqual(store.openCanvas?.lines.count, 0)

        _ = store.inkGoal("Name the case.")
        _ = store.inkReality("It is still a task list.")
        _ = store.groundTheReality(dayKey: 20260901)
        let first = store.addOption(ink: "Write one sentence.")
        XCTAssertFalse(first.refused)
        XCTAssertEqual(store.openCanvas?.phase, .grounded)
        let earlyWill = store.starAsWill(lineID: UUID())
        XCTAssertTrue(earlyWill.refused)
        XCTAssertNil(earlyWill.mark)

        let second = store.addOption(ink: "Ask for a reader.")
        XCTAssertEqual(store.openCanvas?.phase, .branched)
        guard case .option(let option) = second.mark else {
            return XCTFail("expected option")
        }
        let aimless = store.sealTheWill(readiness: 3, dayKey: 20260901)
        XCTAssertTrue(aimless.refused)
        if case .aimless = aimless.mark {} else { XCTFail("expected aimless") }
        XCTAssertEqual(store.openCanvas?.phase, .branched)

        _ = store.starAsWill(lineID: option.lineID)
        XCTAssertEqual(store.openCanvas?.starredLineID, option.lineID)
        let badReadiness = store.sealTheWill(readiness: 0, dayKey: 20260901)
        XCTAssertTrue(badReadiness.refused)
        XCTAssertNil(badReadiness.mark)
        XCTAssertEqual(store.openCanvas?.phase, .branched)

        let sealed = store.sealTheWill(readiness: 5, dayKey: 20260901)
        XCTAssertFalse(sealed.refused)
        if case .seal = sealed.mark {} else { XCTFail("expected seal") }
        XCTAssertEqual(store.notes.count, 1)
        XCTAssertEqual(store.notes[0].readiness, 5)
        XCTAssertEqual(store.openCanvas?.phase, .draft)
        XCTAssertEqual(store.openCanvas?.goalInk, "")
        XCTAssertTrue(store.openCanvas?.lines.isEmpty == true)

        let retracted = store.retractLastSeal()
        XCTAssertFalse(retracted.refused)
        XCTAssertEqual(store.notes.count, 0)
        XCTAssertEqual(store.openCanvas?.phase, .branched)
        XCTAssertEqual(store.openCanvas?.starredLineID, option.lineID)

        _ = store.sealTheWill(readiness: 2, dayKey: 20260902)
        _ = store.inkGoal("Do not retract.")
        let blocked = store.retractLastSeal()
        XCTAssertTrue(blocked.refused)
        XCTAssertEqual(store.notes.count, 1)
    }

    func testRetractDoesNotPeelWhenAnotherEmptyBoardIsOpen() async {
        let store = makeStore()
        await store.load()
        _ = store.addCoachee(name: "Adele Voss", deskDigits: "7731946201")
        _ = store.inkGoal("Name the case.")
        _ = store.inkReality("It is still a task list.")
        _ = store.groundTheReality(dayKey: 20260901)
        _ = store.addOption(ink: "Write one sentence.")
        let second = store.addOption(ink: "Ask for a reader.")
        guard case .option(let option) = second.mark else {
            return XCTFail("expected option")
        }
        _ = store.starAsWill(lineID: option.lineID)
        let sealed = store.sealTheWill(readiness: 4, dayKey: 20260901)
        XCTAssertFalse(sealed.refused)
        let successor = store.openCanvas?.id
        _ = store.addCoachee(name: "Jonah Peck", deskDigits: "2048102481")
        XCTAssertNotEqual(store.openCanvas?.id, successor)
        let peeled = store.retractLastSeal()
        XCTAssertTrue(peeled.refused)
        XCTAssertEqual(store.notes.count, 1)
        XCTAssertEqual(store.openCanvas?.coacheeID, store.coachees.last?.id)
        store.focus(coacheeID: store.coachees[0].id)
        XCTAssertEqual(store.openCanvas?.id, successor)
        let restored = store.retractLastSeal()
        XCTAssertFalse(restored.refused)
        XCTAssertEqual(store.notes.count, 0)
    }

    func testFocusOpensBlankWhenEveryBoardIsSealed() async {
        let name = "grd.tests.\(UUID().uuidString)"
        let coacheeID = UUID()
        let sealedID = UUID()
        var chart = ChartRecord.empty()
        chart.islands = [IslandRow(id: coacheeID, name: "Jonah Peck", deskDigits: "2048102481")]
        chart.books = [BookRow(
            id: sealedID,
            coacheeID: coacheeID,
            goalInk: "Hold a quieter meeting.",
            realityInk: "It ran long.",
            phase: .sealed
        )]
        chart.runs = RunLedger(
            openCanvasID: sealedID,
            marks: [.seal(SealMark(
                id: UUID(),
                canvasID: sealedID,
                sessionID: UUID(),
                readiness: 3,
                dayKey: 20260901,
                successorID: nil
            ))]
        )
        let vault = ChartVault(bank: .suite(name))
        await vault.persist(chart)
        let store = PracticeStore(bank: .suite(name), seedsDemo: false)
        await store.load()
        store.focus(coacheeID: coacheeID)
        XCTAssertEqual(store.openCanvas?.phase, .draft)
        XCTAssertEqual(store.openCanvas?.goalInk, "")
        XCTAssertEqual(store.openCanvas?.coacheeID, coacheeID)
        XCTAssertNotEqual(store.openCanvas?.id, sealedID)
        let peeled = store.retractLastSeal()
        XCTAssertTrue(peeled.refused)
        XCTAssertEqual(store.notes.count, 0)
        XCTAssertNotEqual(store.openCanvas?.id, sealedID)
    }

    func testPersistenceRoundTripAndCorruptRecovery() async {
        let name = "grd.tests.\(UUID().uuidString)"
        let store = PracticeStore(bank: .suite(name), seedsDemo: false)
        await store.load()
        _ = store.addCoachee(name: "Chris Lang", deskDigits: "9155001844")
        _ = store.inkGoal("Keep the notes here.")
        _ = store.inkReality("Nothing leaves the device.")
        _ = store.groundTheReality(dayKey: 20260927)
        await store.flush()

        let reloaded = PracticeStore(bank: .suite(name), seedsDemo: false)
        await reloaded.load()
        XCTAssertEqual(reloaded.openCanvas?.phase, .grounded)
        XCTAssertEqual(reloaded.openCanvas?.goalInk, "Keep the notes here.")
        XCTAssertEqual(reloaded.coachees.map(\.name), ["Chris Lang"])
        XCTAssertNil(reloaded.recoveryMessage)

        await reloaded.installCorruptPrimaryForTests()
        let restored = PracticeStore(bank: .suite(name), seedsDemo: false)
        await restored.load()
        XCTAssertEqual(restored.openCanvas?.goalInk, "Keep the notes here.")
        XCTAssertNotNil(restored.recoveryMessage)

        await restored.installCorruptPairForTests()
        let emptied = PracticeStore(bank: .suite(name), seedsDemo: false)
        await emptied.load()
        XCTAssertTrue(emptied.coachees.isEmpty)
        XCTAssertNotNil(emptied.recoveryMessage)

        _ = emptied.addCoachee(name: "Temp", deskDigits: "12345678")
        await emptied.resetAllData()
        let afterReset = PracticeStore(bank: .suite(name), seedsDemo: false)
        await afterReset.load()
        XCTAssertTrue(afterReset.coachees.isEmpty)
        XCTAssertNil(afterReset.openCanvas)
    }

    func testDeskCodeResolvesLocallyAndUserAgentStaysLocal() {
        let roster = [Coachee(id: UUID(), name: "Mira Calder", deskDigits: "4815162342")]
        XCTAssertEqual(DeskLookup.userAgent, "Gradus/1.0 (iOS; +https://gradus-canvas.pro)")
        XCTAssertEqual(DeskLookup.coachee(matching: "desk:4815162342", roster: roster)?.name, "Mira Calder")
        XCTAssertNil(DeskLookup.coachee(matching: "1234", roster: roster))
    }

    func testSimulatorSeedLeavesGroundEnabled() async {
        #if targetEnvironment(simulator)
        let name = "grd.tests.\(UUID().uuidString)"
        let store = PracticeStore(bank: .suite(name), seedsDemo: true)
        await store.load()
        XCTAssertTrue(store.onboardingComplete)
        XCTAssertTrue(store.rosterPassed)
        XCTAssertGreaterThanOrEqual(store.coachees.count, 4)
        XCTAssertGreaterThanOrEqual(store.notes.count, 2)
        XCTAssertEqual(store.openCanvas?.phase, .draft)
        XCTAssertFalse(store.openCanvas?.goalInk.isEmpty ?? true)
        XCTAssertFalse(store.openCanvas?.realityInk.isEmpty ?? true)
        let ground = store.groundTheReality(dayKey: DayKey.from(Date()))
        XCTAssertFalse(ground.refused)
        let again = PracticeStore(bank: .suite(name), seedsDemo: true)
        await again.load()
        XCTAssertEqual(again.notes.count, store.notes.count)
        #endif
    }
}
