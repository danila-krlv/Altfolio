//
//  MainCoordinatorTest.swift
//  AltfolioTests
//
//  Created by Danila on 22.10.2022.
//

import SwiftUI
import UIKit
import XCTest
@testable import Altfolio

@MainActor
final class MainCoordinatorTest: XCTestCase {
    func testStartInstallsPortfolioAndAnalyticsTabsWithInjectedServices() throws {
        let storage = CoordinatorStorageSpy()
        let network = CoordinatorNetworkSpy()
        let sut = MainCoordinator(coreData: storage, network: network)

        sut.start()

        let tabs = try XCTUnwrap(sut.rootViewController.viewControllers)
        XCTAssertEqual(tabs.count, 2)
        XCTAssertEqual(tabs.map { $0.tabBarItem.title }, ["Home", "Analytics"])
        let portfolio = try XCTUnwrap(tabs.first as? UINavigationController)
        let analytics = try XCTUnwrap(tabs.last as? UINavigationController)
        XCTAssertTrue(portfolio.viewControllers.first is UIHostingController<PortfolioView>)
        XCTAssertTrue(analytics.viewControllers.first is UIHostingController<AnalyticsView>)
        XCTAssertGreaterThanOrEqual(storage.fetchCount, 1)
        XCTAssertEqual(network.mapRequestCount, 1)
    }

    func testRepeatedStartKeepsExistingTabsAndDoesNotRepeatRequests() throws {
        let network = CoordinatorNetworkSpy()
        let sut = MainCoordinator(coreData: CoordinatorStorageSpy(), network: network)
        sut.start()
        let originalTabs = try XCTUnwrap(sut.rootViewController.viewControllers)

        sut.start()

        let tabs = try XCTUnwrap(sut.rootViewController.viewControllers)
        XCTAssertEqual(tabs.map { ObjectIdentifier($0) }, originalTabs.map { ObjectIdentifier($0) })
        XCTAssertEqual(network.mapRequestCount, 1)
    }
}
