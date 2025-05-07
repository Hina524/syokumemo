//
//  IngredientSelectionView.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import SwiftUI
import ShokumemoAPI

struct IngredientSelectionView: View {
    var ingredient: Ingredient
    @Binding var path: [ChoiceIngredient]
    var viewModel: InputViewModel
    // @ObservedObject var viewModel: InputViewModel
    
    var body: some View {
        VStack {
            Text("\(ingredient.name)")
            
            Button(action: {
                path.removeLast()
            }) {
                Text("Back")
            }
            
            Button(action: {
                path.removeAll()
            }) {
                Text("Back to Top")
            }
        }

        
        //        VStack(spacing: 0) {
        //            // カスタムナビゲーションバー
        //            HStack {
        //                Button(action: {
        //                    dismiss() // 戻るボタンで前の画面に戻る
//                }) {
//                    HStack(spacing: 4) {
//                        Image(systemName: "chevron.left")
//                        Text("カテゴリ選択")
//                            .font(.body)
//                    }
//                    .foregroundColor(.black)
//                }
//                Spacer()
//                Text("食材選択")
//                    .font(.headline)
//                    .foregroundColor(.black)
//                Spacer()
//                Spacer().frame(width: 80)
//            }
//            .padding()
//            .frame(height: 50)
//            
//            // 食材リスト
//            List(ingredients, id: \.id) { ingredient in
//                Button {
//                    onSelect(ingredient)  // 食材を選択
//                    dismiss()  // 選択後に戻る
//                } label: {
//                    Text(ingredient.name)
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true) // 戻るボタンを消す
//        .toolbar(.hidden, for: .navigationBar)
    }
}
