//
//  InputPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import ShokumemoAPI

struct InputPage: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = InputViewModel()
    @State private var selectedIngredient: GetCategoriesAndIngredientsQuery.Data.Category.Ingredient? = nil
    @State private var showCategorySelection = false  // fullScreenCover表示用のフラグ
    
    var body: some View {
        VStack {
            HStack {
                Text("選択された食材：")
                Text(selectedIngredient?.name ?? "未選択")
                    .bold()
            }

            Button {
                showCategorySelection.toggle()  // ボタンで遷移をトリガー
            } label: {
                Text("食材を選択")
            }

            Spacer()
        }
        .onAppear {
            viewModel.fetchCategoriesAndIngredients()
        }
        .fullScreenCover(isPresented: $showCategorySelection) {
            CategorySelectionView(viewModel: viewModel) { ingredient in
                self.selectedIngredient = ingredient
                showCategorySelection = false  // 選択後に閉じる
            }
        }
    }
}
