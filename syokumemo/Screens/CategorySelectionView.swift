//
//  CategorySelectionView.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import SwiftUI
import ShokumemoAPI

struct CategorySelectionView: View {
    @ObservedObject var viewModel: InputViewModel
    var onSelect: (Ingredient) -> Void
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss() // 前の画面に戻る
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("食材を追加")
                            .font(.body)
                    }
                    .foregroundColor(.black)
                }
                
                Spacer()
                Text("カテゴリ選択")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                // 右側をスペースで調整して中央揃えを保つ
                Spacer().frame(width: 80)
            }
            .padding()
            .frame(height: 50)
            
            List(viewModel.categories, id: \.id) { category in
                NavigationLink {
                    IngredientSelectionView(ingredients: category.ingredients, onSelect: onSelect)
                } label: {
                    Text(category.name)
                }
            }
        }
        .navigationBarBackButtonHidden(true) // デフォルトの戻るボタンを非表示
    }
}
