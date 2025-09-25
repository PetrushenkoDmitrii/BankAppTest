import Foundation

final class RatesProvider {
    static let shared = RatesProvider()
    private init() {}

    private let wantedFiat = ["USD","EUR","RUB","GBP","JPY","CHF","CNY","PLN","KZT","TRY"]
    private let topFiat    = ["USD","EUR","RUB"]

    private let goldApiKey = "goldapi-11nqsmf33gv7r-io"
    private let fallbackXAU_USD: Double = 2400
    private let fallbackXAG_USD: Double = 30

    func loadTopRates(completion: @escaping (_ rates: [Rate], _ usdUnit: Double?) -> Void) {
        fetchFiatWithChange { [weak self] map, usdUnit in
            guard let self else { return }
            var list = topFiat.compactMap { map[$0] }
            let xauIndex = list.count
            list.append(Rate(currency: "XAU", value: 0, change: 0, flag: "🥇"))
            list.append(Rate(currency: "XAG", value: 0, change: 0, flag: "🥈"))

            guard let u = usdUnit else { self.main { completion(list, nil) }; return }

            fetchMetalsUSD { [weak self] xauUSD, xagUSD in
                guard let self else { return }
                list[xauIndex]     = Rate(currency: "XAU", value: (xauUSD ?? self.fallbackXAU_USD) * u, change: 0, flag: "🥇")
                list[xauIndex + 1] = Rate(currency: "XAG", value: (xagUSD ?? self.fallbackXAG_USD) * u, change: 0, flag: "🥈")
                self.main { completion(list, u) }
            }
        }
    }

    func loadFiatTop10(completion: @escaping (_ rates: [Rate], _ usdUnit: Double?) -> Void) {
        fetchFiatWithChange { [weak self] map, usdUnit in
            guard let self else { return }
            let rows = wantedFiat.compactMap { map[$0] }
            self.main { completion(rows, usdUnit ?? map["USD"]?.value) }
        }
    }

    private func fetchFiatWithChange(completion: @escaping (_ map: [String: Rate], _ usdUnit: Double?) -> Void) {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today.addingTimeInterval(-86400)

        let group = DispatchGroup()
        var todayMap: [String: (value: Double, flag: String)] = [:]
        var yestMap:  [String: Double] = [:]
        var usdUnitToday: Double?

        group.enter()
        fetchNBRB(on: today) { map, usd in
            todayMap = map
            usdUnitToday = usd
            group.leave()
        }

        group.enter()
        fetchNBRB(on: yesterday) { map, _ in
            yestMap = map.mapValues { $0.value }
            group.leave()
        }

        group.notify(queue: .global()) {
            var out: [String: Rate] = ["BYN": Rate(currency: "BYN", value: 1, change: 0, flag: "🇧🇾")]
            let all = Set(self.wantedFiat + self.topFiat)
            for code in all {
                guard let t = todayMap[code] else { continue }
                let todayVal = t.value
                let yVal = yestMap[code] ?? todayVal
                let changePct = (yVal == 0) ? 0 : ((todayVal - yVal) / yVal * 100)
                out[code] = Rate(currency: code, value: todayVal, change: changePct, flag: t.flag)
            }
            completion(out, usdUnitToday)
        }
    }

    private func fetchNBRB(on date: Date,
                           completion: @escaping (_ map: [String: (value: Double, flag: String)], _ usdUnit: Double?) -> Void) {
        var comps = URLComponents(string: "https://api.nbrb.by/exrates/rates")!
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        comps.queryItems = [
            URLQueryItem(name: "periodicity", value: "0"),
            URLQueryItem(name: "ondate", value: df.string(from: date))
        ]
        let url = comps.url!

        URLSession.shared.dataTask(with: url) { data, resp, err in
            guard err == nil,
                  let http = resp as? HTTPURLResponse, http.statusCode == 200,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                completion([:], nil)
                return
            }

            var map: [String: (Double, String)] = [:]
            var usdUnit: Double?

            for obj in json {
                guard let code  = obj["Cur_Abbreviation"] as? String,
                      let scale = obj["Cur_Scale"] as? Int,
                      let off   = obj["Cur_OfficialRate"] as? Double else { continue }

                let unit = off / Double(scale)
                if code == "USD" { usdUnit = unit }
                if self.wantedFiat.contains(code) || self.topFiat.contains(code) {
                    let flag = CurrenciesMeta.flag[code] ?? "🏳️"
                    map[code] = (unit, flag)
                }
            }
            completion(map, usdUnit)
        }.resume()
    }

    private func fetchMetalsUSD(completion: @escaping (_ xauUSD: Double?, _ xagUSD: Double?) -> Void) {
        guard !goldApiKey.isEmpty else { completion(nil, nil); return }

        func make(_ sym: String) -> URLRequest {
            var r = URLRequest(url: URL(string: "https://www.goldapi.io/api/\(sym)/USD")!)
            r.addValue(goldApiKey, forHTTPHeaderField: "x-access-token")
            r.addValue("application/json", forHTTPHeaderField: "Accept")
            return r
        }

        func parse(_ data: Data, _ resp: URLResponse?) -> Double? {
            guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  obj["error"] == nil else { return nil }
            return obj["price"] as? Double
        }

        let g = DispatchGroup()
        var xau: Double?, xag: Double?

        g.enter()
        URLSession.shared.dataTask(with: make("XAU")) { d, r, _ in
            if let d, let p = parse(d, r) { xau = p }
            g.leave()
        }.resume()

        g.enter()
        URLSession.shared.dataTask(with: make("XAG")) { d, r, _ in
            if let d, let p = parse(d, r) { xag = p }
            g.leave()
        }.resume()

        g.notify(queue: .global()) { completion(xau, xag) }
    }

    private func main(_ work: @escaping () -> Void) {
        if Thread.isMainThread { work() } else { DispatchQueue.main.async(execute: work) }
    }
}
