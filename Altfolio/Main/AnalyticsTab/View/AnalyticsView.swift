//
//  AnalyticsView.swift
//  Altfolio
//
//  Created by Danila on 27.08.2022.
//

import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: AnalyticsViewModel

    init(viewModel: AnalyticsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        PieChart(viewModel: viewModel)
    }
}
