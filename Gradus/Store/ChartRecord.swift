import Foundation

/// One chart document. Collection names are storage fields. Domain types stay outside this file's rows.
struct ChartRecord: Sendable, Equatable {
    static let storageKey = "grd.chart.v1"
    static let backupKey = "grd.chart.v1.backup"
    static let demoKey = "grd.demo.v1"
    static let currentSchema = 1

    var schemaVersion: Int
    var islands: [IslandRow]
    var books: [BookRow]
    var sessions: [SessionRow]
    var runs: RunLedger
    var rhumbs: [RhumbRow]
    var onboardingComplete: Bool
    var rosterPassed: Bool

    static func empty() -> ChartRecord {
        ChartRecord(
            schemaVersion: currentSchema,
            islands: [],
            books: [],
            sessions: [],
            runs: RunLedger(openCanvasID: nil, marks: []),
            rhumbs: [],
            onboardingComplete: false,
            rosterPassed: false
        )
    }
}

struct IslandRow: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var deskDigits: String
}

struct BookRow: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var coacheeID: UUID
    var goalInk: String
    var realityInk: String
    var phase: CanvasPhase
}

struct SessionRow: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var coacheeID: UUID
    var canvasID: UUID
    var goal: String
    var reality: String
    var optionLines: [String]
    var will: String
    var readiness: Int
    var dayKey: Int
}

struct RhumbRow: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var canvasID: UUID
    var ink: String
    var starred: Bool
}

struct RunLedger: Codable, Sendable, Equatable {
    var openCanvasID: UUID?
    var marks: [ChartMark]
}

enum ChartMark: Sendable, Equatable {
    case ground(GroundMark)
    case option(OptionMark)
    case seal(SealMark)
    case thin(ThinMark)
    case early(EarlyMark)
    case aimless(Aimless)
    case blank(BlankMark)
}

extension ChartRecord: Codable {
    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case islands
        case books
        case sessions
        case runs
        case rhumbs
        case onboardingComplete
        case rosterPassed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            islands = try container.decode([IslandRow].self, forKey: .islands)
            books = try container.decode([BookRow].self, forKey: .books)
            sessions = try container.decode([SessionRow].self, forKey: .sessions)
            runs = try container.decode(RunLedger.self, forKey: .runs)
            rhumbs = try container.decode([RhumbRow].self, forKey: .rhumbs)
            onboardingComplete = try container.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
            rosterPassed = try container.decodeIfPresent(Bool.self, forKey: .rosterPassed) ?? false
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported chart schema \(version)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(islands, forKey: .islands)
        try container.encode(books, forKey: .books)
        try container.encode(sessions, forKey: .sessions)
        try container.encode(runs, forKey: .runs)
        try container.encode(rhumbs, forKey: .rhumbs)
        try container.encode(onboardingComplete, forKey: .onboardingComplete)
        try container.encode(rosterPassed, forKey: .rosterPassed)
    }
}

extension ChartMark: Codable {
    private enum Kind: String, Codable {
        case ground, option, seal, thin, early, aimless, blank
    }

    private enum CodingKeys: String, CodingKey {
        case kind, ground, option, seal, thin, early, aimless, blank
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .ground:
            self = .ground(try container.decode(GroundMark.self, forKey: .ground))
        case .option:
            self = .option(try container.decode(OptionMark.self, forKey: .option))
        case .seal:
            self = .seal(try container.decode(SealMark.self, forKey: .seal))
        case .thin:
            self = .thin(try container.decode(ThinMark.self, forKey: .thin))
        case .early:
            self = .early(try container.decode(EarlyMark.self, forKey: .early))
        case .aimless:
            self = .aimless(try container.decode(Aimless.self, forKey: .aimless))
        case .blank:
            self = .blank(try container.decode(BlankMark.self, forKey: .blank))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .ground(let mark):
            try container.encode(Kind.ground, forKey: .kind)
            try container.encode(mark, forKey: .ground)
        case .option(let mark):
            try container.encode(Kind.option, forKey: .kind)
            try container.encode(mark, forKey: .option)
        case .seal(let mark):
            try container.encode(Kind.seal, forKey: .kind)
            try container.encode(mark, forKey: .seal)
        case .thin(let mark):
            try container.encode(Kind.thin, forKey: .kind)
            try container.encode(mark, forKey: .thin)
        case .early(let mark):
            try container.encode(Kind.early, forKey: .kind)
            try container.encode(mark, forKey: .early)
        case .aimless(let mark):
            try container.encode(Kind.aimless, forKey: .kind)
            try container.encode(mark, forKey: .aimless)
        case .blank(let mark):
            try container.encode(Kind.blank, forKey: .kind)
            try container.encode(mark, forKey: .blank)
        }
    }
}
