//
//  PieChart.swift
//  Altfolio
//
//  Created by Danila on 13.02.2023.
//

import SwiftUI

struct PieChart: View {

    @ObservedObject private var viewModel: AnalyticsViewModel
    @State private var indexOfTappedSlice = -1
    @State private var show = false

    init(viewModel: AnalyticsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if viewModel.pieSlices.isEmpty {
                Text("No balance to display")
                    .foregroundColor(.secondary)
            } else {
                ZStack {
                    ForEach(0..<viewModel.pieSlices.count, id: \.self) { index in
                        Circle()
                            .trim(
                                from: index == 0 ? 0.0 : viewModel.pieSlices[index - 1].value / 100,
                                to: viewModel.pieSlices[index].value / 100
                            )
                            .stroke(
                                Color(
                                    red: viewModel.pieSlices[index].r,
                                    green: viewModel.pieSlices[index].g,
                                    blue: viewModel.pieSlices[index].b
                                ),
                                lineWidth: 100
                            )
                            .scaleEffect(index == indexOfTappedSlice ? 1.1 : 1.0)
                            .animation(.spring(), value: show)
                    }
                }
                .frame(width: 100, height: 200)

                ForEach(0..<viewModel.pieSlices.count, id: \.self) { index in
                    HStack {
                        Text(viewModel.pieSlices[index].symbol)
                        Text(String(format: "%.2f", Double(viewModel.pieSlices[index].percent)) + "%")
                            .font(indexOfTappedSlice == index ? .headline : .subheadline)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                Color(
                                    red: viewModel.pieSlices[index].r,
                                    green: viewModel.pieSlices[index].g,
                                    blue: viewModel.pieSlices[index].b
                                )
                            )
                            .frame(width: 15, height: 15)
                    }
                    .onTapGesture {
                        indexOfTappedSlice = indexOfTappedSlice == index ? -1 : index
                        self.show.toggle()
                    }
                }
                .padding(8)
                .frame(width: 300, alignment: .trailing)
            }
        }
        .onAppear {
            viewModel.fetchMyCoins()
            indexOfTappedSlice = -1
            self.show.toggle()
        }
    }
}
