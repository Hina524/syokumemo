//
//  InputInventoryViewModel.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import SwiftUI
import Apollo
import ShokumemoAPI

struct InputInventoryFormData {
    // Both of addInventory and addPurchaseHistory
//    var ingredientName: String? = .none
    var ingredientId: String = ""       // String (GraphQL ID) - ★これが空だとエラー原因
    var categoryId: String? = .none     // ★String? (GraphQL ID) に変更推奨
    var numerator: Int = 1            // Int (UIとの整合性注意)
    var denominator: Int? = .none     // Int? (UIとの整合性注意)
    var unit: String = "個"
    var purchaseUnitId: String = ""
    
    // addInventory
    var expiryDate: Date = Date()
    var frozen: Bool = false
    
   
    var isLoading = false
    var errorMessage: String? = .none
    
    // カテゴリから食材を選んだ時に使うものたち
    var selectedIngredientName: String? = .none
}

class InputInventoryViewModel: ObservableObject {
    @Published var form = InputInventoryFormData()
    @Published var isPurchaseHistorySubmitting = false
    @Published var isInventoryAndPurchaseHistorySubmitting: Bool = false
    
    @Published var isMutationError: Bool = false
    @Published var isShowSheet = false
    
    // GetCategoriesAndIngredients
    @Published var categories: [GetCategoriesAndIngredientsQuery.Data.Category] = []
    
    // Category editing mode
    @Published var isCategoryEditMode: Bool = false
    
    func resetForm() {
        form = InputInventoryFormData()  // デフォルトイニシャライザでクリア
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
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.addInventory {
                        self?.isShowSheet = true
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
    
    // MARK: fetchCategoriesAndIngredients
    func fetchCategoriesAndIngredients() {
        form.isLoading = true
        
        Network.shared.apollo.fetch(query: GetCategoriesAndIngredientsQuery()) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data {
                        self?.categories = data.categories
                        
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
    
    func convertToInventoryDataForPurchaseHistory () -> InventoryDataForPurchaseHistory {
        let inventoryData = InventoryDataForPurchaseHistory(
            ingredientName: self.form.selectedIngredientName, // selectedIngredientNameから取得
            ingredientId: self.form.ingredientId,     // selectedIngredientIdから取得
            categoryId: self.form.categoryId,       // selectedCategoryIdから取得
            numerator: self.form.numerator,
            denominator: self.form.denominator,
            unit: self.form.unit,
            purchaseUnitId: self.form.purchaseUnitId
        )
        return inventoryData
    }
    
    // MARK: deleteCategory
    func deleteCategory(categoryId: String) {
        let mutation = DeleteCategoryMutation(id: categoryId)
        
        form.isLoading = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let success = graphQLResult.data?.deleteCategory, success {
                        // Remove the category from the local array
                        self?.categories.removeAll { $0.id == categoryId }
                    } else if let errors = graphQLResult.errors {
                        self?.form.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self?.isMutationError = true
                    }
                case .failure(let error):
                    self?.form.errorMessage = "カテゴリの削除に失敗しました: \(error.localizedDescription)"
                    self?.isMutationError = true
                }
            }
        }
    }
}
