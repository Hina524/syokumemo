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
    // Both of addInventory and addPurchaseHistory
    var ingredientName: String? = .none
    var ingredientId: String = ""
    var categoryId: Int? = .none
    var numerator: Int = 1
    var denominator: Int? = .none
    var unit: String = ""
    
    // addInventory
    var expiryDate: Date = Date()
    var frozen: Bool = false
    
    // addPurchaseHistory
    var date: Date = Date()
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
    @Published var isInventorySubmitting = false
    @Published var isPurchaseHistorySubmitting = false
    @Published var isInventoryAndPurchaseHistorySubmitting: Bool = false
    
    @Published var isMutationError: Bool = false
    
    func resetForm() {
        form = InputFormData()  // デフォルトイニシャライザでクリア
    }
    
    // MARK: addInvebtory
    func addInventory() {
        let fractionInput = FractionInput(
            numerator: form.numerator,
            denominator: form.denominator == .none ? 1 : .init(integerLiteral: form.denominator!)
        )
        
        let input = NewInventory(
            ingredientId: form.ingredientId, // IDはGraphQLID型に変換
            quantity: fractionInput,
            unit: form.unit,
            expiryDate: .init(stringLiteral: DateFormatter.apiFormat.string(from: form.expiryDate)),
            frozen: form.frozen
        )
        
        let mutation = CreateInventoryMutation(input: input)
        
        form.isLoading = true
        isInventorySubmitting = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.addInventory {
                        self?.isInventorySubmitting = false
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
    
    // MARK: addPurchaseHistory
    func addPurchaseHistory() {
        let fractionInput = FractionInput(
            numerator: form.numerator,
            denominator: form.denominator == .none ? 1 : .init(integerLiteral: form.denominator!)
        )
        
        let input = NewPurchaseHistory(
            ingredientId: form.ingredientId, // IDはGraphQLID型に変換
            quantity: fractionInput,
            unit: form.unit,
            date: .init(stringLiteral: DateFormatter.apiFormat.string(from: form.date)),
            location: form.location,
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
    
    //MARK: addInventoryAndPurchaseHistory
    func addInventoryAndPurchaseHistory() {
        let fractionInput = FractionInput(
            numerator: form.numerator,
            denominator: form.denominator == .none ? 1 : .init(integerLiteral: form.denominator!)
        )
        
        let input1 = NewInventory(
            ingredientId: form.ingredientId, // IDはGraphQLID型に変換
            quantity: fractionInput,
            unit: form.unit,
            expiryDate: .init(stringLiteral: DateFormatter.apiFormat.string(from: form.expiryDate)),
            frozen: form.frozen
        )
        
        let input2 = NewPurchaseHistory(
            ingredientId: form.ingredientId, // IDはGraphQLID型に変換
            quantity: fractionInput,
            unit: form.unit,
            date: .init(stringLiteral: DateFormatter.apiFormat.string(from: form.date)),
            location: form.location,
            price: form.price
        )
        
        let mutation = CreateInventoryAndPurchaseHistoryMutation(input1: input1, input2: input2)
        
        form.isLoading = true
        isInventoryAndPurchaseHistorySubmitting = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    var didAddInventory = false
                    var didAddPurchaseHistory = false
                    
                    if let _ = graphQLResult.data?.addInventory {
                        didAddInventory = true
                    } else if let errors = graphQLResult.errors {
                        self?.form.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self?.isMutationError = true
                    }
                    if let _ = graphQLResult.data?.addPurchaseHistory {
                        didAddPurchaseHistory = true
                    } else if let errors = graphQLResult.errors {
                        self?.form.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self?.isMutationError = true
                    }
                    
                    self?.isInventoryAndPurchaseHistorySubmitting = false
                    if didAddInventory && didAddPurchaseHistory {
                        self?.resetForm()
                    }
                    
                case .failure(let error):
                    self?.form.errorMessage = "登録に失敗しました: \(error.localizedDescription)"
                    self?.isMutationError = true
                }
            }
        }
    }
    
    // MARK: fetchCategoriesAndIngredients
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
