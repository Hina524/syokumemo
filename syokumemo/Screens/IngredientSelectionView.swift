//
//  IngredientSelectionView.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import SwiftUI
import ShokumemoAPI

typealias Ingredient = GetCategoriesAndIngredientsQuery.Data.Category.Ingredient

struct IngredientSelectionView: View {
    let ingredients: [Ingredient]
    var onSelect: (Ingredient) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // カスタムナビゲーションバー
            HStack {
                Button(action: {
                    dismiss() // 戻るボタンで前の画面に戻る
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("カテゴリ選択")
                            .font(.body)
                    }
                    .foregroundColor(.black)
                }
                Spacer()
                Text("食材選択")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Spacer().frame(width: 80)
            }
            .padding()
            .frame(height: 50)
            
            // 食材リスト
            List(ingredients, id: \.id) { ingredient in
                Button {
                    onSelect(ingredient)  // 食材を選択
                    dismiss()  // 選択後に戻る
                } label: {
                    Text(ingredient.name)
                }
            }
        }
        .navigationBarBackButtonHidden(true) // 戻るボタンを消す
        .toolbar(.hidden, for: .navigationBar)
    }
}
