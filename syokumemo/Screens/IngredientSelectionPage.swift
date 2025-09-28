//
//  CategorySelectionView.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import SwiftUI
import ShokumemoAPI

struct IngredientSelectionPage: View {
    
    @Binding var path: [AppNavigationPath]
    
    @ObservedObject var viewModel: InputInventoryViewModel
    var category: Category
    
    private var currentCategory: Category {
        viewModel.categories.first(where: { $0.id == category.id }) ?? category
    }
    
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
                Button(action: {
                    if viewModel.isIngredientEditMode {
                        viewModel.completeIngredientEditing()
                    } else {
                        viewModel.isIngredientEditMode = true
                    }
                }) {
                    Text(viewModel.isIngredientEditMode ? "完了" : "編集")
                        .foregroundColor(.accentColor)
                }
            }

            Text(currentCategory.name)
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding()
        .frame(height: 50)
        
        List {
            ForEach(currentCategory.ingredients, id: \.id) { ingredient in
                if viewModel.isIngredientEditMode {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            TextField("食材名", text: Binding(
                                get: {
                                    if viewModel.editingIngredientNames[ingredient.id] == nil {
                                        viewModel.editingIngredientNames[ingredient.id] = ingredient.name
                                    }
                                    return viewModel.editingIngredientNames[ingredient.id] ?? ingredient.name
                                },
                                set: { viewModel.editingIngredientNames[ingredient.id] = $0 }
                            ))
                            .textFieldStyle(.plain)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        
                        Spacer()
                    }
                } else {
                    Button(action: {
                        viewModel.form.selectedIngredientName = ingredient.name
                        viewModel.form.ingredientId = ingredient.id
                        path.removeAll()
                    }) {
                        Text(ingredient.name)
                            .foregroundColor(.black)
                    }
                }
            }
            .onDelete(perform: viewModel.isIngredientEditMode ? deleteIngredients : nil)
            
            if viewModel.isIngredientEditMode {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        TextField("新しい食材", text: $viewModel.newIngredientName)
                            .textFieldStyle(.plain)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    
                    Button(action: {
                        viewModel.addNewIngredient(categoryId: currentCategory.id)
                    }) {
                        Text("追加")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.newIngredientName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .listRowSeparator(.hidden)
            }
        }
        .environment(\.editMode, viewModel.isIngredientEditMode ? .constant(.active) : .constant(.inactive))
        .navigationBarBackButtonHidden(true)
        .alert("削除完了", isPresented: $viewModel.showIngredientDeleteSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("食材を削除しました")
        }
        .alert("削除失敗", isPresented: $viewModel.showIngredientDeleteErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.ingredientDeleteErrorMessage)
        }
        .alert("未入力の項目があります。", isPresented: $viewModel.showEmptyIngredientNameAlert) {
            Button("閉じる", role: .cancel) { }
        }
    }
    
    private func deleteIngredients(at offsets: IndexSet) {
        for offset in offsets {
            let ingredient = currentCategory.ingredients[offset]
            viewModel.deleteIngredient(ingredientId: ingredient.id, categoryId: currentCategory.id)
        }
    }
}
