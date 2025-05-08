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
        return formatter
    }()
}
