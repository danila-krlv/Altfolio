//
//  PortfolioTabCoordinatorTest.swift
//  AltfolioTests
//
//  Created by Danila on 22.10.2022.
//

import SwiftUI
import XCTest
@testable import Altfolio

@MainActor
final class PortfolioCoordinatorTest: XCTestCase {
    func testStartInstallsPortfolioScreenAndLoadsInjectedServices() throws {
        let storage = CoordinatorStorageSpy()
        let network = CoordinatorNetworkSpy()
        let sut = PortfolioCoordinator(coreData: storage, network: network)

        sut.start()

        XCTAssertEqual(sut.rootViewController.viewControllers.count, 1)
        let screen = try XCTUnwrap(sut.rootViewController.viewControllers.first as? UIHostingController<PortfolioView>)
        XCTAssertTrue(screen.rootView.viewModel.coins.isEmpty)
        XCTAssertEqual(storage.fetchCount, 1)
        XCTAssertEqual(network.mapRequestCount, 1)
    }

    func testMapFailureReachesInstalledScreen() throws {
        let network = CoordinatorNetworkSpy()
        let sut = PortfolioCoordinator(coreData: CoordinatorStorageSpy(), network: network)
        sut.start()
        let screen = try XCTUnwrap(sut.rootViewController.viewControllers.first as? UIHostingController<PortfolioView>)

        network.mapCompletion?(.failure(.api(code: 1008, message: "Request limit reached")))

        guard let error = screen.rootView.viewModel.networkError, case .api(let code, _) = error else {
            return XCTFail("Expected the map failure in the screen's view model")
        }
        XCTAssertEqual(code, 1008)
    }

    func testAddCoinActionPushesScreenUsingInjectedNetwork() throws {
        let network = CoordinatorNetworkSpy()
        let sut = PortfolioCoordinator(coreData: CoordinatorStorageSpy(), network: network)
        sut.start()
        let portfolio = try XCTUnwrap(
            sut.rootViewController.viewControllers.first as? UIHostingController<PortfolioView>)

        portfolio.rootView.showAddCoin()

        XCTAssertEqual(sut.rootViewController.viewControllers.count, 2)
        let addCoin = try XCTUnwrap(sut.rootViewController.topViewController as? UIHostingController<AddCoinView>)
        XCTAssertEqual(network.requestedLogoIDs, ["1"])
        XCTAssertEqual(addCoin.rootView.viewModel.selected.logoUrl, "https://example.com/coin.png")
    }
}
