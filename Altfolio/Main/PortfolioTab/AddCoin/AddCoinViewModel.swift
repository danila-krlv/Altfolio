//
//  AddCoinViewModel.swift
//  Altfolio
//
//  Created by Danila on 28.08.2022.
//

import Foundation

final class AddCoinViewModel: ObservableObject {
    @Published var coins = [CoinOfCMC]()
    @Published var selected = CoinOfCMC(id: "1", name: "Bitcoin", rank: 1, slug: "bitcoin", symbol: "BTC")
    @Published var ticker = "btc"
    @Published var amount = ""
    @Published var searchText = ""

    private let network: NetworkProtocol

    var searchResults: [CoinOfCMC] {
        if searchText.isEmpty {
            return coins
        } else {
            return coins.filter { $0.name.hasPrefix(searchText) || $0.symbol.hasPrefix(searchText) }
        }
    }

    init(network: NetworkProtocol) {
        self.network = network
    }

    func updateSelected() {
        DispatchQueue.main.async {
            self.network.fetchLogoURL(id: self.selected.id) { [weak self] logoString in
                guard let strongSelf = self else { return }
                strongSelf.selected.logoUrl = logoString[0]
            }
        }
    }
}
