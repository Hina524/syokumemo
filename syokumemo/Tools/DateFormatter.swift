//
//  DateFormatter.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/08.
//

import SwiftUI

extension DateFormatter {
    static let apiFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    static let displayFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}

extension Date {
    func formattedJapaneseMonth() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月"
        return formatter.string(from: self)
    }
}
