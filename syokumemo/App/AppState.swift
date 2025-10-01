//
//  AppState.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var currentScreen: ScreenType = .list
    @Published var inputMode: InputMode = .selection
    @Published var appState: AppStateType = .splash

    enum ScreenType {
        case list
        case input
        case graph

        var title: String {
            switch self {
            case .list: return "消費期限リスト"
            case .input: return "データを入力"
            case .graph: return "金額推移グラフ"
            }
        }
    }
    
    enum AppStateType {
        case splash
        case login
        case main
    }
    
    enum InputMode {
        case selection      // 入力方法選択画面
        case combined       // 在庫と購入履歴の同時入力
        case inventoryOnly  // 在庫のみ入力
        case purchaseHistoryOnly // 購入履歴のみ入力
    }
}
