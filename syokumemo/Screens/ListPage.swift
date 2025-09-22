//
//  ListPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import ShokumemoAPI

typealias Inventory = GetInventoriesQuery.Data.Inventory

struct ListPage: View {
    @StateObject private var viewModel = ListViewModel()
    @State private var path = [Inventory]()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("読み込み中…")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                NavigationStack(path: $path) {
                    List {
                        Section(header: Text("賞味期限切れ").font(.headline).foregroundColor(.primary)) {
                            if viewModel.expiredInventories.isEmpty {
                                Text("該当なし")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            } else {
                                ForEach(viewModel.expiredInventories, id: \.id) { inventory in
                                    NavigationLink(value: inventory) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(inventory.ingredient.name)
                                                .font(.headline)
                                            
                                            Text("量: \(FractionFormatter.format(numerator: inventory.quantity.numerator, denominator: inventory.quantity.denominator)) \(inventory.unit)")
                                            
                                            Text("賞味期限: \(inventory.expiryDate)")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("今日中").font(.headline).foregroundColor(.primary)) {
                            if viewModel.todayInventories.isEmpty {
                                Text("該当なし")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            } else {
                                ForEach(viewModel.todayInventories, id: \.id) { inventory in
                                    NavigationLink(value: inventory) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(inventory.ingredient.name)
                                                .font(.headline)
                                            
                                            Text("量: \(FractionFormatter.format(numerator: inventory.quantity.numerator, denominator: inventory.quantity.denominator)) \(inventory.unit)")
                                            
                                            Text("賞味期限: \(inventory.expiryDate)")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("それ以降").font(.headline).foregroundColor(.primary)) {
                            if viewModel.futureInventories.isEmpty {
                                Text("該当なし")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            } else {
                                ForEach(viewModel.futureInventories, id: \.id) { inventory in
                                    NavigationLink(value: inventory) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(inventory.ingredient.name)
                                                .font(.headline)
                                            
                                            Text("量: \(FractionFormatter.format(numerator: inventory.quantity.numerator, denominator: inventory.quantity.denominator)) \(inventory.unit)")
                                            
                                            Text("賞味期限: \(inventory.expiryDate)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                    }
                    .navigationDestination(for: Inventory.self) { inventory in
                        EditInventoryPage(
                            path: $path,
                            inventory: inventory
                        )
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchInventories()
        }
    }
}

#Preview {
    ListPage()
}
