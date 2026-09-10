//
//  TransactionCell.swift
//  Altfolio
//
//  Created by Danila on 10.11.2022.
//

import SwiftUI

struct TransactionCell: View {
    let trans: Transaction
    let symbol: String

    var body: some View {
        HStack {
            Text(trans.dateW).padding(.leading, 20.0)
            Spacer()
            Text(
                (trans.addBool ? "+" : "-") + removeZerosFromEnd(trans.amount) + " " + symbol
            )
            .foregroundColor(trans.addBool ? .green : .red)
            .padding(.trailing, 20.0)
        }
        .padding()
    }
}
