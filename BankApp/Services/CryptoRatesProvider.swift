import Foundation

final class CryptoRatesProvider {
    static let shared = CryptoRatesProvider()
    private init() {}

    private struct CryptoRateDTO: Decodable {
        let id: String
        let symbol: String   
        let name: String
        let current_price: Double
        let price_change_percentage_24h: Double?
    }

    func loadTopCrypto(completion: @escaping ([Rate]) -> Void) {
        let url = URL(string:
          "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false"
        )!

        URLSession.shared.dataTask(with: url) { data, resp, err in
            guard err == nil,
                  let http = resp as? HTTPURLResponse, http.statusCode == 200,
                  let data = data,
                  let list = try? JSONDecoder().decode([CryptoRateDTO].self, from: data)
            else { return completion([]) }

            let rates: [Rate] = list.map {
                Rate(
                    currency: $0.symbol.uppercased(),
                    value: $0.current_price,
                    change: $0.price_change_percentage_24h ?? 0,
                    flag: ""
                )
            }
            completion(rates)
        }.resume()
    }
}
