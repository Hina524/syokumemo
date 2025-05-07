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
    }

    @ViewBuilder
    var contentView: some View {
        switch appState.currentScreen {
        case .list:
            ListPage()
        case .input:
            InputPage()
        case .graph:
            GraphPage()
        }
    }
}
