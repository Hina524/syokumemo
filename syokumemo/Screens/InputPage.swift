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
    
    @State private var path = [ChoiceIngredient]() // (1) 画面遷移管理配列
    
    var body: some View {
        NavigationStack(path: $path) { // (2) NavigationStack に画面遷移管理配列を設定
            List {
                ForEach(viewModel.categories, id: \.id) { category in
                    NavigationLink(value: ChoiceIngredient.category(category)) { // (3) 遷移先に渡すデータを設定
                        Text(category.name)
                    }
                }
            }
            //   .navigationTitle("Team List")
            .navigationDestination(for: ChoiceIngredient.self) { choiceIngredient in // (4) 遷移先を設定
                switch choiceIngredient {
                case .category(let category):
                    CategorySelectionView(category: category, path: $path, viewModel: viewModel)
                    
                case .ingredient(let ingredient):
                    IngredientSelectionView(ingredient: ingredient, path: $path, viewModel: viewModel)
                }
            }
        }
        .onAppear {
            viewModel.fetchCategoriesAndIngredients()
        }
    }
}
