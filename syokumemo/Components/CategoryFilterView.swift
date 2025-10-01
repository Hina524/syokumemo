//
//  CategoryFilterView.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/01.
//

import SwiftUI
import ShokumemoAPI

struct CategoryFilterView: View {
    @Binding var selectedCategoryIds: Set<String>
    let categories: [GetCategoriesAndIngredientsQuery.Data.Category]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                HStack(spacing: 12) {
                    Button(action: {
                        selectedCategoryIds = Set(categories.map { $0.id })
                    }) {
                        Text("すべて選択")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        selectedCategoryIds.removeAll()
                    }) {
                        Text("すべて解除")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 4)
                .listRowSeparator(.hidden)
                
                ForEach(categories, id: \.id) { category in
                    Button(action: {
                        if selectedCategoryIds.contains(category.id) {
                            selectedCategoryIds.remove(category.id)
                        } else {
                            selectedCategoryIds.insert(category.id)
                        }
                    }) {
                        HStack {
                            Circle()
                                .fill(Color(hex: category.colorCode))
                                .frame(width: 16, height: 16)
                            
                            Text(category.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedCategoryIds.contains(category.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("絞り込み")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}