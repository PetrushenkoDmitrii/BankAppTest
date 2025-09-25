//
//  MainModel.swift
//  BankApp
//
//  Created by Дмитрий Петрушенко on 18/08/2025.
//

import Foundation

struct Currency: Equatable {
    let code: String
    let name: String    
    let symbol: String
    let flag: String
}

struct ExchangeRate {
    let base: Currency
    let quote: Currency
    let rate: Decimal
    let updatedAt: Date
}

struct ConverterPreviewModel {
    var amountBase: Decimal
    var rate: ExchangeRate

    var resultQuote: Decimal { amountBase * rate.rate }
    var baseCurrency: Currency { rate.base }
    var quoteCurrency: Currency { rate.quote }
    var updatedAt: Date { rate.updatedAt }
}
