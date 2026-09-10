//
//  CMCResponseTests.swift
//  AltfolioTests
//
//  Created by Danila on 10.09.2026.
//

import XCTest
@testable import Altfolio

final class CMCResponseTests: XCTestCase {
    func testMapConvertsNumericIDToDomainString() throws {
        let response = try decode(
            [CMCCoin].self,
            json: """
                {"status":{"error_code":0,"error_message":null},"data":[
                    {"id":1,"name":"Bitcoin","rank":1,"slug":"bitcoin","symbol":"BTC"}
                ]}
                """)
        let coin = try XCTUnwrap(response.data.first).coin
        XCTAssertEqual(coin.id, "1")
        XCTAssertEqual(coin.name, "Bitcoin")
        XCTAssertEqual(coin.rank, 1)
        XCTAssertEqual(coin.slug, "bitcoin")
        XCTAssertEqual(coin.symbol, "BTC")
        XCTAssertEqual(coin.logoUrl, "")
    }

    func testMalformedCoinThrowsInsteadOfForceCasting() {
        XCTAssertThrowsError(
            try decode(
                [CMCCoin].self,
                json: """
                    {"status":{"error_code":0},"data":[
                        {"id":"invalid","name":"Bitcoin","rank":1,"slug":"bitcoin","symbol":"BTC"}
                    ]}
                    """)
        ) { error in
            guard case DecodingError.typeMismatch = error else {
                return XCTFail("Expected a decoding type mismatch")
            }
        }
    }

    func testMissingCoinFieldThrowsInsteadOfDroppingCoin() {
        XCTAssertThrowsError(
            try decode(
                [CMCCoin].self,
                json: """
                    {"status":{"error_code":0},"data":[{"id":1}]}
                    """))
    }

    func testAPIErrorWithoutDataPreservesCodeAndMessage() {
        XCTAssertThrowsError(
            try decode(
                [CMCCoin].self,
                json: """
                    {"status":{"error_code":1008,"error_message":"Request limit reached"}}
                    """)
        ) { error in
            guard case NetworkError.api(let code, let message) = error else {
                return XCTFail("Expected the API error before decoding data")
            }
            XCTAssertEqual(code, 1008)
            XCTAssertEqual(message, "Request limit reached")
        }
    }

    func testAPIErrorWithNullDataAndMessage() {
        XCTAssertThrowsError(
            try decode(
                [CMCCoin].self,
                json: """
                    {"status":{"error_code":1001,"error_message":null},"data":null}
                    """)
        ) { error in
            guard case NetworkError.api(let code, let message) = error else {
                return XCTFail("Expected the API error")
            }
            XCTAssertEqual(code, 1001)
            XCTAssertNil(message)
        }
    }

    func testSuccessfulStatusStillRequiresData() {
        XCTAssertThrowsError(
            try decode(
                [CMCCoin].self,
                json: """
                    {"status":{"error_code":0}}
                    """))
    }

    func testInvalidJSONThrows() {
        XCTAssertThrowsError(try decode([CMCCoin].self, json: "not JSON"))
    }

    func testEmptyMapIsValid() throws {
        let response = try decode(
            [CMCCoin].self,
            json: """
                {"status":{"error_code":0},"data":[]}
                """)
        XCTAssertTrue(response.data.isEmpty)
    }

    func testMetadataDecodesDictionaryKeyedByCoinID() throws {
        let response = try decode(
            [String: CMCMetadata].self,
            json: """
                {"status":{"error_code":0},"data":{"1":{"logo":"https://example.com/bitcoin.png"}}}
                """)
        XCTAssertEqual(response.data["1"]?.logo, "https://example.com/bitcoin.png")
    }

    func testQuotesDecodeUSDPrice() throws {
        let response = try decode(
            [String: CMCQuote].self,
            json: """
                {"status":{"error_code":0},"data":{"1":{"quote":{"USD":{"price":123.45}}}}}
                """)
        XCTAssertEqual(response.data["1"]?.quote["USD"]?.price, 123.45)
    }

    func testNullPriceThrowsInsteadOfBecomingZero() {
        XCTAssertThrowsError(
            try decode(
                [String: CMCQuote].self,
                json: """
                    {"status":{"error_code":0},"data":{"1":{"quote":{"USD":{"price":null}}}}}
                    """))
    }

    func testInvalidImageURLCompletesWithFailureOnMainThread() {
        let completed = expectation(description: "Invalid URL completion")
        NetworkManager().fetchImg(url: "relative/path") { result in
            XCTAssertTrue(Thread.isMainThread)
            guard case .failure(.invalidURL) = result else {
                completed.fulfill()
                return XCTFail("Expected an invalid URL failure")
            }
            completed.fulfill()
        }
        wait(for: [completed], timeout: 1)
    }

    private func decode<Payload: Decodable>(_ type: Payload.Type, json: String) throws -> CMCResponse<Payload> {
        try JSONDecoder().decode(CMCResponse<Payload>.self, from: Data(json.utf8))
    }
}
