//
//  ListPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

struct ListPage: View {
    @StateObject private var viewModel = ListViewModel()

        var body: some View {
            NavigationView {
                VStack {
                    if viewModel.isLoading {
                        ProgressView("読み込み中…")
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    } else {
                        List(viewModel.inventories, id: \.id) { inventory in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(inventory.ingredient.name)
                                    .font(.headline)

                                Text("量: \(inventory.quantity.numerator)/\(inventory.quantity.denominator) \(inventory.unit)")
                                    .font(.subheadline)

                                if let expiry = inventory.expiryDate {
                                    Text("賞味期限: \(expiry)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                if let price = inventory.price {
                                    Text("価格: ¥\(Int(price))")
                                        .font(.caption2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle("食材リスト")
                .onAppear {
                    viewModel.fetchInventories()
                }
            }
        }
    }

//#Preview {
//    ListPage()
//}
