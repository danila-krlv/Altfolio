//
//  AnalyticsCoordinatorTest.swift
//  AltfolioTests
//
//  Created by Danila on 11.11.2022.
//

import SwiftUI
import XCTest
@testable import Altfolio

@MainActor
final class AnalyticsCoordinatorTest: XCTestCase {
    func testStartInstallsAnalyticsScreenUsingInjectedStorage() throws {
        let storage = CoordinatorStorageSpy()
        let sut = AnalyticsCoordinator(coreData: storage)

        sut.start()

        XCTAssertEqual(sut.rootViewController.viewControllers.count, 1)
        let screen = try XCTUnwrap(sut.rootViewController.viewControllers.first as? UIHostingController<AnalyticsView>)
        let previousFetchCount = storage.fetchCount
        screen.rootView.viewModel.fetchMyCoins()
        XCTAssertEqual(storage.fetchCount, previousFetchCount + 1)
        XCTAssertTrue(screen.rootView.viewModel.pieSlices.isEmpty)
    }
}
