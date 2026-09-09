//
//  CoinModel.swift
//  Altfolio
//
//  Created by Danila on 07.11.2022.
//

import Foundation

class Coin: ObservableObject, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let logoUrl: String

    @Published var amount: Double
    @Published var price: Double

    init(id: String, name: String, symbol: String, logoUrl: String, amount: Double, price: Double) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.logoUrl = logoUrl
        self.amount = amount
        self.price = price
    }
}
