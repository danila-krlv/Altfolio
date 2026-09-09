//
//  ExtensionSwiftUI.swift
//  Altfolio
//
//  Created by Danila on 10.02.2023.
//

import SwiftUI

extension View {
    func removeZerosFromEnd(_ value: Double) -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: value)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16
        return String(formatter.string(from: number) ?? "")
    }
}
