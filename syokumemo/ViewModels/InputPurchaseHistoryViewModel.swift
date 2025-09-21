//
//  InputPurchaseHistoryViewModel.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/22.
//

import SwiftUI
import Apollo
import ShokumemoAPI

struct InputPurchaseHistoryFormData {
    // addPurchaseHistory
    var date: Date = Date()
    var location: String = ""
    var price: Int = 0
    
    // GetCategoriesAndIngredients
    var categories: [GetCategoriesAndIngredientsQuery.Data.Category] = []
    var isLoading = false
    var errorMessage: String? = .none
    
//    // カテゴリから食材を選んだ時に使うものたち
//    var selectedIngredientName: String? = .none
}

class InputPurchaseHistoryViewModel: ObservableObject {
    @Published var form = InputPurchaseHistoryFormData()
    @Published var isInventorySubmitting = false
    @Published var isPurchaseHistorySubmitting = false
    @Published var isInventoryAndPurchaseHistorySubmitting: Bool = false
    
    @Published var isMutationError: Bool = false
    @Published var purchaseDidSucceed: Bool = false
    
    var ingredientId: String
    var numerator: Int
    var denominator: Int?
    var unit: String
    
    init(ingredientId: String, numerator: Int, denominator: Int? = nil, unit: String) {
        self.ingredientId = ingredientId
        self.numerator = numerator
        self.denominator = denominator
        self.unit = unit
    }
    
    func resetForm() {
        form = InputPurchaseHistoryFormData()  // デフォルトイニシャライザでクリア
    }
    
    // MARK: addPurchaseHistory
    func addPurchaseHistory() {
        let fractionInput = FractionInput(
            numerator: numerator,
            denominator: denominator == .none ? 1 : .init(integerLiteral: denominator!)
        )
        
        let input = NewPurchaseHistory(
            ingredientId: ingredientId, // IDはGraphQLID型に変換
            quantity: fractionInput,
            unit: unit,
            date: .init(stringLiteral: DateFormatter.apiFormat.string(from: form.date)),
            locationId: form.location,
            price: form.price
        )
        
        let mutation = CreatePurchaseHistoryMutation(input: input)
        
        form.isLoading = true
        isPurchaseHistorySubmitting = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.addPurchaseHistory {
                        self?.isPurchaseHistorySubmitting = false
                        self?.resetForm()
                        self?.purchaseDidSucceed = true
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
}
