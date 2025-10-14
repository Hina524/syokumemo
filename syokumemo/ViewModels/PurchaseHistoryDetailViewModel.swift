//
//  PurchaseHistoryDetailViewModel.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/13.
//

import SwiftUI
import Apollo
import ShokumemoAPI

class PurchaseHistoryDetailViewModel: ObservableObject {
    @Published var isEditMode: Bool = false
    @Published var isLoading: Bool = false
    @Published var showEmptyPriceAlert: Bool = false
    @Published var showUpdateSuccessAlert: Bool = false
    @Published var showUpdateErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    // Sheet表示フラグ
    @Published var showLocationPicker: Bool = false
    @Published var showPurchaseUnitPicker: Bool = false
    
    // 編集中の値
    @Published var editingPrice: String = ""
    @Published var editingDate: Date = Date()
    @Published var selectedLocationId: String = ""
    @Published var selectedLocationName: String = ""
    @Published var selectedPurchaseUnitId: String = ""
    @Published var selectedPurchaseUnitName: String = ""
    
    // 元の履歴データ
    private var originalHistoryItem: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient.PurchaseHistory?
    private var ingredientId: String = ""
    
    // ローカルステート（即座に更新を反映するため）
    @Published var currentDisplayPrice: Int?
    @Published var currentDisplayDate: String?
    @Published var currentDisplayLocation: (id: String, name: String)?
    @Published var currentDisplayPurchaseUnit: (id: String, name: String)?
    
    
    func initialize(with historyItem: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient.PurchaseHistory, ingredientId: String) {
        originalHistoryItem = historyItem
        self.ingredientId = ingredientId
    }
    
    func startEdit(with historyItem: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient.PurchaseHistory, ingredientId: String) {
        originalHistoryItem = historyItem
        self.ingredientId = ingredientId
        editingPrice = String(historyItem.price)
        editingDate = DateFormatter.apiFormat.date(from: historyItem.date) ?? Date()
        selectedLocationId = historyItem.location.id
        selectedLocationName = historyItem.location.name
        selectedPurchaseUnitId = historyItem.purchaseUnit.id
        selectedPurchaseUnitName = historyItem.purchaseUnit.name
        isEditMode = true
    }
    
    var currentIngredientId: String {
        return ingredientId
    }
    
    
    func cancelEdit() {
        isEditMode = false
    }
    
    func completeEdit() {
        guard let historyItem = originalHistoryItem else { return }
        
        // バリデーション
        guard let price = Int(editingPrice.trimmingCharacters(in: .whitespaces)), price > 0 else {
            showEmptyPriceAlert = true
            return
        }
        
        isLoading = true
        
        let input = UpdatePurchaseHistory(
            date: GraphQLNullable<String>(stringLiteral: DateFormatter.apiFormat.string(from: editingDate)),
            locationId: GraphQLNullable<String>(stringLiteral: selectedLocationId),
            purchaseUnitId: GraphQLNullable<String>(stringLiteral: selectedPurchaseUnitId),
            price: GraphQLNullable<Int>(integerLiteral: price)
        )
        
        let mutation = UpdatePurchaseHistoryMutation(id: historyItem.id, input: input)
        
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors {
                        self?.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self?.showUpdateErrorAlert = true
                    } else {
                        // ローカルステートを即座に更新
                        if let editingPrice = self?.editingPrice,
                           let price = Int(editingPrice.trimmingCharacters(in: .whitespaces)) {
                            self?.currentDisplayPrice = price
                        }
                        if let editingDate = self?.editingDate {
                            self?.currentDisplayDate = DateFormatter.apiFormat.string(from: editingDate)
                        }
                        if let locationId = self?.selectedLocationId,
                           let locationName = self?.selectedLocationName {
                            self?.currentDisplayLocation = (id: locationId, name: locationName)
                        }
                        if let unitId = self?.selectedPurchaseUnitId,
                           let unitName = self?.selectedPurchaseUnitName {
                            self?.currentDisplayPurchaseUnit = (id: unitId, name: unitName)
                        }
                        
                        self?.isEditMode = false
                        self?.showUpdateSuccessAlert = true
                        
                        // キャッシュを即座に更新（遅延なし）
                        Network.shared.apollo.fetch(query: GetIngredientsAndParchaseHistoryQuery(), cachePolicy: .fetchIgnoringCacheData) { _ in }
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showUpdateErrorAlert = true
                }
            }
        }
    }
}