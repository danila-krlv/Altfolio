//
//  AnalyticsViewModelTests.swift
//  AltfolioTests
//
//  Created by Danila on 10.09.2026.
//

import CoreData
import XCTest
@testable import Altfolio

final class AnalyticsViewModelTests: XCTestCase {
    func testEmptyPortfolioHasNoSlices() throws {
        let storage = try AnalyticsStorageStub()
        let viewModel = AnalyticsViewModel(coreData: storage)
        viewModel.fetchMyCoins()
        XCTAssertTrue(viewModel.pieSlices.isEmpty)
    }

    func testZeroBalanceHasNoSlices() throws {
        let storage = try AnalyticsStorageStub()
        storage.records = [
            storage.coin(symbol: "BTC", price: 0, amount: 1), storage.coin(symbol: "ETH", price: 10, amount: 0),
        ]
        let viewModel = AnalyticsViewModel(coreData: storage)
        viewModel.fetchMyCoins()
        XCTAssertTrue(viewModel.pieSlices.isEmpty)
    }

    func testOneFetchCalculatesPercentagesAndCumulativeBoundaries() throws {
        let storage = try AnalyticsStorageStub()
        storage.records = [
            storage.coin(symbol: "BTC", price: 10, amount: 3), storage.coin(symbol: "ETH", price: 10, amount: 1),
        ]
        let viewModel = AnalyticsViewModel(coreData: storage)
        viewModel.fetchMyCoins()
        XCTAssertEqual(viewModel.pieSlices.map { $0.symbol }, ["BTC", "ETH"])
        XCTAssertEqual(viewModel.pieSlices.map { $0.percent }, [75, 25])
        XCTAssertEqual(viewModel.pieSlices.map { $0.value }, [75, 100])
    }

    func testZeroPositionsDoNotCreateSectors() throws {
        let storage = try AnalyticsStorageStub()
        storage.records = [
            storage.coin(symbol: "BTC", price: 10, amount: 1), storage.coin(symbol: "ETH", price: 0, amount: 1),
        ]
        let viewModel = AnalyticsViewModel(coreData: storage)
        viewModel.fetchMyCoins()
        XCTAssertEqual(viewModel.pieSlices.map { $0.symbol }, ["BTC"])
        XCTAssertEqual(viewModel.pieSlices.map { $0.percent }, [100])
        XCTAssertEqual(viewModel.pieSlices.map { $0.value }, [100])
    }

    func testZeroBalanceClearsPreviousSlices() throws {
        let storage = try AnalyticsStorageStub()
        let coin = storage.coin(symbol: "BTC", price: 10, amount: 1)
        storage.records = [coin]
        let viewModel = AnalyticsViewModel(coreData: storage)
        viewModel.fetchMyCoins()
        XCTAssertEqual(viewModel.pieSlices.count, 1)
        coin.amount = 0
        viewModel.fetchMyCoins()
        XCTAssertTrue(viewModel.pieSlices.isEmpty)
    }

    func testFractionalPercentagesHaveOrderedBoundariesEndingAt100() throws {
        let storage = try AnalyticsStorageStub()
        storage.records = (1...7).map { storage.coin(symbol: String($0), price: 1, amount: 1) }
        let viewModel = AnalyticsViewModel(coreData: storage)
        viewModel.fetchMyCoins()
        XCTAssertEqual(viewModel.pieSlices.count, 7)
        XCTAssertEqual(viewModel.pieSlices.last?.value, 100)
        var previous: CGFloat = 0
        for slice in viewModel.pieSlices {
            XCTAssertEqual(slice.percent, 100.0 / 7, accuracy: 0.000001)
            XCTAssertGreaterThanOrEqual(slice.value, previous)
            XCTAssertLessThanOrEqual(slice.value, 100)
            previous = slice.value
        }
    }

    func testTinyPositiveBalanceDoesNotDivideByAnUnderflowedOnePercent() throws {
        let storage = try AnalyticsStorageStub()
        storage.records = [storage.coin(symbol: "BTC", price: Double.leastNonzeroMagnitude, amount: 1)]
        let viewModel = AnalyticsViewModel(coreData: storage)
        viewModel.fetchMyCoins()
        XCTAssertEqual(viewModel.pieSlices.map { $0.percent }, [100])
        XCTAssertEqual(viewModel.pieSlices.map { $0.value }, [100])
    }

    func testInvalidBalancesDoNotProduceInvalidSectors() throws {
        let storage = try AnalyticsStorageStub()
        let viewModel = AnalyticsViewModel(coreData: storage)
        for value in [-1.0, Double.infinity, Double.nan] {
            storage.records = [storage.coin(symbol: "BTC", price: value, amount: 1)]
            viewModel.fetchMyCoins()
            XCTAssertTrue(viewModel.pieSlices.isEmpty)
        }
        storage.records = (1...2).map {
            storage.coin(symbol: String($0), price: Double.greatestFiniteMagnitude, amount: 1)
        }
        viewModel.fetchMyCoins()
        XCTAssertTrue(viewModel.pieSlices.isEmpty)
    }
}

private final class AnalyticsStorageStub: CoreDataProtocol {
    var records = [CoinCD]()
    private let context: NSManagedObjectContext

    init() throws {
        let model = try XCTUnwrap(NSManagedObjectModel.mergedModel(from: [Bundle(for: CoinCD.self)]))
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    }

    func coin(symbol: String, price: Double, amount: Double) -> CoinCD {
        let coin = CoinCD(context: context)
        coin.symbol = symbol
        coin.price = price
        coin.amount = amount
        return coin
    }

    func fetchMyCoins() -> [CoinCD] { records }
    func resetAllRecords() { XCTFail("Unexpected mutation") }
    func saveContext() { XCTFail("Unexpected mutation") }
    func createNew(coin: CoinOfCMC, value: Double) -> CoinCD? {
        XCTFail("Unexpected mutation")
        return nil
    }
    func createTrans(value: Double) -> Transaction? {
        XCTFail("Unexpected mutation")
        return nil
    }
    func deleteCoin(_ coinCD: CoinCD) { XCTFail("Unexpected mutation") }
}
