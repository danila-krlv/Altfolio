//
//  SearchCell.swift
//  Altfolio
//
//  Created by Danila on 01.09.2022.
//

import SwiftUI

struct SearchCell: View {
    var coin: CoinOfCMC

    var body: some View {
        HStack {
            AsyncImg(url: coin.logoUrl)

            VStack(alignment: .leading, spacing: 0.0) {
                HStack {
                    Text(coin.symbol)
                        .font(.title)
                    Text(coin.name)
                }
            }
            Spacer()
        }
        .frame(height: 85)
    }
}
