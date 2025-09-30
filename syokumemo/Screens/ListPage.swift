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
                        Section {
                            VStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                    let now = Date()
                                    let calendar = Calendar.current
                                    let year = calendar.component(.year, from: now)
                                    let month = calendar.component(.month, from: now)
                                    
                                    HStack(spacing: 2) {
                                        Text(String(year))
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        Text("年")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        Text(String(month))
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        Text("月")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                }
                                
                                HStack(spacing: 60) {
                                    Spacer()
                                    
                                    VStack {
                                        Text("\(viewModel.discardedCount)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        Text("すてた")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack {
                                        Text("\(viewModel.activeCount)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        Text("在庫数")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack {
                                        Text("\(viewModel.consumedCount)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        Text("食べた")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.top, 8)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        
                        Section(header: Text("賞味期限切れ").font(.headline).foregroundColor(.primary)) {
                            if viewModel.expiredInventories.isEmpty {
                                Text("該当なし")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            } else {
                                ForEach(viewModel.expiredInventories, id: \.id) { inventory in
                                    NavigationLink(value: inventory) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Circle()
                                                        .fill(Color(hex: inventory.ingredient.category.colorCode))
                                                        .frame(width: 16, height: 16)
                                                    Text(inventory.ingredient.category.name)
                                                        .font(.footnote)
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                }
                                                
                                                Text(inventory.ingredient.name)
                                                    .font(.headline)
                                                
                                                Text("\(FractionFormatter.format(numerator: inventory.quantity.numerator, denominator: inventory.quantity.denominator)) \(inventory.unit)")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color(hex: inventory.ingredient.category.colorCode))
                                            }
                                            
                                            Spacer()
                                            
                                            Text(inventory.expiryDate)
                                                .font(.body)
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
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Circle()
                                                        .fill(Color(hex: inventory.ingredient.category.colorCode))
                                                        .frame(width: 16, height: 16)
                                                    Text(inventory.ingredient.category.name)
                                                        .font(.footnote)
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                }
                                                
                                                Text(inventory.ingredient.name)
                                                    .font(.headline)
                                                
                                                Text("\(FractionFormatter.format(numerator: inventory.quantity.numerator, denominator: inventory.quantity.denominator)) \(inventory.unit)")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color(hex: inventory.ingredient.category.colorCode))
                                            }
                                            
                                            Spacer()
                                            
                                            Text(inventory.expiryDate)
                                                .font(.body)
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
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Circle()
                                                        .fill(Color(hex: inventory.ingredient.category.colorCode))
                                                        .frame(width: 16, height: 16)
                                                    Text(inventory.ingredient.category.name)
                                                        .font(.footnote)
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                }
                                                
                                                Text(inventory.ingredient.name)
                                                    .font(.headline)
                                                
                                                Text("\(FractionFormatter.format(numerator: inventory.quantity.numerator, denominator: inventory.quantity.denominator)) \(inventory.unit)")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color(hex: inventory.ingredient.category.colorCode))
                                            }
                                            
                                            Spacer()
                                            
                                            Text(inventory.expiryDate)
                                                .font(.body)
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
