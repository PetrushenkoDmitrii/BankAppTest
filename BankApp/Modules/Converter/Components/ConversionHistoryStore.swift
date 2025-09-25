import Foundation

struct ConversionRecord: Codable, Equatable {
    let baseCode: String
    let baseFlag: String
    let quoteCode: String
    let quoteFlag: String
    let amountBase: Double
    let amountQuote: Double
    let rate: Double
    let timestamp: Date
}

final class ConversionHistoryStore {
    static let shared = ConversionHistoryStore()
    private init() {}

    private let key = "conversion_history_v1"
    private let maxRecords = 50

    func load() -> [ConversionRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let arr = try? JSONDecoder().decode([ConversionRecord].self, from: data) else { return [] }
        return arr
    }

    func add(_ rec: ConversionRecord) {
        var arr = load()
        if let last = arr.first, isNearEqual(last, rec) { return }
        arr.insert(rec, at: 0)
        if arr.count > maxRecords { arr.removeLast(arr.count - maxRecords) }
        save(arr)
    }

    func remove(at index: Int) {
        var arr = load()
        guard arr.indices.contains(index) else { return }
        arr.remove(at: index)
        save(arr)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Helpers
    private func save(_ arr: [ConversionRecord]) {
        if let data = try? JSONEncoder().encode(arr) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func isNearEqual(_ a: ConversionRecord, _ b: ConversionRecord) -> Bool {
        guard a.baseCode == b.baseCode, a.quoteCode == b.quoteCode else { return false }
        func close(_ x: Double, _ y: Double) -> Bool { abs(x - y) < 0.0001 }
        return close(a.amountBase, b.amountBase) && close(a.amountQuote, b.amountQuote)
    }
}
