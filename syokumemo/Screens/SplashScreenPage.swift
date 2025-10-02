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
        VStack {
            Image("logo")
                .resizable()
                .frame(width: 218.19, height: 95)
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
