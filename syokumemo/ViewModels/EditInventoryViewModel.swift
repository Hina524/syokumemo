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
    // editInventory
    var ingredientName: String? = .none
    var categoryId: Int? = .none
    var numerator: Int = 1
    var denominator: Int? = .none
    var unit: String = ""
    var expiryDate: Date? = .none

    var frozen: Bool = false
    var location: String = ""
    var price: Double = 0.0
    
//    // GetCategoriesAndIngredients
//    var categories: [GetCategoriesAndIngredientsQuery.Data.Category] = []
    var isLoading = false
    var errorMessage: String? = .none
    
//    // カテゴリから食材を選んだ時に使うものたち
//    var selectedIngredientName: String? = .none
}

class EditInventoryViewModel: ObservableObject {
    @Published var form = EditFormData()
    @Published var isSubmitting = false
    @Published var isMutationError: Bool = false
    
    var inventoryId: String = ""
    
    func editInventory() {
        let fractionInput = FractionInput(
            numerator: form.numerator,
            denominator: form.denominator == .none ? 1 : .init(integerLiteral: form.denominator!)
        )
        
        let input = UpdateInventory(
            quantity: .init(fractionInput),
            unit: form.unit == "" ? .null : .init(stringLiteral: form.unit),
            expiryDate: form.expiryDate == .none ? .null : .init(stringLiteral: DateFormatter.apiFormat.string(from: form.expiryDate!)),
            frozen: form.frozen == false ? .null : .init(booleanLiteral: form.frozen)
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
    
    func resetForm() {
        form = EditFormData()  // デフォルトイニシャライザでクリア
    }
}
