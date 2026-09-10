//
//  NetworkManager.swift
//  Altfolio
//
//  Created by Danila on 30.08.2022.
//

import Alamofire
import Foundation

// Completions are called once on the main queue, for both success and failure.
protocol NetworkProtocol {
    func fetchMap(completion: @escaping (Result<[CoinOfCMC], NetworkError>) -> Void)
    func fetchLogoURL(id: String, completion: @escaping (Result<String, NetworkError>) -> Void)
    func fetchLogoUrlArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: String], NetworkError>) -> Void)
    func fetchImg(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
    func fetchPriceArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: Double], NetworkError>) -> Void)
}

final class NetworkManager {
    private let headers: HTTPHeaders = [
        "Accepts": "application/json",
        "X-CMC_PRO_API_KEY": "e90479d1-ff9e-4551-85bc-fb25b4863739",/// use CoinMarketCap api key
    ]

    private func request<Payload: Decodable, Value>(
        _ url: String,
        parameters: Parameters,
        transform: @escaping (Payload) throws -> Value,
        completion: @escaping (Result<Value, NetworkError>) -> Void
    ) {
        AF.request(url, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .responseData(queue: .main) { response in
                switch response.result {
                case .success(let data):
                    do {
                        let payload = try JSONDecoder().decode(CMCResponse<Payload>.self, from: data).data
                        completion(.success(try transform(payload)))
                    } catch let error as NetworkError {
                        completion(.failure(error))
                    } catch {
                        completion(.failure(.decodingFailed(error)))
                    }
                case .failure(let error):
                    // API errors may arrive with a non-successful HTTP status and no data payload.
                    if let data = response.data,
                        let apiResponse = try? JSONDecoder().decode(CMCErrorResponse.self, from: data),
                        apiResponse.status.errorCode != 0
                    {
                        completion(
                            .failure(
                                .api(
                                    code: apiResponse.status.errorCode,
                                    message: apiResponse.status.errorMessage
                                )))
                    } else {
                        completion(.failure(.requestFailed(error)))
                    }
                }
            }
    }
}

// MARK: - NetworkProtocol
extension NetworkManager: NetworkProtocol {
    func fetchMap(completion: @escaping (Result<[CoinOfCMC], NetworkError>) -> Void) {
        request(
            "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map",
            parameters: ["start": "1", "limit": "1000"],
            transform: { (coins: [CMCCoin]) in coins.map { $0.coin } },
            completion: completion
        )
    }

    func fetchLogoURL(id: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        fetchLogoUrlArray(idString: id, idArray: [id]) { result in
            completion(
                result.flatMap { logos in
                    guard let logo = logos[id] else {
                        return .failure(.missingData("Logo for coin \(id)"))
                    }
                    return .success(logo)
                })
        }
    }

    func fetchLogoUrlArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: String], NetworkError>) -> Void
    ) {
        request(
            "https://pro-api.coinmarketcap.com/v2/cryptocurrency/info",
            parameters: ["id": idString, "aux": "logo"],
            transform: { (metadata: [String: CMCMetadata]) in
                var logos = [String: String]()
                for id in idArray {
                    guard let coin = metadata[id] else {
                        throw NetworkError.missingData("Metadata for coin \(id)")
                    }
                    logos[id] = coin.logo
                }
                return logos
            },
            completion: completion
        )
    }

    func fetchImg(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let url = URL(string: url),
            let scheme = url.scheme?.lowercased(),
            ["http", "https"].contains(scheme),
            let host = url.host, !host.isEmpty
        else {
            DispatchQueue.main.async { completion(.failure(.invalidURL)) }
            return
        }
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseData(queue: .main) { response in
                completion(response.result.mapError { .requestFailed($0) })
            }
    }

    func fetchPriceArray(
        idString: String, idArray: [String], completion: @escaping (Result<[String: Double], NetworkError>) -> Void
    ) {
        request(
            "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest",
            parameters: ["id": idString],
            transform: { (quotes: [String: CMCQuote]) in
                var prices = [String: Double]()
                for id in idArray {
                    guard let price = quotes[id]?.quote["USD"]?.price else {
                        throw NetworkError.missingData("USD price for coin \(id)")
                    }
                    prices[id] = price
                }
                return prices
            },
            completion: completion
        )
    }
}
