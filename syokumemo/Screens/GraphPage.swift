//
//  GraphPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import ShokumemoAPI

struct GraphPage: View {
    @StateObject private var viewModel = GraphViewModel()
    
    var body: some View {
        VStack {
            Text("食材リスト")
            // ここに食材のリスト表示、カレンダーなどを追加
        }
    }
}
