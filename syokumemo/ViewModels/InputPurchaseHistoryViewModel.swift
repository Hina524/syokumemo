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
    
    // Location editing mode
    @Published var isLocationEditMode: Bool = false
    @Published var showLocationDeleteSuccessAlert: Bool = false
    @Published var showLocationDeleteErrorAlert: Bool = false
    @Published var locationDeleteErrorMessage: String = ""
    @Published var editingLocationNames: [String: String] = [:]
    @Published var showEmptyLocationNameAlert: Bool = false
    @Published var newLocationName: String = ""
    
    // PurchaseUnit editing mode
    @Published var isPurchaseUnitEditMode: Bool = false
    @Published var showPurchaseUnitDeleteSuccessAlert: Bool = false
    @Published var showPurchaseUnitDeleteErrorAlert: Bool = false
    @Published var purchaseUnitDeleteErrorMessage: String = ""
    @Published var editingPurchaseUnitNames: [String: String] = [:]
    @Published var showEmptyPurchaseUnitNameAlert: Bool = false
    @Published var newPurchaseUnitName: String = ""
    
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
    
    // MARK: - Location Management
    
    func deleteLocation(locationId: String) {
        let mutation = DeleteLocationMutation(id: locationId)
        
        form.isLoading = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let success = graphQLResult.data?.deleteLocation, success {
                        self?.locations.removeAll { $0.id == locationId }
                        self?.showLocationDeleteSuccessAlert = true
                    } else if let errors = graphQLResult.errors {
                        self?.locationDeleteErrorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self?.showLocationDeleteErrorAlert = true
                    }
                case .failure(let error):
                    self?.locationDeleteErrorMessage = "購入場所の削除に失敗しました: \(error.localizedDescription)"
                    self?.showLocationDeleteErrorAlert = true
                }
            }
        }
    }
    
    func completeLocationEditing() {
        for (locationId, name) in editingLocationNames {
            if name.trimmingCharacters(in: .whitespaces).isEmpty {
                showEmptyLocationNameAlert = true
                return
            }
        }
        
        var locationsToUpdate: [(id: String, name: String)] = []
        
        for (locationId, newName) in editingLocationNames {
            guard let location = locations.first(where: { $0.id == locationId }) else { continue }
            
            let currentName = location.name
            
            if currentName != newName {
                locationsToUpdate.append((id: locationId, name: newName))
            }
        }
        
        guard !locationsToUpdate.isEmpty else {
            editingLocationNames.removeAll()
            showEmptyLocationNameAlert = false
            newLocationName = ""
            isLocationEditMode = false
            return
        }
        
        var updateCount = 0
        let totalUpdates = locationsToUpdate.count
        
        for locationUpdate in locationsToUpdate {
            updateLocation(id: locationUpdate.id, name: locationUpdate.name) {
                updateCount += 1
                if updateCount == totalUpdates {
                    self.completeAllLocationEdits()
                }
            }
        }
        
        if totalUpdates == 0 {
            completeAllLocationEdits()
        }
    }
    
    private func completeAllLocationEdits() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.editingLocationNames.removeAll()
            self.showEmptyLocationNameAlert = false
            self.newLocationName = ""
            self.isLocationEditMode = false
            self.fetchLocations()
        }
    }
    
    func addNewLocation() {
        guard !newLocationName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showEmptyLocationNameAlert = true
            return
        }
        
        createLocation {
            self.newLocationName = ""
            self.fetchLocations()
        }
    }
    
    private func createLocation(completion: @escaping () -> Void) {
        let input = NewLocation(name: newLocationName)
        let mutation = CreateLocationMutation(input: input)
        
        form.isLoading = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.createLocation {
                        completion()
                    } else if let errors = graphQLResult.errors {
                        print("Error creating location: \(errors)")
                    }
                case .failure(let error):
                    print("Failed to create location: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateLocation(id: String, name: String, completion: @escaping () -> Void) {
        let input = UpdateLocationInput(name: name)
        let mutation = UpdateLocationMutation(id: id, input: input)
        
        Network.shared.apollo.perform(mutation: mutation) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.updateLocation {
                        completion()
                    } else if let errors = graphQLResult.errors {
                        print("Error updating location: \(errors)")
                        completion()
                    }
                case .failure(let error):
                    print("Failed to update location: \(error.localizedDescription)")
                    completion()
                }
            }
        }
    }
    
    // MARK: - PurchaseUnit Management
    
    func deletePurchaseUnit(purchaseUnitId: String) {
        let mutation = DeletePurchaseUnitMutation(id: purchaseUnitId)
        
        form.isLoading = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let success = graphQLResult.data?.deletePurchaseUnit, success {
                        self?.purchaseUnits.removeAll { $0.id == purchaseUnitId }
                        self?.showPurchaseUnitDeleteSuccessAlert = true
                    } else if let errors = graphQLResult.errors {
                        self?.purchaseUnitDeleteErrorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self?.showPurchaseUnitDeleteErrorAlert = true
                    }
                case .failure(let error):
                    self?.purchaseUnitDeleteErrorMessage = "購入単位の削除に失敗しました: \(error.localizedDescription)"
                    self?.showPurchaseUnitDeleteErrorAlert = true
                }
            }
        }
    }
    
    func completePurchaseUnitEditing() {
        for (purchaseUnitId, name) in editingPurchaseUnitNames {
            if name.trimmingCharacters(in: .whitespaces).isEmpty {
                showEmptyPurchaseUnitNameAlert = true
                return
            }
        }
        
        var purchaseUnitsToUpdate: [(id: String, name: String)] = []
        
        for (purchaseUnitId, newName) in editingPurchaseUnitNames {
            guard let purchaseUnit = purchaseUnits.first(where: { $0.id == purchaseUnitId }) else { continue }
            
            let currentName = purchaseUnit.name
            
            if currentName != newName {
                purchaseUnitsToUpdate.append((id: purchaseUnitId, name: newName))
            }
        }
        
        guard !purchaseUnitsToUpdate.isEmpty else {
            editingPurchaseUnitNames.removeAll()
            showEmptyPurchaseUnitNameAlert = false
            newPurchaseUnitName = ""
            isPurchaseUnitEditMode = false
            return
        }
        
        var updateCount = 0
        let totalUpdates = purchaseUnitsToUpdate.count
        
        for purchaseUnitUpdate in purchaseUnitsToUpdate {
            updatePurchaseUnit(id: purchaseUnitUpdate.id, name: purchaseUnitUpdate.name) {
                updateCount += 1
                if updateCount == totalUpdates {
                    self.completeAllPurchaseUnitEdits()
                }
            }
        }
        
        if totalUpdates == 0 {
            completeAllPurchaseUnitEdits()
        }
    }
    
    private func completeAllPurchaseUnitEdits() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.editingPurchaseUnitNames.removeAll()
            self.showEmptyPurchaseUnitNameAlert = false
            self.newPurchaseUnitName = ""
            self.isPurchaseUnitEditMode = false
            if !self.form.ingredientId.isEmpty {
                self.fetchPurchaseUnitsByIngredient(ingredientId: self.form.ingredientId)
            }
        }
    }
    
    func addNewPurchaseUnit() {
        guard !newPurchaseUnitName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showEmptyPurchaseUnitNameAlert = true
            return
        }
        
        guard !form.ingredientId.isEmpty else {
            form.errorMessage = "先に食材を選択してください"
            isMutationError = true
            return
        }
        
        createPurchaseUnit {
            self.newPurchaseUnitName = ""
            if !self.form.ingredientId.isEmpty {
                self.fetchPurchaseUnitsByIngredient(ingredientId: self.form.ingredientId)
            }
        }
    }
    
    private func createPurchaseUnit(completion: @escaping () -> Void) {
        let input = NewPurchaseUnit(
            ingredientId: form.ingredientId,
            name: newPurchaseUnitName
        )
        let mutation = CreatePurchaseUnitMutation(input: input)
        
        form.isLoading = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.form.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.createPurchaseUnit {
                        completion()
                    } else if let errors = graphQLResult.errors {
                        print("Error creating purchase unit: \(errors)")
                    }
                case .failure(let error):
                    print("Failed to create purchase unit: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updatePurchaseUnit(id: String, name: String, completion: @escaping () -> Void) {
        let input = UpdatePurchaseUnitInput(name: name)
        let mutation = UpdatePurchaseUnitMutation(id: id, input: input)
        
        Network.shared.apollo.perform(mutation: mutation) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.updatePurchaseUnit {
                        completion()
                    } else if let errors = graphQLResult.errors {
                        print("Error updating purchase unit: \(errors)")
                        completion()
                    }
                case .failure(let error):
                    print("Failed to update purchase unit: \(error.localizedDescription)")
                    completion()
                }
            }
        }
    }
}
