//
//  PurchaseHistoryDetailPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/13.
//

import SwiftUI
import ShokumemoAPI

struct PurchaseHistoryDetailPage: View {
    let historyItem: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient.PurchaseHistory
    let ingredientId: String
    @StateObject private var viewModel = PurchaseHistoryDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // トップバー
            ZStack {
                HStack {
                    Button(action: {
                        if viewModel.isEditMode {
                            viewModel.cancelEdit()
                        } else {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("戻る")
                                .font(.body)
                        }
                        .foregroundColor(.accentColor)
                    }
                    Spacer()
                    
                    Button(action: {
                        if viewModel.isEditMode {
                            viewModel.completeEdit()
                        } else {
                            viewModel.startEdit(with: historyItem, ingredientId: ingredientId)
                        }
                    }) {
                        Text(viewModel.isEditMode ? "完了" : "編集")
                            .foregroundColor(.accentColor)
                    }
                }
                
                Text("購入履歴詳細")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(height: 44)
            .navigationBarBackButtonHidden(true)
            
            // 詳細情報リスト
            List {
                Section {
                    if viewModel.isEditMode {
                        // 編集モード
                        
                        // 金額
                        VStack(alignment: .leading, spacing: 4) {
                            Text("金額")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            TextField("\(historyItem.price)", text: $viewModel.editingPrice)
                                .textFieldStyle(.plain)
                                .keyboardType(.numberPad)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 4)
                        
                        // 購入日
                        VStack(alignment: .leading, spacing: 8) {
                            Text("購入日")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            DatePicker("", selection: $viewModel.editingDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                        }
                        .padding(.vertical, 4)
                        
                        // 購入場所
                        Button(action: {
                            viewModel.showLocationPicker = true
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("購入場所")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                HStack {
                                    Text(viewModel.selectedLocationName)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        
                        // 購入単位
                        Button(action: {
                            viewModel.showPurchaseUnitPicker = true
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("購入単位")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                HStack {
                                    Text(viewModel.selectedPurchaseUnitName)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        
                    } else {
                        // 表示モード（ローカルステート優先）
                        
                        // 金額
                        VStack(alignment: .leading, spacing: 4) {
                            Text("金額")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.currentDisplayPrice ?? historyItem.price)円")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 4)
                        
                        // 購入日
                        VStack(alignment: .leading, spacing: 4) {
                            Text("購入日")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            let displayDate = viewModel.currentDisplayDate ?? historyItem.date
                            if let date = DateFormatter.apiFormat.date(from: displayDate) {
                                Text(DateFormatter.displayFormat.string(from: date))
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // 購入場所
                        VStack(alignment: .leading, spacing: 4) {
                            Text("購入場所")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            let locationName = viewModel.currentDisplayLocation?.name ?? historyItem.location.name
                            Text(locationName)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 4)
                        
                        // 購入単位
                        VStack(alignment: .leading, spacing: 4) {
                            Text("購入単位")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            let unitName = viewModel.currentDisplayPurchaseUnit?.name ?? historyItem.purchaseUnit.name
                            Text(unitName)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            Spacer()
        }
        .alert("未入力の項目があります", isPresented: $viewModel.showEmptyPriceAlert) {
            Button("OK") { }
        } message: {
            Text("金額を入力してください")
        }
        .alert("更新完了", isPresented: $viewModel.showUpdateSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("購入履歴を更新しました")
        }
        .alert("更新失敗", isPresented: $viewModel.showUpdateErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $viewModel.showLocationPicker) {
            LocationPickerSheet(
                selectedLocationId: $viewModel.selectedLocationId,
                selectedLocationName: $viewModel.selectedLocationName
            )
        }
        .sheet(isPresented: $viewModel.showPurchaseUnitPicker) {
            PurchaseUnitPickerSheet(
                ingredientId: viewModel.currentIngredientId,
                selectedPurchaseUnitId: $viewModel.selectedPurchaseUnitId,
                selectedPurchaseUnitName: $viewModel.selectedPurchaseUnitName
            )
        }
    }
}
