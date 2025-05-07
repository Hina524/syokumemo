//
//  AppState.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var currentScreen: ScreenType = .list

    enum ScreenType {
        case list
        case input
        case graph

        var title: String {
            switch self {
            case .list: return "消費期限リスト"
            case .input: return "食材を追加"
            case .graph: return "金額推移グラフ"
            }
        }
    }
}
