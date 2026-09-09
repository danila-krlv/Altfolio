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

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "dd/MM/yyyy - HH:mm:ss"
        return formatter
    }()

    // Display text only. Chronological comparisons must use date directly.
    public var dateW: String {
        guard let date = date else { return "Unknown date" }
        return Self.displayDateFormatter.string(from: date)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
}

extension Transaction: Identifiable {
}
