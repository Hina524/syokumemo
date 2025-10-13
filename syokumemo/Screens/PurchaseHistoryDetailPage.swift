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
                        HStack {
                            Text("金額")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            TextField("金額", text: $viewModel.editingPrice)
                                .textFieldStyle(.plain)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 8)
                        
                        // 購入日
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("購入日")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            DatePicker("", selection: $viewModel.editingDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                        }
                        .padding(.vertical, 8)
                        
                        // 購入場所
                        Button(action: {
                            viewModel.showLocationPicker = true
                        }) {
                            HStack {
                                Text("購入場所")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(viewModel.selectedLocationName)
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        
                        // 購入単位
                        Button(action: {
                            viewModel.showPurchaseUnitPicker = true
                        }) {
                            HStack {
                                Text("購入単位")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(viewModel.selectedPurchaseUnitName)
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        
                    } else {
                        // 表示モード（ローカルステート優先）
                        
                        // 金額
                        HStack {
                            Text("金額")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.currentDisplayPrice ?? historyItem.price)円")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 8)
                        
                        // 購入日
                        HStack {
                            Text("購入日")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            let displayDate = viewModel.currentDisplayDate ?? historyItem.date
                            if let date = DateFormatter.apiFormat.date(from: displayDate) {
                                Text(DateFormatter.displayFormat.string(from: date))
                                    .font(.title3)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // 購入場所
                        HStack {
                            Text("購入場所")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            let locationName = viewModel.currentDisplayLocation?.name ?? historyItem.location.name
                            Text(locationName)
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 8)
                        
                        // 購入単位
                        HStack {
                            Text("購入単位")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            let unitName = viewModel.currentDisplayPurchaseUnit?.name ?? historyItem.purchaseUnit.name
                            Text(unitName)
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 8)
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
