//
//  TopBarView.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

struct TopBarView: View {
    let title: String
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingLogoutConfirmation = false

    var body: some View {
        ZStack {
            // タイトルを中央に配置
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // ユーザーアイコンボタンを右端に配置
            HStack {
                Spacer()
                Button(action: {
                    showingLogoutConfirmation = true
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(.systemGreen))
                }
                .accessibilityLabel("ユーザーメニュー")
                .accessibilityHint("タップしてログアウトオプションを表示")
                .padding(.trailing, 16)
            }
        }
        .frame(height: 50)
        .confirmationDialog(
            "ログアウトしますか？",
            isPresented: $showingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("ログアウト", role: .destructive) {
                authViewModel.signOut()
            }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("アプリからログアウトします。")
        }
    }
}
