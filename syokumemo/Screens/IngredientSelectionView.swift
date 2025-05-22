//
//  CategorySelectionView.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import SwiftUI
import ShokumemoAPI

struct IngredientSelectionView: View {
    
    @Binding var path: [SelectIngredient]
    
    var viewModel: InputInventoryViewModel
    var category: Category
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    path.removeLast()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("カテゴリ選択")
                            .font(.body)
                    }
                    .foregroundColor(.black)
                }
                Spacer()
            }

            Text(category.name)
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding()
        .frame(height: 50)
        
        List {
            ForEach(category.ingredients, id: \.id) { ingredient in
                Button(action: {
                    viewModel.form.selectedIngredientName = ingredient.name
                    viewModel.form.ingredientId = ingredient.id
                    path.removeAll()
                }) {
                    Text("\(ingredient.name)")
                        .foregroundColor(.black)
                }
            }
        }

        .navigationBarBackButtonHidden(true)
    }
}
