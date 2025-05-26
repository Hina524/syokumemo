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
    
    var inventoryId: String = ""
    
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
    
    func resetForm() {
        form = EditFormData()  // デフォルトイニシャライザでクリア
    }
}
