//
//  InventoryInputViewModel.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import SwiftUI
import Apollo
import ShokumemoAPI

struct InputFormData {
    // addInventory
    var ingredientName: String? = .none
    var ingredientId: String = ""
    var categoryId: Int? = .none
    var numerator: Int = 1
    var denominator: Int? = .none
    var unit: String = ""
    var expiryDate: Date? = .none

    var frozen: Bool = false
    var location: String = ""
    var price: Double = 0.0
    
    // GetCategoriesAndIngredients
    var categories: [GetCategoriesAndIngredientsQuery.Data.Category] = []
    var isLoading = false
    var errorMessage: String? = .none
    
    // カテゴリから食材を選んだ時に使うものたち
    var selectedIngredientName: String? = .none
}

class InputInventoryViewModel: ObservableObject {
    @Published var form = InputFormData()
    @Published var isSubmitting = false
    @Published var isMutationError: Bool = false
    
    
    func addInventory() {
        
        let fractionInput = FractionInput(
            numerator: form.numerator,
            denominator: form.denominator == .none ? 1 : .init(integerLiteral: form.denominator!)
        )

        let input = NewInventory(
            ingredientId: form.ingredientId, // IDはGraphQLID型に変換
            quantity: fractionInput,
            unit: form.unit,
            expiryDate: form.expiryDate == .none ? .null : .init(stringLiteral: DateFormatter.apiFormat.string(from: form.expiryDate!)),
            frozen: form.frozen == false ? .null : .init(booleanLiteral: form.frozen),
            location: form.location == "" ? .null : .init(stringLiteral: form.location),
            price: form.price == 0.0 ? .null : .init(floatLiteral: form.price)
        )
        
        let mutation = CreateInventoryMutation(input: input)
        
        form.isLoading = true
        isSubmitting = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.addInventory {
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
        form = InputFormData()  // デフォルトイニシャライザでクリア
    }
    
    func fetchCategoriesAndIngredients() {
        form.isLoading = true
        
        Network.shared.apollo.fetch(query: GetCategoriesAndIngredientsQuery()) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data {
                        self?.form.categories = data.categories
                        
                    } else if let errors = graphQLResult.errors {
                        self?.form.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                    }
                case .failure(let error):
                    self?.isMutationError = true
                    self?.form.errorMessage = "データ取得に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }
}
