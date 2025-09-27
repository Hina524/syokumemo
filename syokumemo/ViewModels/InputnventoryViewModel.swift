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
    @Published var showDeleteSuccessAlert: Bool = false
    @Published var showDeleteErrorAlert: Bool = false
    @Published var deleteErrorMessage: String = ""
    
    // Category color editing
    @Published var editingCategoryColors: [String: Color] = [:]
    @Published var showColorPicker: [String: Bool] = [:]
    
    // Category name editing
    @Published var editingCategoryNames: [String: String] = [:]
    @Published var showEmptyNameAlert: Bool = false
    
    // New category addition
    @Published var newCategoryName: String = ""
    @Published var newCategoryColor: Color = .gray
    
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
        
        Network.shared.apollo.fetch(query: GetCategoriesAndIngredientsQuery(), cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
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
                        self?.showDeleteSuccessAlert = true
                    } else if let errors = graphQLResult.errors {
                        self?.deleteErrorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self?.showDeleteErrorAlert = true
                    }
                case .failure(let error):
                    self?.deleteErrorMessage = "カテゴリの削除に失敗しました: \(error.localizedDescription)"
                    self?.showDeleteErrorAlert = true
                }
            }
        }
    }
    
    // MARK: completeEditing
    func completeEditing() {
        // Check for empty category names
        for (categoryId, name) in editingCategoryNames {
            if name.trimmingCharacters(in: .whitespaces).isEmpty {
                showEmptyNameAlert = true
                return
            }
        }
        
        // Collect all categories that need updating (either name or color changed)
        var categoriesToUpdate: [(id: String, name: String, color: String)] = []
        
        // Get all category IDs that have been edited
        let editedCategoryIds = Set(editingCategoryColors.keys).union(Set(editingCategoryNames.keys))
        
        for categoryId in editedCategoryIds {
            guard let category = categories.first(where: { $0.id == categoryId }) else { continue }
            
            let currentName = category.name
            let newName = editingCategoryNames[categoryId] ?? currentName
            
            let currentHex = category.colorCode.isEmpty ? "#808080" : category.colorCode
            let newHex = editingCategoryColors[categoryId]?.toHex() ?? currentHex
            
            // Check if anything actually changed
            if currentName != newName || currentHex != newHex {
                categoriesToUpdate.append((id: categoryId, name: newName, color: newHex))
            }
        }
        
        // Check if there are any changes to save
        guard !categoriesToUpdate.isEmpty else {
            editingCategoryColors.removeAll()
            editingCategoryNames.removeAll()
            showColorPicker.removeAll()
            isCategoryEditMode = false
            return
        }
        
        var updateCount = 0
        let totalUpdates = categoriesToUpdate.count
        
        // Update existing categories
        for categoryUpdate in categoriesToUpdate {
            updateCategory(id: categoryUpdate.id, name: categoryUpdate.name, colorCode: categoryUpdate.color) {
                updateCount += 1
                if updateCount == totalUpdates {
                    self.completeAllEdits()
                }
            }
        }
        
        // If no updates, just exit edit mode
        if totalUpdates == 0 {
            completeAllEdits()
        }
    }
    
    private func completeAllEdits() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.editingCategoryColors.removeAll()
            self.editingCategoryNames.removeAll()
            self.showColorPicker.removeAll()
            self.newCategoryName = ""
            self.newCategoryColor = .gray
            self.isCategoryEditMode = false
            self.fetchCategoriesAndIngredients()
        }
    }
    
    private func updateCategory(id: String, name: String, colorCode: String, completion: @escaping () -> Void) {
        let input = UpdateCategoryInput(
            name: name,
            colorCode: .some(colorCode)
        )
        
        let mutation = UpdateCategoryMutation(id: id, input: input)
        
        Network.shared.apollo.perform(mutation: mutation) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.updateCategory {
                        completion()
                    } else if let errors = graphQLResult.errors {
                        print("Error updating category color: \(errors)")
                        completion()
                    }
                case .failure(let error):
                    print("Failed to update category color: \(error.localizedDescription)")
                    completion()
                }
            }
        }
    }
    
    // MARK: isDefaultGrayColor
    func isDefaultGrayColor() -> Bool {
        let hexColor = newCategoryColor.toHex()
        return hexColor == "#808080" || hexColor == "#7F7F7F"
    }
    
    // MARK: addNewCategory
    func addNewCategory() {
        createCategory {
            // Reset the input fields after successful creation
            self.newCategoryName = ""
            self.newCategoryColor = .gray
            self.fetchCategoriesAndIngredients()
        }
    }
    
    // MARK: createCategory
    private func createCategory(completion: @escaping () -> Void) {
        let hexColor = newCategoryColor.toHex()
        
        let input = NewCategory(
            name: newCategoryName,
            colorCode: .some(hexColor)
        )
        
        let mutation = CreateCategoryMutation(input: input)
        
        Network.shared.apollo.perform(mutation: mutation) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.createCategory {
                        completion()
                    } else if let errors = graphQLResult.errors {
                        print("Error creating category: \(errors)")
                        completion()
                    }
                case .failure(let error):
                    print("Failed to create category: \(error.localizedDescription)")
                    completion()
                }
            }
        }
    }
}
