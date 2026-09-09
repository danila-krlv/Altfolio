//
//  PortfolioView.swift
//  Altfolio
//
//  Created by Danila on 27.08.2022.
//

import SwiftUI

struct PortfolioView: View {
    @ObservedObject var viewModel: PortfolioViewModel

    var showAddCoin: () -> Void = {}
    var showDetails: (Coin) -> Void = { _ in }

    @Environment(\.scenePhase) private var scenePhase
    @State private var isVisible = false

    init(viewModel: PortfolioViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 5.0) {
                TotalBalance(balance: viewModel.totalBalance)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)

                List {
                    if #available(iOS 15.0, *) {
                        Text("Tracking list")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                    } else {
                        Text("Tracking list")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    ForEach(self.viewModel.coins) { obj in
                        PortfolioCell(object: obj)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print(obj.amount)
                                showDetails(obj)
                            }
                    }
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Portfolio tracker").font(.headline)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                                .font(.title)
                        }
                        .padding(1.0)
                    }
                }
            }
        }
        .onAppear {
            isVisible = true
            if scenePhase == .active {
                viewModel.startPriceUpdates()
            }
        }
        .onDisappear {
            isVisible = false
            viewModel.stopPriceUpdates()
        }
        .onChange(of: scenePhase) { phase in
            if isVisible && phase == .active {
                viewModel.startPriceUpdates()
            } else {
                viewModel.stopPriceUpdates()
            }
        }
    }

    private func addItem() {
        showAddCoin()
    }

    private func showDetail(_ coin: Coin) {
        showDetails(coin)
    }
}

//struct PortfolioView_Previews: PreviewProvider {
//    static var previews: some View {
//        PortfolioView(viewModel: PortfolioViewModel())
//    }
//}
