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
    @Published private(set) var pieSlices = [PieSlice]()

    private let coreData: CoreDataProtocol

    init(coreData: CoreDataProtocol) {
        self.coreData = coreData
    }

    func fetchMyCoins() {
        let balances = coreData.fetchMyCoins().map { coin in
            (symbol: coin.symbolW, value: coin.price * coin.amount)
        }
        let totalBalance = balances.reduce(0.0) { $0 + $1.value }
        // A pie chart requires finite, nonnegative values and a positive total.
        guard totalBalance.isFinite, totalBalance > 0,
            balances.allSatisfy({ $0.value.isFinite && $0.value >= 0 })
        else {
            pieSlices = []
            return
        }

        let positiveBalances = balances.filter { $0.value > 0 }
        var cumulativePercent: CGFloat = 0
        let slices = positiveBalances.enumerated().map { index, balance in
            let percent = CGFloat((balance.value / totalBalance) * 100)
            cumulativePercent = min(cumulativePercent + percent, 100)
            if index == positiveBalances.count - 1 {
                cumulativePercent = 100
            }
            return PieSlice(
                symbol: balance.symbol, r: random(), g: random(), b: random(),
                percent: percent, value: cumulativePercent
            )
        }
        pieSlices = slices
    }

    private func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
