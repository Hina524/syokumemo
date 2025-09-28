//
//  InputDataPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/09/24.
//

import SwiftUI

struct InputDataPage: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
            VStack(spacing: 30) {
                Text("データ入力方法を選択してください")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top, 50)
                
                Spacer()
                
                VStack(spacing: 20) {
                    // 同時入力ボタン
                    Button(action: {
                        appState.inputMode = .combined
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 24))
                            Text("在庫と購入履歴を同時に入力")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.primary)
                    
                    // 在庫のみボタン
                    Button(action: {
                        appState.inputMode = .inventoryOnly
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "archivebox")
                                .font(.system(size: 24))
                            Text("在庫のみ入力")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.primary)
                    
                    // 購入履歴のみボタン
                    Button(action: {
                        appState.inputMode = .purchaseHistoryOnly
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 24))
                            Text("購入履歴のみ入力")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
    }
}

#Preview {
    InputDataPage()
        .environmentObject(AppState())
}
