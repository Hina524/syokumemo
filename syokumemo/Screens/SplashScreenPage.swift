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
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .frame(width: 218.19, height: 95)
                .scaleEffect(size)
                .opacity(opacity)
        }
        .onAppear {
            // アニメーション
            withAnimation(.easeIn(duration: 0.6)) {
                size = 1.0
                opacity = 1.0
            }
            
            // 認証状態を確認して遷移
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                checkAuthenticationAndNavigate()
            }
        }
    }
    
    private func checkAuthenticationAndNavigate() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if authViewModel.isAuthenticated {
                // 認証済みの場合、メイン画面へ
                appState.appState = .main
            } else {
                // 未認証の場合、ログイン画面へ
                appState.appState = .login
            }
        }
    }
}

#Preview {
    SplashScreenPage()
}
