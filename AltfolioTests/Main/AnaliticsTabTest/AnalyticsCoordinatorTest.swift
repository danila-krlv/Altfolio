//
//  AnalyticsCoordinatorTest.swift
//  AltfolioTests
//
//  Created by Danila on 11.11.2022.
//

import XCTest
@testable import Altfolio

class AnalyticsCoordinatorTest: XCTestCase {
    var sut: AnalyticsCoordinator!

    override func setUpWithError() throws {
        sut = AnalyticsCoordinator()
        sut.start()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testViewModelNotNil() throws {
        XCTAssertNotNil(sut.viewModel)
    }

    func testAnalyticsViewNotNil() throws {
        XCTAssertNotNil(sut.analyticsView)
    }
}
