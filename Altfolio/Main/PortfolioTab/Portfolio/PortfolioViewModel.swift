//
//  PortfolioViewModel.swift
//  Altfolio
//
//  Created by Danila on 27.08.2022.
//

import Foundation

final class PortfolioViewModel: ObservableObject {
    @Published var coinsMap = [CoinOfCMC]()
    @Published var coinsCD = [CoinCD]()
    @Published var coins = [Coin]()
    @Published var totalBalance: Int = 0
    @Published var networkError: NetworkError?

    private let coreData: CoreDataProtocol
    private let network: NetworkProtocol

    private var timer: Timer?

    init(coreData: CoreDataProtocol, network: NetworkProtocol) {
        self.coreData = coreData
        self.network = network
    }

    // MARK: - CoreData layer
    func fetchMyCoins() {
        coinsCD = coreData.fetchMyCoins()
        coins.removeAll()
        for coin in coinsCD {
            coins.append(initCoin(coin))
        }
    }

    private func initCoin(_ coin: CoinCD) -> Coin {
        let coin = Coin(
            id: coin.idW, name: coin.nameW, symbol: coin.symbolW,
            logoUrl: coin.logoUrlW, amount: coin.amount, price: coin.price)
        return coin
    }

    func save(coin: CoinOfCMC, amount: String) {
        if amount == "" { return }
        guard let value = Double(amount) else { return }

        if let coinCD = coinsCD.filter({ $0.symbol == coin.symbol }).first {
            guard let trans = coreData.createTrans(value: value) else { return }
            coins.filter { $0.symbol == coin.symbol }.first?.amount += value
            coinCD.amount += value
            coinCD.addToHistory(trans)
            coreData.saveContext()
            updateTotalBalance()
        } else {
            guard let coinCD = coreData.createNew(coin: coin, value: value) else { return }
            coinsCD.append(coinCD)
            coins.append(initCoin(coinCD))
            fetchPrice(coinId: coin.id)
            coreData.saveContext()
        }
    }

    func deleteCoin(_ coinCD: CoinCD) {
        coreData.deleteCoin(coinCD)
        fetchMyCoins()
    }

    // MARK: - update totalBalance
    func updateTotalBalance() {
        var total: Double = 0.0
        for coin in coins {
            total += (coin.price * coin.amount)
        }
        totalBalance = Int(total)
    }

    // MARK: - Network layer
    @objc func updateAllPrices() {
        if coinsCD.isEmpty { return }

        if timer == nil {
            let timer = Timer(
                timeInterval: 30.0,
                target: self,
                selector: #selector(updateAllPrices),
                userInfo: nil,
                repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            self.timer = timer
        }

        print("updateAllPrices")
        var idArray = [String]()
        var idString = ""

        for (index, coin) in self.coins.enumerated() {
            idArray.append(coin.id)

            if index == 0 {
                idString += coin.id
            } else {
                idString += "," + coin.id
            }
        }

        DispatchQueue.main.async {
            self.network.fetchPriceArray(idString: idString, idArray: idArray) { [weak self] result in
                guard let strongSelf = self else { return }
                let prices: [String: Double]
                switch result {
                case .success(let values):
                    prices = values
                    strongSelf.networkError = nil
                case .failure(let error):
                    strongSelf.networkError = error
                    return
                }

                for (index, _) in strongSelf.coinsCD.enumerated() {
                    if strongSelf.coinsCD[index].id == nil { return }
                    guard let price = prices[strongSelf.coins[index].id] else {
                        print("error guard updatePrice()")
                        return
                    }

                    strongSelf.coinsCD[index].price = price
                    strongSelf.coins[index].price = price
                    strongSelf.updateTotalBalance()
                }
                strongSelf.coreData.saveContext()
            }
        }
    }

    func fetchPrice(coinId: String) {
        network.fetchPriceArray(idString: coinId, idArray: [coinId]) { [weak self] result in
            guard let strongSelf = self else { return }
            let prices: [String: Double]
            switch result {
            case .success(let values):
                prices = values
                strongSelf.networkError = nil
            case .failure(let error):
                strongSelf.networkError = error
                return
            }
            strongSelf.coins.filter { $0.id == coinId }.first?.price = prices[coinId] ?? 0.0
            strongSelf.coinsCD.filter { $0.id == coinId }.first?.price = prices[coinId] ?? 0.0
            strongSelf.coreData.saveContext()
            strongSelf.updateTotalBalance()
        }
    }

    func updateURL() {
        var idArray = [String]()
        var idString = ""

        for (index, coin) in self.coinsMap.enumerated() {
            idArray.append(coin.id)
            if index == 0 {
                idString += coin.id
            } else {
                idString += "," + coin.id
            }
        }

        DispatchQueue.main.async {
            self.network.fetchLogoUrlArray(idString: idString, idArray: idArray) { [weak self] result in
                guard let strongSelf = self else { return }
                let logoDict: [String: String]
                switch result {
                case .success(let values):
                    logoDict = values
                    strongSelf.networkError = nil
                case .failure(let error):
                    strongSelf.networkError = error
                    return
                }
                for (index, _) in strongSelf.coinsMap.enumerated() {
                    guard let urlStr = logoDict[strongSelf.coinsMap[index].id] else {
                        print("error guard updateURL()")
                        return
                    }
                    strongSelf.coinsMap[index].logoUrl = urlStr
                }
            }
        }
    }
}
