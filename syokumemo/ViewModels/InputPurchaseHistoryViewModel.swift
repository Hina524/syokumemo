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
    
    // 購入単位と購入場所
    var purchaseUnitId: String = ""
    var locationId: String = ""
    
    // 購入履歴
    var date: Date = Date()
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
    
    // 購入場所と購入単位
    @Published var locations: [GetLocationsQuery.Data.Location] = []
    @Published var purchaseUnits: [GetPurchaseUnitsByIngredientQuery.Data.PurchaseUnitsByIngredient] = []
    @Published var selectedLocationName: String? = nil
    @Published var selectedPurchaseUnitName: String? = nil
    
    // 既存のプロパティ（在庫データから購入履歴を作成する場合）
    var ingredientId: String?
    var purchaseUnitId: String?
    
    // 在庫データから購入履歴を作成するコンストラクタ
    init(ingredientId: String, purchaseUnitId: String) {
        self.ingredientId = ingredientId
        self.purchaseUnitId = purchaseUnitId
    }
    
    // 購入履歴のみ入力用のデフォルトコンストラクタ
    init() {
        self.ingredientId = nil
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
        form.purchaseUnitId = inventoryViewModel.form.purchaseUnitId
    }
    
    // MARK: fetchLocations
    func fetchLocations() {
        form.isLoading = true
        
        Network.shared.apollo.fetch(query: GetLocationsQuery(), cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data {
                        self?.locations = data.locations
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
    
    // MARK: fetchPurchaseUnitsByIngredient
    func fetchPurchaseUnitsByIngredient(ingredientId: String) {
        form.isLoading = true
        
        Network.shared.apollo.fetch(query: GetPurchaseUnitsByIngredientQuery(ingredientId: ingredientId), cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data {
                        self?.purchaseUnits = data.purchaseUnitsByIngredient
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
    
    // MARK: addInventoryAndPurchaseHistory
    func addInventoryAndPurchaseHistory(numerator: Int, denominator: Int?, unit: String, expiryDate: Date, frozen: Bool) {
        let targetIngredientId = ingredientId ?? form.ingredientId
        let targetPurchaseUnitId = purchaseUnitId ?? form.purchaseUnitId
        
        guard !targetIngredientId.isEmpty else {
            form.errorMessage = "食材を選択してください"
            isMutationError = true
            return
        }
        
        guard !form.locationId.isEmpty else {
            form.errorMessage = "購入場所を選択してください"
            isMutationError = true
            return
        }
        
        guard !targetPurchaseUnitId.isEmpty else {
            form.errorMessage = "購入単位を選択してください"
            isMutationError = true
            return
        }
        
        let fractionInput = FractionInput(
            numerator: numerator,
            denominator: denominator == nil ? 1 : denominator!
        )
        
        let inventoryInput = NewInventory(
            ingredientId: targetIngredientId,
            quantity: fractionInput,
            unit: unit,
            expiryDate: DateFormatter.apiFormat.string(from: expiryDate),
            frozen: frozen
        )
        
        let purchaseHistoryInput = NewPurchaseHistory(
            ingredientId: targetIngredientId,
            date: DateFormatter.apiFormat.string(from: form.date),
            locationId: form.locationId,
            purchaseUnitId: targetPurchaseUnitId,
            price: form.price
        )
        
        let mutation = CreateInventoryAndPurchaseHistoryMutation(
            input1: inventoryInput,
            input2: purchaseHistoryInput
        )
        
        form.isLoading = true
        isPurchaseHistorySubmitting = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.addInventory, let _ = graphQLResult.data?.addPurchaseHistory {
                        self?.isPurchaseHistorySubmitting = false
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
    
    // MARK: addPurchaseHistory
    func addPurchaseHistory() {
        // 購入履歴のみの場合はformから、在庫からの場合は既存のプロパティから取得
        let targetIngredientId = ingredientId ?? form.ingredientId
        let targetPurchaseUnitId = purchaseUnitId ?? form.purchaseUnitId
        
        guard !targetIngredientId.isEmpty else {
            form.errorMessage = "食材を選択してください"
            isMutationError = true
            return
        }
        
        guard !form.locationId.isEmpty else {
            form.errorMessage = "購入場所を選択してください"
            isMutationError = true
            return
        }
        
        guard !targetPurchaseUnitId.isEmpty else {
            form.errorMessage = "購入単位を選択してください"
            isMutationError = true
            return
        }
        
        let input = NewPurchaseHistory(
            ingredientId: targetIngredientId,
            date: DateFormatter.apiFormat.string(from: form.date),
            locationId: form.locationId,
            purchaseUnitId: targetPurchaseUnitId,
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
