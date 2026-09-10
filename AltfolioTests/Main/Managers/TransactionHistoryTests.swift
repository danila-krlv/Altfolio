//
//  TransactionHistoryTests.swift
//  AltfolioTests
//
//  Created by Danila on 10.09.2026.
//

import CoreData
import XCTest
@testable import Altfolio

final class TransactionHistoryTests: XCTestCase {
    func testHistorySortsAcrossMonthAndYearBoundaries() throws {
        let context = try makeContext()
        let coin = CoinCD(context: context)
        let december = try transaction(in: context, year: 2023, month: 12, day: 31)
        let january = try transaction(in: context, year: 2024, month: 1, day: 1)
        let endOfJanuary = try transaction(in: context, year: 2024, month: 1, day: 31)
        let february = try transaction(in: context, year: 2024, month: 2, day: 1)
        coin.history = NSSet(array: [february, january, endOfJanuary, december])

        XCTAssertEqual(
            coin.historyArray.map { $0.objectID }, [december, january, endOfJanuary, february].map { $0.objectID })
    }

    func testHistorySortsByTimeWithinSameDay() throws {
        let context = try makeContext()
        let coin = CoinCD(context: context)
        let earlier = try transaction(in: context, year: 2024, month: 1, day: 1)
        let later = Transaction(context: context)
        later.date = try XCTUnwrap(earlier.date).addingTimeInterval(1)
        coin.history = NSSet(array: [later, earlier])

        XCTAssertEqual(coin.historyArray.map { $0.objectID }, [earlier.objectID, later.objectID])
    }

    func testMissingDatesSortAfterKnownDates() throws {
        let context = try makeContext()
        let coin = CoinCD(context: context)
        let known = try transaction(in: context, year: 2024, month: 1, day: 1)
        let unknown = Transaction(context: context)
        coin.history = NSSet(array: [unknown, known])

        XCTAssertEqual(coin.historyArray.map { $0.objectID }, [known.objectID, unknown.objectID])
        XCTAssertNil(unknown.date)
        XCTAssertEqual(unknown.dateW, "Unknown date")
    }

    func testEqualAndMissingDatesHaveRepeatableOrder() throws {
        let context = try makeContext()
        let coin = CoinCD(context: context)
        let first = try transaction(in: context, year: 2024, month: 1, day: 1)
        let second = Transaction(context: context)
        second.date = first.date
        let unknown = Transaction(context: context)
        let anotherUnknown = Transaction(context: context)
        coin.history = NSSet(array: [anotherUnknown, second, unknown, first])

        let knownIDs = [first, second].map { $0.objectID.uriRepresentation().absoluteString }.sorted()
        let unknownIDs = [unknown, anotherUnknown].map { $0.objectID.uriRepresentation().absoluteString }.sorted()
        XCTAssertEqual(coin.historyArray.map { $0.objectID.uriRepresentation().absoluteString }, knownIDs + unknownIDs)
        XCTAssertEqual(coin.historyArray.map { $0.objectID }, coin.historyArray.map { $0.objectID })
    }

    func testEmptyHistoryReturnsEmptyArray() throws {
        let context = try makeContext()
        let coin = CoinCD(context: context)
        XCTAssertTrue(coin.historyArray.isEmpty)
    }

    func testDisplayUsesCalendarYearAtEndOfDecember() throws {
        let context = try makeContext()
        let transaction = try transaction(in: context, year: 2019, month: 12, day: 30)
        XCTAssertEqual(transaction.dateW, "30/12/2019 - 12:00:00")
    }

    func testDisplayPreservesLeapDayAndTime() throws {
        let context = try makeContext()
        let transaction = try transaction(in: context, year: 2024, month: 2, day: 29)
        XCTAssertEqual(transaction.dateW, "29/02/2024 - 12:00:00")
    }

    private func makeContext() throws -> NSManagedObjectContext {
        let model = try XCTUnwrap(NSManagedObjectModel.mergedModel(from: [Bundle(for: CoinCD.self)]))
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        return context
    }

    private func transaction(in context: NSManagedObjectContext, year: Int, month: Int, day: Int) throws -> Transaction
    {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        let transaction = Transaction(context: context)
        transaction.date = try XCTUnwrap(
            calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12)))
        return transaction
    }
}
