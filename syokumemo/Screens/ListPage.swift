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
                    List(viewModel.inventories, id: \.id) { inventory in
                        NavigationLink(value: inventory) {
                            VStack(alignment: .leading, spacing: 4) {
                                
                                Text(inventory.ingredient.name)
                                    .font(.headline)
                                
                                Text("量: \(inventory.quantity.numerator)/\(inventory.quantity.denominator) \(inventory.unit)")
                                    .font(.subheadline)
                                
                                Text("賞味期限: \(inventory.expiryDate)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                            }
                            .padding(.vertical, 4)
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
