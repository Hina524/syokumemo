//
//  PurchaseUnitSelectionPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/09/28.
//

import SwiftUI
import ShokumemoAPI

struct PurchaseUnitSelectionPage: View {
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
                    .foregroundColor(.black)
                }
                Spacer()
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.purchaseUnits, id: \.id) { purchaseUnit in
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
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if !viewModel.form.ingredientId.isEmpty && viewModel.purchaseUnits.isEmpty {
                viewModel.fetchPurchaseUnitsByIngredient(ingredientId: viewModel.form.ingredientId)
            }
        }
    }
}