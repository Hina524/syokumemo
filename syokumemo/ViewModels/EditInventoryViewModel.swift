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
    @Published var isShowQuantitySheet = false
    @Published var newNumerator: Int? = nil
    @Published var newDenominator: Int? = nil
    @Published var newUnit: String? = nil
    @Published var isOnFractionInput = false
   
    var listViewModel: ListViewModel?
    var inventoryId: String = ""
    var onNavigateBack: (() -> Void)?
    
    func updateQuantity() {
        let denominatorValue = isOnFractionInput ? (newDenominator ?? 1) : 1
        let numeratorValue = newNumerator ?? 1
        
        let quantityInput: GraphQLNullable<FractionInput>
        if newNumerator != nil || newDenominator != nil {
            quantityInput = .some(FractionInput(
                numerator: numeratorValue,
                denominator: denominatorValue
            ))
        } else {
            quantityInput = .none
        }
        
        let unitInput: GraphQLNullable<String>
        if let unit = newUnit {
            unitInput = .some(unit)
        } else {
            unitInput = .none
        }
        
        let input = UpdateInventory(
            quantity: quantityInput,
            unit: unitInput,
            expiryDate: .none,
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
                        self?.isShowQuantitySheet = false
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
