//
//  LocationPickerSheet.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/13.
//

import SwiftUI
import ShokumemoAPI

struct LocationPickerSheet: View {
    @Binding var selectedLocationId: String
    @Binding var selectedLocationName: String
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = LocationPickerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("読み込み中…")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(Color(.systemRed))
                } else {
                    List {
                        ForEach(viewModel.locations, id: \.id) { location in
                            if viewModel.isEditMode {
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
                                    selectedLocationId = location.id
                                    selectedLocationName = location.name
                                    dismiss()
                                }) {
                                    HStack {
                                        Text(location.name)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if location.id == selectedLocationId {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete(perform: viewModel.isEditMode ? deleteLocations : nil)
                        
                        if viewModel.isEditMode {
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
                }
            }
            .navigationTitle("購入場所選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.isEditMode {
                            viewModel.completeLocationEditing()
                        } else {
                            viewModel.isEditMode = true
                        }
                    }) {
                        Text(viewModel.isEditMode ? "完了" : "編集")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchLocations()
        }
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

class LocationPickerViewModel: ObservableObject {
    @Published var locations: [GetLocationsQuery.Data.Location] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isEditMode: Bool = false
    @Published var editingLocationNames: [String: String] = [:]
    @Published var newLocationName: String = ""
    @Published var showLocationDeleteSuccessAlert: Bool = false
    @Published var showLocationDeleteErrorAlert: Bool = false
    @Published var locationDeleteErrorMessage: String = ""
    @Published var showEmptyLocationNameAlert: Bool = false
    
    func fetchLocations() {
        isLoading = true
        Network.shared.apollo.fetch(query: GetLocationsQuery()) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let locations = graphQLResult.data?.locations {
                        self?.locations = locations
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func addNewLocation() {
        let trimmedName = newLocationName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            showEmptyLocationNameAlert = true
            return
        }
        
        let input = NewLocation(name: trimmedName)
        Network.shared.apollo.perform(mutation: CreateLocationMutation(input: input)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.newLocationName = ""
                    self?.fetchLocations()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func completeLocationEditing() {
        // 編集内容を保存
        for (locationId, newName) in editingLocationNames {
            let trimmedName = newName.trimmingCharacters(in: .whitespaces)
            if !trimmedName.isEmpty {
                let input = UpdateLocationInput(name: trimmedName)
                Network.shared.apollo.perform(mutation: UpdateLocationMutation(id: locationId, input: input)) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
        
        isEditMode = false
        editingLocationNames = [:]
        fetchLocations()
    }
    
    func deleteLocation(locationId: String) {
        Network.shared.apollo.perform(mutation: DeleteLocationMutation(id: locationId)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showLocationDeleteSuccessAlert = true
                    self?.fetchLocations()
                case .failure(let error):
                    self?.locationDeleteErrorMessage = error.localizedDescription
                    self?.showLocationDeleteErrorAlert = true
                }
            }
        }
    }
}