//
//  EditInventoryPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/09.
//

import SwiftUI
import ShokumemoAPI

struct EditInventoryNavigationHeader: View {
    @Binding var path: [Inventory]
    let inventory: Inventory
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    path.removeLast()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("消費期限リスト")
                            .font(.body)
                    }
                    .foregroundColor(.accentColor)
                }
                Spacer()
            }
            
            Text(inventory.ingredient.name)
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(height: 44)
        .navigationBarBackButtonHidden(true)
    }
}

struct ExpiryDateSheet: View {
    @ObservedObject var viewModel: EditInventoryViewModel
    @ObservedObject var listViewModel: ListViewModel
    let inventory: Inventory
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 8) {
                        Text("現在の賞味期限")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(inventory.expiryDate)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowSeparator(.hidden)
                
                Section {
                    DatePicker("", selection: $viewModel.newExpiryDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                } header: {
                    Text("新しい賞味期限")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .navigationTitle("賞味期限の変更")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        viewModel.isShowFreezeSheet = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("決定") {
                        viewModel.updateExpiryDate()
                    }
                    .disabled(viewModel.isSubmitting)
                }
            }
        }
    }
}

struct QuantitySheet: View {
    @ObservedObject var viewModel: EditInventoryViewModel
    @ObservedObject var listViewModel: ListViewModel
    let inventory: Inventory
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 8) {
                        Text("現在の数量")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("\(FractionFormatter.format(numerator: inventory.quantity.numerator, denominator: inventory.quantity.denominator)) \(inventory.unit)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                
                Section(header: Text("新しい数量と単位")
                    .font(.headline)
                    .foregroundColor(.primary)) {
                    HStack {
                        if viewModel.isOnFractionInput {
                            HStack {
                                TextField(FractionFormatter.format(numerator: inventory.quantity.numerator, denominator: 1), text: Binding(
                                    get: { viewModel.newNumerator?.description ?? "" },
                                    set: { viewModel.newNumerator = Int($0) }
                                ))
                                    .keyboardType(.asciiCapableNumberPad)
                                    .frame(minWidth: 50)
                                Text("/")
                                    .foregroundColor(.secondary)
                                TextField("\(inventory.quantity.denominator)", text: Binding(
                                    get: { viewModel.newDenominator?.description ?? "" },
                                    set: { viewModel.newDenominator = Int($0) }
                                ))
                                    .keyboardType(.asciiCapableNumberPad)
                                    .frame(minWidth: 50)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            TextField(FractionFormatter.format(numerator: inventory.quantity.numerator, denominator: inventory.quantity.denominator), text: Binding(
                                get: { viewModel.newNumerator?.description ?? "" },
                                set: { viewModel.newNumerator = Int($0) }
                            ))
                                .keyboardType(.asciiCapableNumberPad)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        TextField(inventory.unit, text: Binding(
                            get: { viewModel.newUnit ?? "" },
                            set: { viewModel.newUnit = $0.isEmpty ? nil : $0 }
                        ))
                        .textInputAutocapitalization(.never)
                        .frame(maxWidth: 100)
                    }
                    
                    Toggle(isOn: $viewModel.isOnFractionInput) {
                        Text("分数入力")
                    }
                }
            }
            .navigationTitle("数量の変更")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        viewModel.isShowQuantitySheet = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("決定") {
                        viewModel.updateQuantity()
                    }
                    .disabled(viewModel.isSubmitting)
                }
            }
        }
    }
}

struct EditInventoryPage: View {
    
    @Binding var path: [Inventory]
    @ObservedObject var listViewModel: ListViewModel
    var inventory: Inventory
    @StateObject var viewModel = EditInventoryViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            EditInventoryNavigationHeader(path: $path, inventory: inventory)
            
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    viewModel.inventoryId = inventory.id
                    viewModel.listViewModel = listViewModel
                    viewModel.onNavigateBack = {
                        path.removeLast()
                    }
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let currentDate = dateFormatter.date(from: inventory.expiryDate) {
                        viewModel.newExpiryDate = currentDate
                    }
                    viewModel.isShowFreezeSheet = true
                }) {
                    VStack(spacing: 4) {
                        Text("冷凍する")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("賞味期限の延長")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Button(action: {
                        viewModel.inventoryId = inventory.id
                        viewModel.listViewModel = listViewModel
                        viewModel.onNavigateBack = {
                            path.removeLast()
                        }
                        viewModel.isShowQuantitySheet = true
                    }) {
                        VStack(spacing: 4) {
                            Text("残りの数量を変更")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("数量の調整")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top, 20)
            
            Spacer()
        }
        .sheet(isPresented: $viewModel.isShowFreezeSheet) {
                ExpiryDateSheet(viewModel: viewModel, listViewModel: listViewModel, inventory: inventory)
            }
            .sheet(isPresented: $viewModel.isShowQuantitySheet) {
                QuantitySheet(viewModel: viewModel, listViewModel: listViewModel, inventory: inventory)
            }
    }
}
