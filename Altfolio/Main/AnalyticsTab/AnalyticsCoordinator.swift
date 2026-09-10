//
//  AnalyticsCoordinator.swift
//  Altfolio
//
//  Created by Danila on 27.08.2022.
//

import SwiftUI
import UIKit

class AnalyticsCoordinator {
    var rootViewController: UINavigationController

    private var viewModel: AnalyticsViewModel

    private lazy var analyticsView: AnalyticsView = {
        let view = AnalyticsView(viewModel: viewModel)
        return view
    }()

    init(coreData: CoreDataProtocol) {
        rootViewController = UINavigationController()
        rootViewController.navigationBar.backgroundColor = .clear
        rootViewController.navigationBar.prefersLargeTitles = false
        rootViewController.isNavigationBarHidden = false
        viewModel = AnalyticsViewModel(coreData: coreData)
    }
}

// MARK: - CoordinatorProtocol
extension AnalyticsCoordinator: CoordinatorProtocol {
    func start() {
        rootViewController.setViewControllers([UIHostingController(rootView: analyticsView)], animated: true)
    }
}
