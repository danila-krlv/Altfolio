//
//  CoinOfCMCModel.swift
//  Altfolio
//
//  Created by Danila on 31.08.2022.
//

import Foundation

struct CoinOfCMC: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let rank: Int
    let slug: String
    let symbol: String
    var logoUrl: String = ""

    init(id: String, name: String, rank: Int, slug: String, symbol: String) {
        self.id = id
        self.name = name
        self.rank = rank
        self.slug = slug
        self.symbol = symbol
    }
}
