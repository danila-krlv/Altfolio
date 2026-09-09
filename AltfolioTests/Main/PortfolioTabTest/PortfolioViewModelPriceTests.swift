//
//  PortfolioViewModelPriceTests.swift
//  AltfolioTests
//
//  Created by Danila on 10.09.2026.
//

import CoreData
import XCTest
@testable import Altfolio

final class PortfolioViewModelPriceTests: XCTestCase {
    func testPricesMatchIDsWhenCollectionsHaveDifferentOrderAndLength() throws {
        let storage = try PortfolioStorageStub()
        let first = storage.makeCoin(id: "1", price: 5)
        let second = storage.makeCoin(id: "2", price: 6)
        storage.records = [first, second]
        let network = PortfolioNetworkStub()
        let viewModel = PortfolioViewModel(coreData: storage, network: network)
        viewModel.fetchMyCoins()
        viewModel.coins = [viewModel.coins[1]]

        viewModel.updateAllPrices()
        network.completions[0](.success(["1": 10, "2": 20]))

        XCTAssertEqual(first.price, 10)
        XCTAssertEqual(second.price, 20)
        XCTAssertEqual(viewModel.coins[0].id, "2")
        XCTAssertEqual(viewModel.coins[0].price, 20)
        XCTAssertEqual(viewModel.totalBalance, 20)
        XCTAssertEqual(storage.saveCount, 1)
    }

    func testRemovedCoinIsNotUpdatedByDelayedResponse() throws {
        let storage = try PortfolioStorageStub()
        let removed = storage.makeCoin(id: "1", price: 5)
        let remaining = storage.makeCoin(id: "2", price: 6)
        storage.records = [removed, remaining]
        let network = PortfolioNetworkStub()
        let viewModel = PortfolioViewModel(coreData: storage, network: network)
        viewModel.fetchMyCoins()
        viewModel.updateAllPrices()
        viewModel.deleteCoin(removed)

        network.completions[0](.success(["1": 10, "2": 20]))

        XCTAssertEqual(removed.price, 5)
        XCTAssertEqual(remaining.price, 20)
        XCTAssertEqual(viewModel.coins.map { $0.id }, ["2"])
        XCTAssertEqual(viewModel.totalBalance, 20)
    }

    func testMissingIDsAndMissingPricesDoNotPreventOtherUpdates() throws {
        let storage = try PortfolioStorageStub()
        let invalid = storage.makeCoin(id: nil, price: 5)
        let first = storage.makeCoin(id: "1", price: 6)
        let second = storage.makeCoin(id: "2", price: 7)
        storage.records = [invalid, first, second]
        let network = PortfolioNetworkStub()
        let viewModel = PortfolioViewModel(coreData: storage, network: network)
        viewModel.fetchMyCoins()

        viewModel.updateAllPrices()
        network.completions[0](.success(["2": 20]))

        XCTAssertEqual(network.requestedIDs, [["1", "2"]])
        XCTAssertEqual(invalid.price, 5)
        XCTAssertEqual(first.price, 6)
        XCTAssertEqual(second.price, 20)
    }

    func testSingleCoinWithoutPriceKeepsPreviousValue() throws {
        let storage = try PortfolioStorageStub()
        let coin = storage.makeCoin(id: "1", price: 5)
        storage.records = [coin]
        let network = PortfolioNetworkStub()
        let viewModel = PortfolioViewModel(coreData: storage, network: network)
        viewModel.fetchMyCoins()

        viewModel.fetchPrice(coinId: "1")
        network.completions[0](.success([:]))

        XCTAssertEqual(coin.price, 5)
        XCTAssertEqual(viewModel.coins[0].price, 5)
        XCTAssertEqual(storage.saveCount, 0)
    }

    func testSameSymbolDoesNotMergeDifferentCoins() throws {
        let storage = try PortfolioStorageStub()
        let first = storage.makeCoin(id: "1", price: 5)
        let second = storage.makeCoin(id: "2", price: 6)
        storage.records = [first, second]
        let viewModel = PortfolioViewModel(coreData: storage, network: PortfolioNetworkStub())
        viewModel.fetchMyCoins()

        viewModel.save(coin: CoinOfCMC(id: "2", name: "Second", rank: 2, slug: "second", symbol: "SAME"), amount: "3")

        XCTAssertEqual(first.amount, 1)
        XCTAssertEqual(second.amount, 4)
        XCTAssertEqual(viewModel.coins.first { $0.id == "1" }?.amount, 1)
        XCTAssertEqual(viewModel.coins.first { $0.id == "2" }?.amount, 4)
    }

    func testRepeatedStartCreatesOneTimerAndStopPreventsFurtherTicks() throws {
        let storage = try PortfolioStorageStub()
        storage.records = [storage.makeCoin(id: "1", price: 5)]
        let network = PortfolioNetworkStub()
        let timers = PriceTimerSpy()
        let viewModel = PortfolioViewModel(coreData: storage, network: network, makePriceUpdateTimer: timers.makeTimer)
        viewModel.fetchMyCoins()

        viewModel.startPriceUpdates()
        viewModel.startPriceUpdates()
        XCTAssertEqual(timers.timers.count, 1)
        XCTAssertEqual(network.requestedIDs.count, 1)
        timers.timers[0].fire()
        XCTAssertEqual(network.requestedIDs.count, 2)

        viewModel.stopPriceUpdates()
        XCTAssertFalse(timers.timers[0].isValid)
        timers.timers[0].fire()
        XCTAssertEqual(network.requestedIDs.count, 2)

        viewModel.startPriceUpdates()
        XCTAssertEqual(timers.timers.count, 2)
        XCTAssertEqual(network.requestedIDs.count, 3)
    }

