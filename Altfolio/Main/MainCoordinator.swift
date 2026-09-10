//
//  MainCoordinator.swift
//  Altfolio
//
//  Created by Danila on 27.08.2022.
//

import Foundation
import SwiftUI
import UIKit

final class MainCoordinator {
    var rootViewController: UITabBarController
    private let coreDataManager: CoreDataProtocol
    private let networkManager: NetworkProtocol

    private var childCoordinators = [CoordinatorProtocol]()

    init(coreData: CoreDataProtocol = CoreDataManager(), network: NetworkProtocol = NetworkManager()) {
        coreDataManager = coreData
        networkManager = network
        rootViewController = UITabBarController()
        rootViewController.tabBar.isTranslucent = true
    }

    private func setup(vc: UIViewController, title: String, imageName: String, selectedImageName: String) {
        let defaultImage = UIImage(systemName: imageName)
        let selectedImage = UIImage(systemName: selectedImageName)
        let tabBarItem = UITabBarItem(title: title, image: defaultImage, selectedImage: selectedImage)
        vc.tabBarItem = tabBarItem
    }
}

extension MainCoordinator: CoordinatorProtocol {
    func start() {
        guard childCoordinators.isEmpty else { return }

        let portfolioCoordinator = PortfolioCoordinator(coreData: coreDataManager, network: networkManager)
        portfolioCoordinator.start()
        childCoordinators.append(portfolioCoordinator)
        let portfolioView = portfolioCoordinator.rootViewController
        setup(vc: portfolioView, title: "Home", imageName: "paperplane", selectedImageName: "paperplane.fill")

        let analyticsCoordinator = AnalyticsCoordinator(coreData: coreDataManager)
        analyticsCoordinator.start()
        childCoordinators.append(analyticsCoordinator)
        let analyticsView = analyticsCoordinator.rootViewController
        setup(vc: analyticsView, title: "Analytics", imageName: "bell", selectedImageName: "bell.fill")

        rootViewController.viewControllers = [portfolioView, analyticsView]
    }
}
