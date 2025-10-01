//
//  EditInventoryViewModel.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/09.
//

import SwiftUI
import Apollo
import ShokumemoAPI

struct EditFormData {
    var numerator: Int = 1
    var denominator: Int? = .none
    var unit: String = ""

    var frozen: Bool = false
    
//    // GetCategoriesAndIngredients
    var isLoading = false
    var errorMessage: String? = .none
}

class EditInventoryViewModel: ObservableObject {
    @Published var form = EditFormData()
    @Published var isSubmitting = false
    @Published var isMutationError: Bool = false
    @Published var isShowFreezeSheet = false
    @Published var newExpiryDate = Date()
   
    var listViewModel: ListViewModel?
    var inventoryId: String = ""
    var onNavigateBack: (() -> Void)?
    
    func updateQuantity() {
        let input = UpdateQuantity(
            numerator: form.numerator,
            denominator: form.denominator == .none ? 1 : .init(integerLiteral: form.denominator!)
        )
        
        let mutation = UpdateQuantityMutation(id: inventoryId, input: input)
        
        form.isLoading = true
        isSubmitting = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.updateQuantity {
                        self?.isSubmitting = false
                        self?.resetForm()
                    } else if let errors = graphQLResult.errors {
                        self?.form.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self?.isMutationError = true
                    }
                case .failure(let error):
                    self?.form.errorMessage = "登録に失敗しました: \(error.localizedDescription)"
                    self?.isMutationError = true
                }
            }
        }
    }
    
    func updateExpiryDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expiryDateString = dateFormatter.string(from: newExpiryDate)
        
        let input = UpdateInventory(
            quantity: .none,
            unit: .none,
            expiryDate: .some(expiryDateString),
            frozen: .none
        )
        
        let mutation = UpdateInventoryMutation(id: inventoryId, input: input)
        
        form.isLoading = true
        isSubmitting = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.updateInventory {
                        self?.isSubmitting = false
                        self?.isShowFreezeSheet = false
                        // ListViewModelを更新して即座に反映
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self?.listViewModel?.fetchInventories()
                        }
                        // ListPageに戻る
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self?.onNavigateBack?()
                        }
                    } else if let errors = graphQLResult.errors {
                        self?.form.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self?.isMutationError = true
                    }
                case .failure(let error):
                    self?.form.errorMessage = "更新に失敗しました: \(error.localizedDescription)"
                    self?.isMutationError = true
                }
            }
        }
    }
    
    func resetForm() {
        form = EditFormData()  // デフォルトイニシャライザでクリア
    }
}
