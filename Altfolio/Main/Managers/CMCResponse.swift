//
//  CMCResponse.swift
//  Altfolio
//
//  Created by Danila on 10.09.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case api(code: Int, message: String?)
    case decodingFailed(Error)
    case missingData(String)
}

struct CMCStatus: Decodable {
    let errorCode: Int
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
}

struct CMCErrorResponse: Decodable {
    let status: CMCStatus
}

struct CMCResponse<Payload: Decodable>: Decodable {
    let data: Payload

    private enum CodingKeys: String, CodingKey {
        case status
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(CMCStatus.self, forKey: .status)
        guard status.errorCode == 0 else {
            throw NetworkError.api(code: status.errorCode, message: status.errorMessage)
        }
        data = try container.decode(Payload.self, forKey: .data)
    }
}

struct CMCCoin: Decodable {
    let id: Int
    let name: String
    let rank: Int
    let slug: String
    let symbol: String

    var coin: CoinOfCMC {
        CoinOfCMC(id: String(id), name: name, rank: rank, slug: slug, symbol: symbol)
    }
}

struct CMCMetadata: Decodable {
    let logo: String
}

struct CMCQuote: Decodable {
    let quote: [String: CMCPrice]
}

struct CMCPrice: Decodable {
    let price: Double
}
