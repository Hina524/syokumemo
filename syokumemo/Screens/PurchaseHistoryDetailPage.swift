//
//  PurchaseHistoryDetailPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/13.
//

import SwiftUI
import ShokumemoAPI

struct PurchaseHistoryDetailPage: View {
    let historyItem: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient.PurchaseHistory
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // トップバー
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("戻る")
                                .font(.body)
                        }
                        .foregroundColor(.accentColor)
                    }
                    Spacer()
                }
                
                Text("購入履歴詳細")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(height: 44)
            .navigationBarBackButtonHidden(true)
            
            // 詳細情報リスト
            List {
                Section {
                    // 金額
                    HStack {
                        Text("金額")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(historyItem.price)円")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    
                    // 購入日
                    HStack {
                        Text("購入日")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                        if let date = DateFormatter.apiFormat.date(from: historyItem.date) {
                            Text(DateFormatter.displayFormat.string(from: date))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // 購入場所
                    HStack {
                        Text("購入場所")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(historyItem.location.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    
                    // 購入単位
                    HStack {
                        Text("購入単位")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(historyItem.purchaseUnit.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.insetGrouped)
            
            Spacer()
        }
    }
}