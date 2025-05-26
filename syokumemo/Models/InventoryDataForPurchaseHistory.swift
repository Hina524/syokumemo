//
//  InventoryDataForPurchaseHistory.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/22.
//

import SwiftUI

struct InventoryDataForPurchaseHistory: Hashable { // Hashableに準拠させる
    let ingredientName: String?
    let ingredientId: String
    let categoryId: String? // 型を実際のcategoryIdの型に合わせてください
    let numerator: Int
    let denominator: Int?
    let unit: String
}
