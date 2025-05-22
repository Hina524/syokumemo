//
//  CategorySelectionPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/22.
//

import SwiftUI
import ShokumemoAPI

struct CategorySelectionPage: View {
    var categories: [Category]
    @Binding var path: [SelectIngredient]
    var viewModel: InputInventoryViewModel
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    path.removeLast()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                            .font(.body)
                    }
                    .foregroundColor(.black)
                }
                Spacer()
            }
            Text("カテゴリ選択")
        }
        .padding()
        .frame(height: 50)
        
        List {
            ForEach(categories, id: \.id) { category in
                NavigationLink(value: SelectIngredient.ingredients(category)) {
                    Text(category.name)
                }
            }
        }
        .navigationDestination(for: SelectIngredient.self) { selectIngredient in
            if case SelectIngredient.ingredients(let category) = selectIngredient { // Item.member から associated value を取得する
                IngredientSelectionView(path: $path, viewModel: viewModel, category: category)
            }
        }
        
        .navigationBarBackButtonHidden(true)
    }
}

//#Preview {
//    @Previewable @State var path = [SelectIngredient]()
//    var categories: [Category] = Category.init()
//    CategorySelectionPage(categories: categories, path: $path)
//}
