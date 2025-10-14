//
//  AppPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

struct AppPage: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            TopBarView(title: appState.currentScreen.title)
            Spacer(minLength: 0)
            contentView
            Spacer(minLength: 0)
            BottomBarView()
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .onAppear {
            // ListPage表示時にGraphデータを先読み
            if appState.currentScreen == .list {
                GraphDataPreloader.shared.preloadGraphDataInBackground()
            }
        }
        .onChange(of: appState.currentScreen) { _, newScreen in
            // ListPageに遷移した時にもプリロード
            if newScreen == .list {
                GraphDataPreloader.shared.preloadGraphDataInBackground()
            }
        }
    }

    @ViewBuilder
    var contentView: some View {
        switch appState.currentScreen {
        case .list:
            ListPage()
        case .input:
            switch appState.inputMode {
            case .selection:
                InputDataPage()
            case .combined:
                InputAllPage()
            case .inventoryOnly:
                InputInventoryPage()
            case .purchaseHistoryOnly:
                InputPurchaseHistoryPage()
            }
        case .graph:
            GraphPage()
        }
    }
}
