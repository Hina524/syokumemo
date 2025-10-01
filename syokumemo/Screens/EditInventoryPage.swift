//
//  EditInventoryPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/09.
//

import SwiftUI
import ShokumemoAPI

struct EditInventoryPage: View {
    
    @Binding var path: [Inventory]
    @ObservedObject var listViewModel: ListViewModel
    var inventory: Inventory
    @StateObject var viewModel = EditInventoryViewModel()
    
    var body: some View {
        VStack {
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
            
            Spacer()
            
            VStack(spacing: 16) {
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
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $viewModel.isShowFreezeSheet, onDismiss: {
            // シートが閉じられた時にリストを更新
            listViewModel.fetchInventories()
        }) {
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
}
