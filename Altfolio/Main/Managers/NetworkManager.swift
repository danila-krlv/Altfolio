//
//  NetworkManager.swift
//  Altfolio
//
//  Created by Danila on 30.08.2022.
//

import Alamofire
import Foundation

protocol NetworkProtocol {
    func fetchMap(completion: @escaping (_ coins: [CoinOfCMC]) -> Void)
    func fetchLogoURL(id: String, completion: @escaping (_ logoString: [String]) -> Void)
    func fetchLogoUrlArray(
        idString: String, idArray: [String], completion: @escaping (_ logoDict: [String: String]) -> Void)
    func fetchImg(url: String, completion: @escaping (_ imageData: Data) -> Void)
    func fetchPriceArray(
        idString: String, idArray: [String], completion: @escaping (_ logoDict: [String: Double]) -> Void)
}

final class NetworkManager {
    private let headers: HTTPHeaders = [
        "Accepts": "application/json",
        "X-CMC_PRO_API_KEY": "e90479d1-ff9e-4551-85bc-fb25b4863739",/// use CoinMarketCap api key
    ]
}

// MARK: - NetworkProtocol
extension NetworkManager: NetworkProtocol {
    func fetchMap(completion: @escaping (_ coins: [CoinOfCMC]) -> Void) {
        let urlBasic = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map"
        let parameters: Parameters = [
            "start": "1",
            "limit": "1000",
        ]

        guard let url = URL(string: urlBasic) else { return }
        AF.request(url, parameters: parameters, headers: headers).responseData { response in
            switch response.result {
            case .success(let value):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: value)
                    guard let responseDictionary = asJSON as? NSDictionary else { return }
                    guard let data = responseDictionary.object(forKey: "data") else { return }
                    guard let coins = CoinOfCMC.getArray(from: data) else { return }
                    completion(coins)
                } catch {
                    print("Error while decoding response: \(error)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchLogoURL(id: String, completion: @escaping (_ logoString: [String]) -> Void) {
        let url = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/info"
        let parameters: Parameters = [
            "id": id,
            "aux": "logo",
        ]

        guard let url = URL(string: url) else { return }
        AF.request(url, parameters: parameters, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let value):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: value)

                    guard let responseDictionary = asJSON as? NSDictionary else { return }
                    guard let data = responseDictionary.object(forKey: "data") as? NSDictionary else { return }
                    guard let idData = data.object(forKey: id) as? NSDictionary else { return }
                    guard let string = idData.object(forKey: "logo") as? String else { return }
                    let arrStr = [string]
                    completion(arrStr)
                } catch {
                    print("Error while decoding response: \(error)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchLogoUrlArray(
        idString: String, idArray: [String], completion: @escaping (_ logoDict: [String: String]) -> Void
    ) {
        let url = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/info"
        let parameters: Parameters = [
            "id": idString,
            "aux": "logo",
        ]

        guard let url = URL(string: url) else { return }
        AF.request(url, parameters: parameters, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let value):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: value)
                    guard let responseDictionary = asJSON as? NSDictionary else { return }
                    guard let data = responseDictionary.object(forKey: "data") as? NSDictionary else { return }

                    var dict = [String: String]()

                    for id in idArray {
                        guard let idData = data.object(forKey: id) as? NSDictionary else { return }
                        guard let string = idData.object(forKey: "logo") as? String else { return }
                        dict[id] = string
                    }
                    completion(dict)
                } catch {
                    print("Error while decoding response: \(error)")
                }
            case .failure(let error):
                print("Request failed with error \(error)")
            }
        }
    }

    func fetchImg(url: String, completion: @escaping (_ imageData: Data) -> Void) {
        guard let url = URL(string: url) else { return }
        AF.request(url).responseData { (response) in
            switch response.result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchPriceArray(
        idString: String, idArray: [String], completion: @escaping (_ logoDict: [String: Double]) -> Void
    ) {
        let url = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest"
        let parameters: Parameters = [
            "id": idString
        ]

        guard let url = URL(string: url) else { return }
        AF.request(url, parameters: parameters, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let value):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: value)
                    guard let responseDictionary = asJSON as? NSDictionary else { return }
                    guard let data = responseDictionary.object(forKey: "data") as? NSDictionary else { return }

                    var dict = [String: Double]()

                    for id in idArray {
                        guard let idData = data.object(forKey: id) as? NSDictionary else { return }
                        guard let quote = idData.object(forKey: "quote") as? NSDictionary else { return }
                        guard let usdPrice = quote.object(forKey: "USD") as? NSDictionary else { return }
                        guard let price = usdPrice.object(forKey: "price") as? Double else { return }
                        dict[id] = price
                    }
                    completion(dict)
                } catch {
                    print("Error while decoding response: \(error)")
                }
            case .failure(let error):
                print("Request failed with error \(error)")
            }
        }
    }
}
