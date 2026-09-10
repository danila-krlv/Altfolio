//
//  CoordinatorTestDoubles.swift
//  AltfolioTests
//
//  Created by Danila on 10.09.2026.
//

import Foundation
import XCTest
@testable import Altfolio

final class CoordinatorStorageSpy: CoreDataProtocol {
    private(set) var fetchCount = 0

    func fetchMyCoins() -> [CoinCD] {
        fetchCount += 1
        return []
    }

    func resetAllRecords() { XCTFail("Unexpected storage mutation") }
    func saveContext() { XCTFail("Unexpected storage mutation") }
    func createNew(coin: CoinOfCMC, value: Double) -> CoinCD? {
        XCTFail("Unexpected storage mutation")
        return nil
    }
    func createTrans(value: Double) -> Transaction? {
        XCTFail("Unexpected storage mutation")
        return nil
    }
    func deleteCoin(_ coinCD: CoinCD) { XCTFail("Unexpected storage mutation") }
}

final class CoordinatorNetworkSpy: NetworkProtocol {
    private(set) var mapRequestCount = 0
    private(set) var requestedLogoIDs = [String]()
    var mapCompletion: ((Result<[CoinOfCMC], NetworkError>) -> Void)?

    func fetchMap(completion: @escaping (Result<[CoinOfCMC], NetworkError>) -> Void) {
        mapRequestCount += 1
        mapCompletion = completion
    }

    func fetchLogoURL(id: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        requestedLogoIDs.append(id)
        completion(.success("https://example.com/coin.png"))
    }

    func fetchLogoUrlArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: String], NetworkError>) -> Void
    ) {
        completion(
            .success(
                Dictionary(
                    idArray.map { ($0, "https://example.com/coin.png") }, uniquingKeysWith: { first, _ in first })))
    }

    func fetchImg(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        XCTFail("Unexpected image request")
    }

    func fetchPriceArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: Double], NetworkError>) -> Void
    ) {
        XCTFail("Unexpected price request for an empty portfolio")
    }
}
