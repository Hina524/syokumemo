//
//  SelectPurchaseUnitPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/09/28.
//

import SwiftUI
import ShokumemoAPI

struct SelectPurchaseUnitPage: View {
    @Binding var path: [AppNavigationPath]
    @ObservedObject var viewModel: InputPurchaseHistoryViewModel
    
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
                    .foregroundColor(.accentColor)
                }
                Spacer()
                if !viewModel.form.ingredientId.isEmpty && !viewModel.purchaseUnits.isEmpty {
                    Button(action: {
                        if viewModel.isPurchaseUnitEditMode {
                            viewModel.completePurchaseUnitEditing()
                        } else {
                            viewModel.isPurchaseUnitEditMode = true
                        }
                    }) {
                        Text(viewModel.isPurchaseUnitEditMode ? "完了" : "編集")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            Text("購入単位選択")
        }
        .padding()
        .frame(height: 50)
        
        VStack {
            if viewModel.form.ingredientId.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("先に食材を選択してください")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Button("戻る") {
                        path.removeLast()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.purchaseUnits.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("この食材の購入単位がありません")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("編集モードで追加できます")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.purchaseUnits, id: \.id) { purchaseUnit in
                        if viewModel.isPurchaseUnitEditMode {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    TextField("購入単位名", text: Binding(
                                        get: {
                                            if viewModel.editingPurchaseUnitNames[purchaseUnit.id] == nil {
                                                viewModel.editingPurchaseUnitNames[purchaseUnit.id] = purchaseUnit.name
                                            }
                                            return viewModel.editingPurchaseUnitNames[purchaseUnit.id] ?? purchaseUnit.name
                                        },
                                        set: { viewModel.editingPurchaseUnitNames[purchaseUnit.id] = $0 }
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
                                viewModel.selectedPurchaseUnitName = purchaseUnit.name
                                viewModel.form.purchaseUnitId = purchaseUnit.id
                                path.removeAll()
                            }) {
                                Text(purchaseUnit.name)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .onDelete(perform: viewModel.isPurchaseUnitEditMode ? deletePurchaseUnits : nil)
                    
                    if viewModel.isPurchaseUnitEditMode {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                TextField("新しい購入単位", text: $viewModel.newPurchaseUnitName)
                                    .textFieldStyle(.plain)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            
                            Button(action: {
                                viewModel.addNewPurchaseUnit()
                            }) {
                                Text("追加")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.newPurchaseUnitName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .environment(\.editMode, viewModel.isPurchaseUnitEditMode ? .constant(.active) : .constant(.inactive))
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if !viewModel.form.ingredientId.isEmpty && viewModel.purchaseUnits.isEmpty {
                viewModel.fetchPurchaseUnitsByIngredient(ingredientId: viewModel.form.ingredientId)
            }
        }
        .alert("削除完了", isPresented: $viewModel.showPurchaseUnitDeleteSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("購入単位を削除しました")
        }
        .alert("削除失敗", isPresented: $viewModel.showPurchaseUnitDeleteErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.purchaseUnitDeleteErrorMessage)
        }
        .alert("未入力の項目があります。", isPresented: $viewModel.showEmptyPurchaseUnitNameAlert) {
            Button("閉じる", role: .cancel) { }
        }
    }
    
    private func deletePurchaseUnits(at offsets: IndexSet) {
        for offset in offsets {
            let purchaseUnit = viewModel.purchaseUnits[offset]
            viewModel.deletePurchaseUnit(purchaseUnitId: purchaseUnit.id)
        }
    }
}