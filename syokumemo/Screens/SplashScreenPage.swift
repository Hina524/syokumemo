//
//  SplashScreenPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

struct SplashScreenPage: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // ロゴ（将来的に画像ロゴに戻す予定）
//            Image("logo")
//                .resizable()
//                .frame(width: 218.19, height: 95)
            
            // 暫定的なテキストロゴ
            Text("Syokumemo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("食材管理アプリ")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                checkAuthenticationAndNavigate()
            }
        }
    }
    
    private func checkAuthenticationAndNavigate() {
        if authViewModel.isAuthenticated {
            // 認証済みの場合、メイン画面へ
            appState.appState = .main
        } else {
            // 未認証の場合、ログイン画面へ
            appState.appState = .login
        }
    }
}

#Preview {
    SplashScreenPage()
}
