//
//  DetailsView.swift
//  Altfolio
//
//  Created by Danila on 07.11.2022.
//

import SwiftUI

struct DetailsView: View {
    @ObservedObject var viewModel: DetailsViewModel

    var saveCoin: () -> Void = {}
    var popDetails: () -> Void = {}
    var popDetailsWithDelete: () -> Void = {}

    @State private var presentAlert = false
    @State private var addOrRemove = true

    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DetailsCell(object: viewModel.coin)

                VStack(spacing: 10) {
                    TextField("add amount", text: $viewModel.value)
                        .contentShape(Rectangle())
                        .frame(width: 216, height: 40.0)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 1)
                        )

                    HStack(spacing: 20) {
                        Button {
                            if Double(viewModel.value) != nil {
                                viewModel.saveValue(addBool: true)
                            }
                        } label: {
                            Text("Add")
                                .font(.title2)
                                .bold()
                                .frame(width: 100, height: 40, alignment: .center)
                        }
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)

                        Button {
                            if Double(viewModel.value) != nil {
                                viewModel.saveValue(addBool: false)
                            }
                        } label: {
                            Text("Remove")
                                .font(.title2)
                                .bold()
                                .frame(width: 100, height: 40, alignment: .center)
                        }
                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                    }
                }
                .padding()

                ScrollView {
                    VStack {
                        Text("Transaction history")
                        ForEach(viewModel.history) { trans in
                            TransactionCell(trans: trans, symbol: viewModel.coinCD.symbolW)
                        }
                    }
                    .padding(.bottom, 30)

                    Button {
                        presentAlert = true
                    } label: {
                        Text("Delete coin")
                            .foregroundColor(Color.red)
                    }
                }
            }

            .alert(
                "Warning", isPresented: $presentAlert,
                actions: {
                    Button(
                        "Accept",
                        action: {
                            popAndDelete()
                        })
                    Button("Cancel", role: .cancel, action: {})
                },
                message: {
                    Text("You will delete the coin and its entire history")
                }
            )

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: pop) {
                        Label("%%%%", systemImage: "chevron.left")
                            .font(.title)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func save() {
        saveCoin()
    }

    private func pop() {
        popDetails()
    }

    private func popAndDelete() {
        popDetailsWithDelete()
    }
}
