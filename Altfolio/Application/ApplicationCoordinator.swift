//
//  ApplicationCoordinator.swift
//  Altfolio
//
//  Created by Danila on 27.08.2022.
//

import UIKit

final class ApplicationCoordinator {
    let window: UIWindow
    private var childCoordinators = [CoordinatorProtocol]()

    init(window: UIWindow) {
        self.window = window
    }
}

extension ApplicationCoordinator: CoordinatorProtocol {
    func start() {
        let mainCoordinator = MainCoordinator()
        mainCoordinator.start()
        childCoordinators = [mainCoordinator]
        window.rootViewController = mainCoordinator.rootViewController
    }
}
