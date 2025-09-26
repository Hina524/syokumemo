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
    @Binding var path: [AppNavigationPath]
    @ObservedObject var viewModel: InputInventoryViewModel
    
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
                Button(action: {
                    viewModel.isCategoryEditMode.toggle()
                }) {
                    Text(viewModel.isCategoryEditMode ? "完了" : "編集")
                        .foregroundColor(.black)
                }
            }
            Text("カテゴリ選択")
        }
        .padding()
        .frame(height: 50)
        
        List {
            ForEach(categories, id: \.id) { category in
                NavigationLink(value: AppNavigationPath.ingredients(category)) {
                    HStack {
                        Circle()
                            .fill(category.colorCode.isEmpty ? Color.gray : Color(hex: category.colorCode))
                            .frame(width: 20, height: 20)
                        Text(category.name)
                        Spacer()
                    }
                }
                .deleteDisabled(!viewModel.isCategoryEditMode)
            }
            .onDelete(perform: viewModel.isCategoryEditMode ? deleteCategories : nil)
        }
        .environment(\.editMode, viewModel.isCategoryEditMode ? .constant(.active) : .constant(.inactive))
        .navigationDestination(for: AppNavigationPath.self) { selectIngredient in
            if case AppNavigationPath.ingredients(let category) = selectIngredient { // Item.member から associated value を取得する
                IngredientSelectionPage(path: $path, viewModel: viewModel, category: category)
            }
        }
        
        .navigationBarBackButtonHidden(true)
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for offset in offsets {
            let category = categories[offset]
            viewModel.deleteCategory(categoryId: category.id)
        }
    }
}

//#Preview {
//    @Previewable @State var path = [SelectIngredient]()
//    var categories: [Category] = Category.init()
//    CategorySelectionPage(categories: categories, path: $path)
//}
