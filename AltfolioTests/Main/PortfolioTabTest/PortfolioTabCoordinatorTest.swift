//
//  PortfolioTabCoordinatorTests.swift
//  AltfolioTests
//
//  Created by Danila on 22.10.2022.
//

import XCTest
@testable import Altfolio

class PortfolioCoordinatorTest: XCTestCase {
    var sut: PortfolioCoordinator!

    override func setUpWithError() throws {
        sut = PortfolioCoordinator()
        sut.start()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testViewModelNotNil() throws {
        XCTAssertNotNil(sut.viewModel)
    }

    func testViewModelCoinsMapNotNil() throws {
        XCTAssertNotNil(sut.viewModel.coinsMap)
    }

    func testPortfolioViewNotNil() throws {
        XCTAssertNotNil(sut.portfolioView)
    }
}
