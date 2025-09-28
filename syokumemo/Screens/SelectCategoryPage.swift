//
//  SelectCategoryPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/22.
//

import SwiftUI
import ShokumemoAPI

struct SelectCategoryPage: View {
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
                    if viewModel.isCategoryEditMode {
                        viewModel.completeEditing()
                    } else {
                        viewModel.isCategoryEditMode = true
                    }
                }) {
                    Text(viewModel.isCategoryEditMode ? "完了" : "編集")
                        .foregroundColor(.accentColor)
                }
            }
            Text("カテゴリ選択")
        }
        .padding()
        .frame(height: 50)
        
        List {
            ForEach(viewModel.categories, id: \.id) { category in
                if viewModel.isCategoryEditMode {
                    HStack {
                        ColorPicker("", selection: Binding(
                            get: { 
                                if viewModel.editingCategoryColors[category.id] == nil {
                                    let initialColor = category.colorCode.isEmpty ? Color.gray : Color(hex: category.colorCode)
                                    viewModel.editingCategoryColors[category.id] = initialColor
                                }
                                return viewModel.editingCategoryColors[category.id] ?? Color.gray
                            },
                            set: { viewModel.editingCategoryColors[category.id] = $0 }
                        ), supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            TextField("カテゴリ名", text: Binding(
                                get: {
                                    if viewModel.editingCategoryNames[category.id] == nil {
                                        viewModel.editingCategoryNames[category.id] = category.name
                                    }
                                    return viewModel.editingCategoryNames[category.id] ?? category.name
                                },
                                set: { viewModel.editingCategoryNames[category.id] = $0 }
                            ))
                            .textFieldStyle(.plain)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        
                        Spacer()
                    }
                } else {
                    NavigationLink(value: AppNavigationPath.ingredients(category)) {
                        HStack {
                            Circle()
                                .fill(category.colorCode.isEmpty ? Color.gray : Color(hex: category.colorCode))
                                .frame(width: 20, height: 20)
                            Text(category.name)
                            Spacer()
                        }
                    }
                }
                
                if viewModel.isCategoryEditMode {
                    EmptyView()
                        .deleteDisabled(false)
                } else {
                    EmptyView()
                        .deleteDisabled(true)
                }
            }
            .onDelete(perform: viewModel.isCategoryEditMode ? deleteCategories : nil)
            
            if viewModel.isCategoryEditMode {
                HStack {
                    ColorPicker("", selection: $viewModel.newCategoryColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 30, height: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        TextField("新しいカテゴリ", text: $viewModel.newCategoryName)
                            .textFieldStyle(.plain)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    
                    Button(action: {
                        viewModel.addNewCategory()
                    }) {
                        Text("追加")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isDefaultGrayColor())
                }
                .listRowSeparator(.hidden)
            }
        }
        .environment(\.editMode, viewModel.isCategoryEditMode ? .constant(.active) : .constant(.inactive))
        .navigationDestination(for: AppNavigationPath.self) { selectIngredient in
            if case AppNavigationPath.ingredients(let category) = selectIngredient {
                SelectIngredientPage(path: $path, viewModel: viewModel, category: category)
            }
        }
        
        .navigationBarBackButtonHidden(true)
        .alert("削除完了", isPresented: $viewModel.showDeleteSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("カテゴリを削除しました")
        }
        .alert("削除失敗", isPresented: $viewModel.showDeleteErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.deleteErrorMessage)
        }
        .alert("未入力の項目があります。", isPresented: $viewModel.showEmptyNameAlert) {
            Button("閉じる", role: .cancel) { }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for offset in offsets {
            let category = viewModel.categories[offset]
            viewModel.deleteCategory(categoryId: category.id)
        }
    }
}