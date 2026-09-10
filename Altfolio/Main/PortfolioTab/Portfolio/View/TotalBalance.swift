//
//  TotalBalance.swift
//  Altfolio
//
//  Created by Danila on 27.08.2022.
//

import SwiftUI

struct TotalBalance: View {
    var balance: Int

    let backgroundGradient = LinearGradient(
        colors: [Color.gray, Color.blue],
        startPoint: .leading, endPoint: .trailing)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0.0) {
                Text("Total balance:")
                    .foregroundColor(.white)
                    .font(.title)
                Text("\(balance)$")
                    .foregroundColor(.white)
                    .font(.system(size: 45, weight: .bold, design: .default))
                    .minimumScaleFactor(0.005)
                    .lineLimit(1)
                    .animation(.default, value: balance)
            }
            .padding(.leading)
            Spacer()
        }
        .frame(height: 115)
        .background(backgroundGradient)
        .cornerRadius(15.0)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black, lineWidth: 2)
        )
    }
}

struct TotalBalance_Previews: PreviewProvider {
    static var previews: some View {
        TotalBalance(balance: 10000)
    }
}