    func testEmptyPortfolioWaitsForCoinsAndStopsAfterLastDeletion() throws {
        let storage = try PortfolioStorageStub()
        let network = PortfolioNetworkStub()
        let timers = PriceTimerSpy()
        let viewModel = PortfolioViewModel(coreData: storage, network: network, makePriceUpdateTimer: timers.makeTimer)
        viewModel.fetchMyCoins()
        viewModel.startPriceUpdates()
        XCTAssertTrue(timers.timers.isEmpty)
        XCTAssertTrue(network.requestedIDs.isEmpty)

        let coin = storage.makeCoin(id: "1", price: 5)
        storage.records = [coin]
        viewModel.fetchMyCoins()
        XCTAssertEqual(timers.timers.count, 1)
        viewModel.deleteCoin(coin)
        XCTAssertFalse(timers.timers[0].isValid)
        XCTAssertEqual(viewModel.totalBalance, 0)
    }

    func testAddingFirstCoinStartsTimerWhenUpdatesAreEnabled() throws {
        let storage = try PortfolioStorageStub()
        let network = PortfolioNetworkStub()
        let timers = PriceTimerSpy()
        let viewModel = PortfolioViewModel(coreData: storage, network: network, makePriceUpdateTimer: timers.makeTimer)
        viewModel.startPriceUpdates()

        viewModel.save(coin: CoinOfCMC(id: "1", name: "Bitcoin", rank: 1, slug: "bitcoin", symbol: "BTC"), amount: "1")

        XCTAssertEqual(timers.timers.count, 1)
        XCTAssertEqual(network.requestedIDs, [["1"]])
    }

    func testReloadDoesNotRestartExplicitlyStoppedTimer() throws {
        let storage = try PortfolioStorageStub()
        storage.records = [storage.makeCoin(id: "1", price: 5)]
        let timers = PriceTimerSpy()
        let viewModel = PortfolioViewModel(
            coreData: storage, network: PortfolioNetworkStub(), makePriceUpdateTimer: timers.makeTimer)
        viewModel.fetchMyCoins()
        viewModel.startPriceUpdates()
        viewModel.stopPriceUpdates()

        viewModel.fetchMyCoins()

        XCTAssertEqual(timers.timers.count, 1)
        XCTAssertFalse(timers.timers[0].isValid)
    }

    func testTimerDoesNotRetainViewModelAndIsInvalidatedOnDeinit() throws {
        let storage = try PortfolioStorageStub()
        storage.records = [storage.makeCoin(id: "1", price: 5)]
        let timers = PriceTimerSpy()
        var viewModel: PortfolioViewModel? = PortfolioViewModel(
            coreData: storage, network: PortfolioNetworkStub(), makePriceUpdateTimer: timers.makeTimer)
        viewModel?.fetchMyCoins()
        viewModel?.startPriceUpdates()
        weak var weakViewModel = viewModel

        viewModel = nil

        XCTAssertNil(weakViewModel)
        XCTAssertFalse(timers.timers[0].isValid)
    }
}

private final class PriceTimerSpy {
    var timers = [Timer]()

    func makeTimer(action: @escaping () -> Void) -> Timer {
        let timer = Timer(timeInterval: 30, repeats: true) { _ in action() }
        timers.append(timer)
        return timer
    }
}

private final class PortfolioStorageStub: CoreDataProtocol {
    var records = [CoinCD]()
    var saveCount = 0

    private let context: NSManagedObjectContext

    init() throws {
        let model = try XCTUnwrap(NSManagedObjectModel.mergedModel(from: [Bundle(for: CoinCD.self)]))
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    }

    func makeCoin(id: String?, price: Double) -> CoinCD {
        let coin = CoinCD(context: context)
        coin.id = id
        coin.name = "Coin"
        coin.symbol = "SAME"
        coin.logoUrl = ""
        coin.price = price
        coin.amount = 1
        return coin
    }

    func fetchMyCoins() -> [CoinCD] { records }
    func resetAllRecords() { records.removeAll() }
    func saveContext() { saveCount += 1 }

    func createNew(coin: CoinOfCMC, value: Double) -> CoinCD? {
        let record = makeCoin(id: coin.id, price: 0)
        record.amount = value
        record.symbol = coin.symbol
        records.append(record)
        return record
    }

    func createTrans(value: Double) -> Transaction? {
        let transaction = Transaction(context: context)
        transaction.amount = value
        return transaction
    }

    func deleteCoin(_ coinCD: CoinCD) {
        records.removeAll { $0 === coinCD }
    }
}

private final class PortfolioNetworkStub: NetworkProtocol {
    var requestedIDs = [[String]]()
    var completions = [(Result<[String: Double], NetworkError>) -> Void]()

    func fetchPriceArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: Double], NetworkError>) -> Void
    ) {
        XCTAssertEqual(idString, idArray.joined(separator: ","))
        requestedIDs.append(idArray)
        completions.append(completion)
    }

    func fetchMap(completion: @escaping (Result<[CoinOfCMC], NetworkError>) -> Void) { XCTFail("Unexpected request") }
    func fetchLogoURL(id: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        XCTFail("Unexpected request")
    }
    func fetchLogoUrlArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: String], NetworkError>) -> Void
    ) { XCTFail("Unexpected request") }
    func fetchImg(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        XCTFail("Unexpected request")
    }
}
