import Foundation

/// Projects the in-memory chart onto UserDefaults off the main actor.
/// A failed decode restores the backup key, then an empty chart.
actor ChartVault {
    enum Bank: Sendable {
        case standard
        case suite(String)
    }

    private let bank: Bank
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(bank: Bank) {
        self.bank = bank
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    func load() -> (record: ChartRecord, notice: String?) {
        let defaults = box()
        if let data = defaults.data(forKey: ChartRecord.storageKey) {
            if let record = decode(data) {
                return (record, nil)
            }
            if let backup = defaults.data(forKey: ChartRecord.backupKey), let record = decode(backup) {
                return (record, "The chart was unreadable. Restored the previous copy.")
            }
            return (.empty(), "The chart was unreadable. Started from an empty roster.")
        }
        return (.empty(), nil)
    }

    func persist(_ record: ChartRecord) {
        let defaults = box()
        let data: Data
        do {
            data = try encoder.encode(record)
        } catch {
            return
        }
        if let previous = defaults.data(forKey: ChartRecord.storageKey) {
            defaults.set(previous, forKey: ChartRecord.backupKey)
        }
        defaults.set(data, forKey: ChartRecord.storageKey)
    }

    func demoAlreadySeeded() -> Bool {
        box().bool(forKey: ChartRecord.demoKey)
    }

    func markDemoSeeded() {
        box().set(true, forKey: ChartRecord.demoKey)
    }

    func writeCorruptPrimary() {
        let defaults = box()
        if let previous = defaults.data(forKey: ChartRecord.storageKey) {
            defaults.set(previous, forKey: ChartRecord.backupKey)
        }
        defaults.set(Data("{".utf8), forKey: ChartRecord.storageKey)
    }

    func writeCorruptPair() {
        let defaults = box()
        defaults.set(Data("{".utf8), forKey: ChartRecord.storageKey)
        defaults.set(Data("}".utf8), forKey: ChartRecord.backupKey)
    }

    private func decode(_ data: Data) -> ChartRecord? {
        try? decoder.decode(ChartRecord.self, from: data)
    }

    private func box() -> UserDefaults {
        switch bank {
        case .standard:
            return .standard
        case .suite(let name):
            if let named = UserDefaults(suiteName: name) {
                return named
            }
            return .standard
        }
    }
}
