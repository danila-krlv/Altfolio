//
//  AnalyticsViewModel.swift
//  Altfolio
//
//  Created by Danila on 27.08.2022.
//

import Foundation

struct PieSlice {
    var id = UUID()
    var symbol: String
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var percent: CGFloat
    var value: CGFloat
}

final class AnalyticsViewModel: ObservableObject {
    @Published var pieSlices = [PieSlice]()

    private let coreData: CoreDataProtocol

    private var coinsCD = [CoinCD]()
    private var totalBalance = 0.0

    init(coreData: CoreDataProtocol) {
        self.coreData = coreData
    }

    func calculateCumulativePercentages() {
        var value: CGFloat = 0

        for i in 0..<pieSlices.count {
            value += pieSlices[i].percent
            pieSlices[i].value = value
        }
    }

    func fetchMyCoins() {
        coinsCD = coreData.fetchMyCoins()
        updateTotalBalance()
        calculatePercentages()
    }

    private func updateTotalBalance() {
        var total: Double = 0.0

        for coin in coinsCD {
            total += (coin.price * coin.amount)
        }
        totalBalance = total
    }

    private func calculatePercentages() {
        pieSlices.removeAll()
        let onePercent = totalBalance / 100.0

        for coin in coinsCD {
            pieSlices.append(
                PieSlice(
                    symbol: coin.symbolW, r: random(), g: random(), b: random(),
                    percent: (coin.price * coin.amount) / onePercent, value: 0))
        }
    }

    private func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
