//
//  Transaction+CoreDataProperties.swift
//  Altfolio
//
//  Created by Danila on 10.11.2022.
//

import CoreData
import Foundation

extension Transaction {
    @NSManaged public var addBool: Bool
    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var relationship: CoinCD?

    public var dateW: String {
        let dateFormatter = DateFormatter()
        let transactionDate = date ?? Date()

        dateFormatter.dateFormat = "dd/MM/YY - HH:mm:ss"

        return dateFormatter.string(from: transactionDate)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
}

extension Transaction: Identifiable {
}
