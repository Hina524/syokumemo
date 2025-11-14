//
//  PurchaseUnitPickerSheet.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/13.
//

import SwiftUI
import ShokumemoAPI

struct PurchaseUnitPickerSheet: View {
    let ingredientId: String
    @Binding var selectedPurchaseUnitId: String
    @Binding var selectedPurchaseUnitName: String
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = PurchaseUnitPickerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("読み込み中…")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(Color(.systemRed))
                } else if viewModel.purchaseUnits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        Text("この食材には購入単位が設定されていません")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                        Text("まず食材を選択してから購入単位を設定してください")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.purchaseUnits, id: \.id) { purchaseUnit in
                            if viewModel.isEditMode {
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
                                    selectedPurchaseUnitId = purchaseUnit.id
                                    selectedPurchaseUnitName = purchaseUnit.name
                                    dismiss()
                                }) {
                                    HStack {
                                        Text(purchaseUnit.name)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if purchaseUnit.id == selectedPurchaseUnitId {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete(perform: viewModel.isEditMode ? deletePurchaseUnits : nil)
                        
                        if viewModel.isEditMode {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    TextField("新しい購入単位", text: $viewModel.newPurchaseUnitName)
                                        .textFieldStyle(.plain)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                }
                                
                                Button(action: {
                                    viewModel.addNewPurchaseUnit(ingredientId: ingredientId)
                                }) {
                                    Text("追加")
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(viewModel.newPurchaseUnitName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .navigationTitle("購入単位選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                if !viewModel.purchaseUnits.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if viewModel.isEditMode {
                                viewModel.completePurchaseUnitEditing()
                            } else {
                                viewModel.isEditMode = true
                            }
                        }) {
                            Text(viewModel.isEditMode ? "完了" : "編集")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchPurchaseUnits(ingredientId: ingredientId)
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

class PurchaseUnitPickerViewModel: ObservableObject {
    @Published var purchaseUnits: [GetPurchaseUnitsByIngredientQuery.Data.PurchaseUnitsByIngredient] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isEditMode: Bool = false
    @Published var editingPurchaseUnitNames: [String: String] = [:]
    @Published var newPurchaseUnitName: String = ""
    @Published var showPurchaseUnitDeleteSuccessAlert: Bool = false
    @Published var showPurchaseUnitDeleteErrorAlert: Bool = false
    @Published var purchaseUnitDeleteErrorMessage: String = ""
    @Published var showEmptyPurchaseUnitNameAlert: Bool = false
    
    func fetchPurchaseUnits(ingredientId: String) {
        guard !ingredientId.isEmpty else { return }
        
        isLoading = true
        Network.shared.apollo.fetch(query: GetPurchaseUnitsByIngredientQuery(ingredientId: ingredientId)) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let purchaseUnits = graphQLResult.data?.purchaseUnitsByIngredient {
                        self?.purchaseUnits = purchaseUnits
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func addNewPurchaseUnit(ingredientId: String) {
        let trimmedName = newPurchaseUnitName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            showEmptyPurchaseUnitNameAlert = true
            return
        }
        
        let input = NewPurchaseUnit(ingredientId: ingredientId, name: trimmedName)
        Network.shared.apollo.perform(mutation: CreatePurchaseUnitMutation(input: input)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.newPurchaseUnitName = ""
                    self?.fetchPurchaseUnits(ingredientId: ingredientId)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func completePurchaseUnitEditing() {
        // 編集内容を保存
        for (purchaseUnitId, newName) in editingPurchaseUnitNames {
            let trimmedName = newName.trimmingCharacters(in: .whitespaces)
            if !trimmedName.isEmpty {
                let input = UpdatePurchaseUnitInput(name: trimmedName)
                Network.shared.apollo.perform(mutation: UpdatePurchaseUnitMutation(id: purchaseUnitId, input: input)) { [weak self] result in
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
        editingPurchaseUnitNames = [:]
    }
    
    func deletePurchaseUnit(purchaseUnitId: String) {
        Network.shared.apollo.perform(mutation: DeletePurchaseUnitMutation(id: purchaseUnitId)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showPurchaseUnitDeleteSuccessAlert = true
                case .failure(let error):
                    self?.purchaseUnitDeleteErrorMessage = error.localizedDescription
                    self?.showPurchaseUnitDeleteErrorAlert = true
                }
            }
        }
    }
}