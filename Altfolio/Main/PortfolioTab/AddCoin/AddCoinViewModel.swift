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
    @Published private(set) var networkError: NetworkError?

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
        let coinID = selected.id
        networkError = nil
        network.fetchLogoURL(id: coinID) { [weak self] result in
            guard let self = self, self.selected.id == coinID else { return }
            switch result {
            case .success(let logoURL):
                self.selected.logoUrl = logoURL
            case .failure(let error):
                self.networkError = error
            }
        }
    }
}
