//
//  CoinCD+CoreDataProperties.swift
//  Altfolio
//
//  Created by Danila on 10.11.2022.
//

import CoreData
import Foundation

extension CoinCD {
    @NSManaged public var amount: Double
    @NSManaged public var history: NSSet?
    @NSManaged public var id: String?
    @NSManaged public var logoUrl: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var symbol: String?

    public var idW: String {
        id ?? "Unknown"
    }

    public var logoUrlW: String {
        logoUrl ?? "Unknown logo"
    }

    public var nameW: String {
        name ?? "Unknown name"
    }

    public var symbolW: String {
        symbol ?? "Unknown symbol"
    }

    public var historyArray: [Transaction] {
        let set = history as? Set<Transaction> ?? []

        return set.sorted {
            $0.dateW < $1.dateW
        }
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoinCD> {
        return NSFetchRequest<CoinCD>(entityName: "CoinCD")
    }
}

// MARK: - Generated accessors for history
extension CoinCD {
    @objc(addHistoryObject:)
    @NSManaged public func addToHistory(_ value: Transaction)

    @objc(removeHistoryObject:)
    @NSManaged public func removeFromHistory(_ value: Transaction)

    @objc(addHistory:)
    @NSManaged public func addToHistory(_ values: NSSet)

    @objc(removeHistory:)
    @NSManaged public func removeFromHistory(_ values: NSSet)
}

extension CoinCD: Identifiable {
}
