//
//  PortfolioCell.swift
//  Altfolio
//
//  Created by Danila on 27.08.2022.
//

import SwiftUI

struct PortfolioCell: View {
    @ObservedObject var object: Coin

    var body: some View {
        HStack {
            AsyncImg(url: object.logoUrl)

            VStack(alignment: .leading, spacing: 0.0) {
                HStack {
                    Text(object.symbol)
                        .font(.title)
                        .scaledToFill()
                        .lineLimit(1)
                        .minimumScaleFactor(5)
                    Text(object.name)
                        .scaledToFill()
                        .lineLimit(1)
                        .minimumScaleFactor(1)
                }
                Text(removeZerosFromEnd(object.amount))
                    .scaledToFill()
                    .minimumScaleFactor(0.0005)
                    .lineLimit(1)
            }
            Spacer()
            Text(String(format: "%.2f", (object.price * object.amount)) + "$")
                .font(.title3)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(height: 85)
    }
}
