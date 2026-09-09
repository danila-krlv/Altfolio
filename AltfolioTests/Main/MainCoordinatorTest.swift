//
//  MainCoordinatorTest.swift
//  AltfolioTests
//
//  Created by Danila on 22.10.2022.
//

import XCTest
@testable import Altfolio

class MainCoordinatorTest: XCTestCase {
    var sut: MainCoordinator!

    override func setUpWithError() throws {
        sut = MainCoordinator()
        sut.start()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testValueChildCoordinator() throws {
        XCTAssertEqual(sut.childCoordinators.count, 2)
    }
}
