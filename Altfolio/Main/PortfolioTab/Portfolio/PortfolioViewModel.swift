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
    private let makePriceUpdateTimer: (@escaping () -> Void) -> Timer

    private var timer: Timer?
    private var isPriceUpdatingEnabled = false

    private var priceCoinIDs: [String] {
        Array(
            Set(
                coinsCD.compactMap { coin -> String? in
                    guard !coin.isDeleted, let id = coin.id, !id.isEmpty else { return nil }
                    return id
                })
        ).sorted()
    }

    init(
        coreData: CoreDataProtocol,
        network: NetworkProtocol,
        makePriceUpdateTimer: @escaping (@escaping () -> Void) -> Timer = { action in
            let timer = Timer(timeInterval: 30.0, repeats: true) { _ in action() }
            timer.tolerance = 0.1
            RunLoop.main.add(timer, forMode: .common)
            return timer
        }
    ) {
        self.coreData = coreData
        self.network = network
        self.makePriceUpdateTimer = makePriceUpdateTimer
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - CoreData layer
    func fetchMyCoins() {
        coinsCD = coreData.fetchMyCoins()
        coins.removeAll()
        for coin in coinsCD {
            coins.append(initCoin(coin))
        }
        updateTotalBalance()
        synchronizePriceUpdateTimer()
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

        if let coinCD = coinsCD.first(where: { $0.id == coin.id }) {
            guard let trans = coreData.createTrans(value: value) else { return }
            coins.first { $0.id == coin.id }?.amount += value
            coinCD.amount += value
            coinCD.addToHistory(trans)
            coreData.saveContext()
            updateTotalBalance()
        } else {
            guard let coinCD = coreData.createNew(coin: coin, value: value) else { return }
            coinsCD.append(coinCD)
            coins.append(initCoin(coinCD))
            synchronizePriceUpdateTimer()
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

    // MARK: - Price updates
    func startPriceUpdates() {
        guard !isPriceUpdatingEnabled else { return }
        isPriceUpdatingEnabled = true
        synchronizePriceUpdateTimer()
        updateAllPrices()
    }

    func stopPriceUpdates() {
        isPriceUpdatingEnabled = false
        timer?.invalidate()
        timer = nil
    }

    private func synchronizePriceUpdateTimer() {
        guard isPriceUpdatingEnabled, !priceCoinIDs.isEmpty else {
            timer?.invalidate()
            timer = nil
            return
        }
        guard timer == nil else { return }
        timer = makePriceUpdateTimer { [weak self] in
            self?.updateAllPrices()
        }
    }

    func updateAllPrices() {
        synchronizePriceUpdateTimer()
        let ids = priceCoinIDs
        guard !ids.isEmpty else { return }
        fetchPrices(ids: ids)
    }

    func fetchPrice(coinId: String) {
        fetchPrices(ids: [coinId])
    }

    private func fetchPrices(ids: [String]) {
        network.fetchPriceArray(idString: ids.joined(separator: ","), idArray: ids) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let prices):
                self.networkError = nil
                self.applyPrices(prices)
            case .failure(let error):
                self.networkError = error
            }
        }
    }

    private func applyPrices(_ prices: [String: Double]) {
        // The collections can change order or membership while the request is in flight.
        for coin in coins {
            guard let price = prices[coin.id] else { continue }
            coin.price = price
        }
        var hasStoredPrices = false
        for coin in coinsCD {
            guard !coin.isDeleted, let id = coin.id, let price = prices[id] else { continue }
            coin.price = price
            hasStoredPrices = true
        }
        updateTotalBalance()
        if hasStoredPrices {
            coreData.saveContext()
        }
    }

    // MARK: - Network layer
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
