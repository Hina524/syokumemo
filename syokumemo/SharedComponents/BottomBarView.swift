//
//  BottomBarView.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

struct BottomBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            TabItem(icon: "list.dash", screen: .list)
            TabItem(icon: "plus.circle.fill", screen: .input)
            TabItem(icon: "chart.xyaxis.line", screen: .graph)
        }
        .padding()
        .background(Color.white)
    }

    @ViewBuilder
    func TabItem(icon: String, screen: AppState.ScreenType) -> some View {
        VStack {
            Button(action: {
                withAnimation {
                    appState.currentScreen = screen
                }
            }) {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(appState.currentScreen == screen ? .green : .gray)
            }

            Text(screen.title)
                .font(.caption)
                .foregroundColor(appState.currentScreen == screen ? .green : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}
