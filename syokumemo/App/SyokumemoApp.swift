//
//  SyokumemoApp.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import FirebaseCore

@main
struct SyokumemoApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var appState = AppState()
    
    init() {
        // Firebase初期化
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState.appState {
                case .splash:
                    SplashScreenPage()
                        .environmentObject(appState)
                        .environmentObject(authViewModel)
                case .login:
                    LoginPage()
                        .environmentObject(appState)
                        .environmentObject(authViewModel)
                case .main:
                    AppPage()
                        .environmentObject(appState)
                        .environmentObject(authViewModel)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.appState)
        }
    }
}
