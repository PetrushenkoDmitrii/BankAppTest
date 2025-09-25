//

import Foundation


enum CurrenciesMeta {

    static let fiatName: [String: String] = [
        "USD":"Доллар США","EUR":"Евро","RUB":"Российский рубль","GBP":"Фунт стерлингов",
        "JPY":"Японская иена","CHF":"Швейцарский франк","CNY":"Китайский юань",
        "PLN":"Польский злотый","KZT":"Казахстанский тенге","TRY":"Турецкая лира","BYN":"Белорусский рубль"
    ]

    static let fiatSymbol: [String: String] = [
        "USD":"$","EUR":"€","RUB":"₽","GBP":"£","JPY":"¥","CHF":"₣","CNY":"¥",
        "PLN":"zł","KZT":"₸","TRY":"₺","BYN":"Br"
    ]

    static let flag: [String: String] = [
        "USD":"🇺🇸","EUR":"🇪🇺","RUB":"🇷🇺","GBP":"🇬🇧","JPY":"🇯🇵","CHF":"🇨🇭",
        "CNY":"🇨🇳","PLN":"🇵🇱","KZT":"🇰🇿","TRY":"🇹🇷","BYN":"🇧🇾"
    ]

    static let cryptoName: [String: String] = [
        "BTC":"Bitcoin","ETH":"Ethereum","USDT":"Tether","BNB":"BNB","XRP":"XRP",
        "ADA":"Cardano","DOGE":"Dogecoin","SOL":"Solana","TRX":"TRON","DOT":"Polkadot"
    ]
}
