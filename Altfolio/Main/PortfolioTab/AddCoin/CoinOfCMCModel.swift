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

    init?(json: [String: Any]) {
        let id = json["id"] as! Int
        let name = json["name"] as! String
        let rank = json["rank"] as! Int
        let slug = json["slug"] as! String
        let symbol = json["symbol"] as! String

        self.id = "\(id)"
        self.name = name
        self.rank = rank
        self.slug = slug
        self.symbol = symbol
    }

    init(id: String, name: String, rank: Int, slug: String, symbol: String) {
        self.id = id
        self.name = name
        self.rank = rank
        self.slug = slug
        self.symbol = symbol
    }

    static func getArray(from jsonArray: Any) -> [CoinOfCMC]? {
        guard let jsonArray = jsonArray as? [[String: Any]] else { return nil }
        return jsonArray.compactMap { CoinOfCMC(json: $0) }
    }
}
