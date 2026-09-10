//
//  CoreDataManager.swift
//  Altfolio
//
//  Created by Danila on 11.02.2023.
//

import CoreData
import UIKit

protocol CoreDataProtocol {
    func fetchMyCoins() -> [CoinCD]
    func resetAllRecords()
    func saveContext()
    func createNew(coin: CoinOfCMC, value: Double) -> CoinCD?
    func createTrans(value: Double) -> Transaction?
    func deleteCoin(_ coinCD: CoinCD)
}

final class CoreDataManager {
    private let context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }()
}

// MARK: - CoreDataProtocol
extension CoreDataManager: CoreDataProtocol {
    func fetchMyCoins() -> [CoinCD] {
        let fetchRequest: NSFetchRequest<CoinCD> = CoinCD.fetchRequest()

        do {
            let arr = try context.fetch(fetchRequest)
            return arr
        } catch let error as NSError {
            print(error.localizedDescription)
            return []
        }
    }

    func resetAllRecords() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CoinCD")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func saveContext() {
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func createNew(coin: CoinOfCMC, value: Double) -> CoinCD? {
        guard
            let entity = NSEntityDescription.entity(
                forEntityName: "CoinCD",
                in: context)
        else { return nil }
        let myCoin = CoinCD(entity: entity, insertInto: context)
        myCoin.id = coin.id
        myCoin.symbol = coin.symbol
        myCoin.name = coin.name
        myCoin.amount = value
        myCoin.price = 0.0
        myCoin.logoUrl = coin.logoUrl

        if let trans = createTrans(value: value) {
            myCoin.addToHistory(trans)
        }
        return myCoin
    }

    func createTrans(value: Double) -> Transaction? {
        guard
            let entity = NSEntityDescription.entity(
                forEntityName: "Transaction",
                in: context)
        else { return nil }
        let trans = Transaction(entity: entity, insertInto: context)
        trans.date = Date()
        trans.amount = value
        trans.addBool = true
        return trans
    }

    func deleteCoin(_ coinCD: CoinCD) {
        context.delete(coinCD)
        saveContext()
    }
}
