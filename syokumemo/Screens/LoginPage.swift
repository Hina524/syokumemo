//
//  LoginPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/09/21.
//

import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // ロゴ
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
//            // アプリタイトル
//            VStack(spacing: 8) {
//                Text("食材管理アプリ")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                
//                Text("Syokumemo")
//                    .font(.title2)
//                    .foregroundColor(.secondary)
//            }
            
            Spacer()
            
            // Apple Sign In ボタン
            VStack(spacing: 16) {
                SignInWithAppleButton(viewModel: authViewModel)
                    .frame(height: 50)
                    .cornerRadius(8)
                
                // ローディング表示
                if authViewModel.isLoading {
                    HStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("サインイン中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // エラーメッセージ表示
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            
//            Spacer()
            
            // フッター
            VStack(spacing: 4) {
                Text("Apple でサインインすることで、")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("利用規約とプライバシーポリシーに同意したものとみなされます")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 32)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // 認証成功時にメイン画面へ遷移
                withAnimation(.easeInOut(duration: 0.3)) {
                    appState.appState = .main
                }
            }
        }
    }
}

#Preview {
    LoginPage()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppState())
}
