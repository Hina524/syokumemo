//
//  SelectLocationPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/09/28.
//

import SwiftUI
import ShokumemoAPI

struct SelectLocationPage: View {
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
                Button(action: {
                    if viewModel.isLocationEditMode {
                        viewModel.completeLocationEditing()
                    } else {
                        viewModel.isLocationEditMode = true
                    }
                }) {
                    Text(viewModel.isLocationEditMode ? "完了" : "編集")
                        .foregroundColor(.accentColor)
                }
            }
            Text("購入場所選択")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(height: 44)
        
        List {
            ForEach(viewModel.locations, id: \.id) { location in
                if viewModel.isLocationEditMode {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            TextField("購入場所名", text: Binding(
                                get: {
                                    if viewModel.editingLocationNames[location.id] == nil {
                                        viewModel.editingLocationNames[location.id] = location.name
                                    }
                                    return viewModel.editingLocationNames[location.id] ?? location.name
                                },
                                set: { viewModel.editingLocationNames[location.id] = $0 }
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
                        viewModel.selectedLocationName = location.name
                        viewModel.form.locationId = location.id
                        path.removeAll()
                    }) {
                        Text(location.name)
                            .foregroundColor(.black)
                    }
                }
            }
            .onDelete(perform: viewModel.isLocationEditMode ? deleteLocations : nil)
            
            if viewModel.isLocationEditMode {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        TextField("新しい購入場所", text: $viewModel.newLocationName)
                            .textFieldStyle(.plain)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    
                    Button(action: {
                        viewModel.addNewLocation()
                    }) {
                        Text("追加")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.newLocationName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .listRowSeparator(.hidden)
            }
        }
        .environment(\.editMode, viewModel.isLocationEditMode ? .constant(.active) : .constant(.inactive))
        .navigationBarBackButtonHidden(true)
        .alert("削除完了", isPresented: $viewModel.showLocationDeleteSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("購入場所を削除しました")
        }
        .alert("削除失敗", isPresented: $viewModel.showLocationDeleteErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.locationDeleteErrorMessage)
        }
        .alert("未入力の項目があります。", isPresented: $viewModel.showEmptyLocationNameAlert) {
            Button("閉じる", role: .cancel) { }
        }
    }
    
    private func deleteLocations(at offsets: IndexSet) {
        for offset in offsets {
            let location = viewModel.locations[offset]
            viewModel.deleteLocation(locationId: location.id)
        }
    }
}