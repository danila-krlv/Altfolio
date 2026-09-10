//
//  AddCoinViewModelNetworkTests.swift
//  AltfolioTests
//
//  Created by Danila on 10.09.2026.
//

import XCTest
@testable import Altfolio

final class AddCoinViewModelNetworkTests: XCTestCase {
    func testLogoFailurePreservesExistingLogoAndPublishesError() {
        let network = NetworkStub()
        let viewModel = AddCoinViewModel(network: network)
        viewModel.selected.logoUrl = "https://example.com/existing.png"

        viewModel.updateSelected()
        network.logoCompletion?(.failure(.api(code: 1008, message: "Request limit reached")))

        XCTAssertEqual(viewModel.selected.logoUrl, "https://example.com/existing.png")
        guard let error = viewModel.networkError, case .api(let code, _) = error else {
            return XCTFail("Expected the view model to expose the API error")
        }
        XCTAssertEqual(code, 1008)
    }

    func testSuccessfulRetryUpdatesLogoAndClearsError() {
        let network = NetworkStub()
        let viewModel = AddCoinViewModel(network: network)
        viewModel.updateSelected()
        network.logoCompletion?(.failure(.missingData("Logo")))

        viewModel.updateSelected()
        network.logoCompletion?(.success("https://example.com/bitcoin.png"))

        XCTAssertNil(viewModel.networkError)
        XCTAssertEqual(viewModel.selected.logoUrl, "https://example.com/bitcoin.png")
    }

    func testResponseForPreviouslySelectedCoinIsIgnored() {
        let network = NetworkStub()
        let viewModel = AddCoinViewModel(network: network)
        viewModel.updateSelected()
        XCTAssertEqual(network.requestedID, "1")
        viewModel.selected = CoinOfCMC(id: "1027", name: "Ethereum", rank: 2, slug: "ethereum", symbol: "ETH")

        network.logoCompletion?(.success("https://example.com/bitcoin.png"))

        XCTAssertEqual(viewModel.selected.logoUrl, "")
        XCTAssertNil(viewModel.networkError)
    }
}

private final class NetworkStub: NetworkProtocol {
    var requestedID: String?
    var logoCompletion: ((Result<String, NetworkError>) -> Void)?

    func fetchLogoURL(id: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        requestedID = id
        logoCompletion = completion
    }

    func fetchMap(completion: @escaping (Result<[CoinOfCMC], NetworkError>) -> Void) {
        XCTFail("Unexpected map request")
    }

    func fetchLogoUrlArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: String], NetworkError>) -> Void
    ) {
        XCTFail("Unexpected metadata request")
    }

    func fetchImg(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        XCTFail("Unexpected image request")
    }

    func fetchPriceArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: Double], NetworkError>) -> Void
    ) {
        XCTFail("Unexpected price request")
    }
}
