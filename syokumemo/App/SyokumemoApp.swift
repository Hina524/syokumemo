//
//  SyokumemoApp.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

@main
struct SyokumemoApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenPage()
                .environmentObject(AppState())
        }
    }
}
