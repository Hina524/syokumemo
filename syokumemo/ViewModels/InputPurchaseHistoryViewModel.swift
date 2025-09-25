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
    // 食材選択（InputInventoryViewModelから参考）
    var ingredientId: String = ""
    var categoryId: String? = nil
    var selectedIngredientName: String? = nil
    
    // 数量（InputInventoryViewModelから参考）
    var numerator: Int = 1
    var denominator: Int? = nil
    var unit: String = "個"
    var purchaseUnitId: String = ""
    
    // 購入履歴
    var date: Date = Date()
    var location: String = ""
    var price: Int = 0
    
    // UI状態
    var isLoading = false
    var errorMessage: String? = nil
}

class InputPurchaseHistoryViewModel: ObservableObject {
    @Published var form = InputPurchaseHistoryFormData()
    @Published var isInventorySubmitting = false
    @Published var isPurchaseHistorySubmitting = false
    @Published var isInventoryAndPurchaseHistorySubmitting: Bool = false
    
    @Published var isMutationError: Bool = false
    @Published var purchaseDidSucceed: Bool = false
    
    // GetCategoriesAndIngredients（InputInventoryViewModelから参考）
    @Published var categories: [GetCategoriesAndIngredientsQuery.Data.Category] = []
    
    // 既存のプロパティ（在庫データから購入履歴を作成する場合）
    var ingredientId: String?
    var numerator: Int?
    var denominator: Int?
    var unit: String?
    var purchaseUnitId: String?
    
    // 在庫データから購入履歴を作成するコンストラクタ
    init(ingredientId: String, numerator: Int, denominator: Int? = nil, unit: String, purchaseUnitId: String) {
        self.ingredientId = ingredientId
        self.numerator = numerator
        self.denominator = denominator
        self.unit = unit
        self.purchaseUnitId = purchaseUnitId
    }
    
    // 購入履歴のみ入力用のデフォルトコンストラクタ
    init() {
        self.ingredientId = nil
        self.numerator = nil
        self.denominator = nil
        self.unit = nil
        self.purchaseUnitId = nil
    }
    
    func resetForm() {
        form = InputPurchaseHistoryFormData()  // デフォルトイニシャライザでクリア
    }
    
    // MARK: fetchCategoriesAndIngredients（InputInventoryViewModelから参考）
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
    
    // 購入履歴のみの場合に食材選択情報を連携する
    func syncFromInventoryViewModel(_ inventoryViewModel: InputInventoryViewModel) {
        form.ingredientId = inventoryViewModel.form.ingredientId
        form.selectedIngredientName = inventoryViewModel.form.selectedIngredientName
        form.numerator = inventoryViewModel.form.numerator
        form.denominator = inventoryViewModel.form.denominator
        form.unit = inventoryViewModel.form.unit
        form.purchaseUnitId = inventoryViewModel.form.purchaseUnitId
    }
    
    // MARK: addPurchaseHistory
    func addPurchaseHistory() {
        // 購入履歴のみの場合はformから、在庫からの場合は既存のプロパティから取得
        let targetIngredientId = ingredientId ?? form.ingredientId
        let targetNumerator = numerator ?? form.numerator
        let targetDenominator = denominator ?? form.denominator
        let targetUnit = unit ?? form.unit
        let targetPurchaseUnitId = purchaseUnitId ?? form.purchaseUnitId
        
        guard !targetIngredientId.isEmpty else {
            form.errorMessage = "食材を選択してください"
            isMutationError = true
            return
        }
        
        let fractionInput = FractionInput(
            numerator: targetNumerator,
            denominator: targetDenominator == nil ? 1 : targetDenominator!
        )
        
        let input = NewPurchaseHistory(
            ingredientId: targetIngredientId,
            date: DateFormatter.apiFormat.string(from: form.date),
            locationId: form.location,
            purchaseUnitId: targetPurchaseUnitId.isEmpty ? "個" : targetPurchaseUnitId,
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
