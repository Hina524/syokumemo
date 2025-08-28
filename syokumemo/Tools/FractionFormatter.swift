//
//  FractionFormatter.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/08/28.
//

import Foundation

struct FractionFormatter {
    /// 分数を適切にフォーマットします
    /// 分母が1の場合は分子のみの整数表示、それ以外は分数表示
    static func format(numerator: Int, denominator: Int) -> String {
        if denominator == 1 {
            return "\(numerator)"
        } else {
            return "\(numerator)/\(denominator)"
        }
    }
}