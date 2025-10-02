//
//  ListViewModel.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import SwiftUI
import Apollo
import ShokumemoAPI

class ListViewModel: ObservableObject {
    @Published var inventories: [GetInventoriesQuery.Data.Inventory] = []
    @Published var categories: [GetCategoriesAndIngredientsQuery.Data.Category] = []
    @Published var selectedCategoryIds: Set<String> = []
    @Published var showFilterMenu = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isShowSheet = false
    @Published var discardedCount: Int = 0
    @Published var activeCount: Int = 0
    @Published var consumedCount: Int = 0
    private var watcher: GraphQLQueryWatcher<GetInventoriesQuery>?
    private var categoriesWatcher: GraphQLQueryWatcher<GetCategoriesAndIngredientsQuery>?
    private var statusCountsWatcher: GraphQLQueryWatcher<GetInventoryStatusCountsQuery>?
    
    private var filteredInventories: [GetInventoriesQuery.Data.Inventory] {
        guard !selectedCategoryIds.isEmpty else { return inventories }
        return inventories.filter { selectedCategoryIds.contains($0.ingredient.category.id) }
    }
    
    var expiredInventories: [GetInventoriesQuery.Data.Inventory] {
        return filteredInventories.filter { Date.isExpired($0.expiryDate) }
    }
    
    var todayInventories: [GetInventoriesQuery.Data.Inventory] {
        return filteredInventories.filter { Date.isToday($0.expiryDate) }
    }
    
    var futureInventories: [GetInventoriesQuery.Data.Inventory] {
        return filteredInventories.filter { Date.isFuture($0.expiryDate) }
    }
    
    
    init(sort: InventorySort? = .expiryAsc ) {
        
        let gqlSort: GraphQLNullable<GraphQLEnum<InventorySort>> =
        sort.map { .some(GraphQLEnum($0)) } ?? .none
        
        let activeFilter = InventoryFilter(status: [GraphQLEnum(.active)])
        
        // ACTIVEな在庫のみを取得
        watcher = Network.shared.apollo.watch(
            query: GetInventoriesQuery(sort: gqlSort, filter: .some(activeFilter)),
            cachePolicy: .returnCacheDataAndFetch
        ) { [weak self] result in
            switch result {
            case .success(let graphQLResult):
                self?.inventories = graphQLResult.data?.inventory ?? []
            case .failure(let error):
                print("Query watch error:", error)
            }
        }
        
        // 統計データを取得
        statusCountsWatcher = Network.shared.apollo.watch(
            query: GetInventoryStatusCountsQuery(),
            cachePolicy: .returnCacheDataAndFetch
        ) { [weak self] result in
            switch result {
            case .success(let graphQLResult):
                if let counts = graphQLResult.data?.inventoryStatusCounts {
                    self?.activeCount = counts.active
                    self?.discardedCount = counts.discarded
                    self?.consumedCount = counts.consumed
                }
            case .failure(let error):
                print("Status counts query watch error:", error)
            }
        }
        
        // カテゴリー一覧を取得
        categoriesWatcher = Network.shared.apollo.watch(
            query: GetCategoriesAndIngredientsQuery(),
            cachePolicy: .returnCacheDataAndFetch
        ) { [weak self] result in
            switch result {
            case .success(let graphQLResult):
                self?.categories = graphQLResult.data?.categories ?? []
            case .failure(let error):
                print("Categories query watch error:", error)
            }
        }
    }
    
    func fetchInventories(sort: InventorySort? = .expiryAsc) {
        isLoading = true
        
        let gqlSort: GraphQLNullable<GraphQLEnum<InventorySort>> =
        sort.map { .some(GraphQLEnum($0)) } ?? .none
        
        let activeFilter = InventoryFilter(status: [GraphQLEnum(.active)])

        Network.shared.apollo.fetch(query: GetInventoriesQuery(sort: gqlSort, filter: .some(activeFilter)), cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    self?.inventories = graphQLResult.data?.inventory ?? []
                case .failure(let error):
                    self?.errorMessage = "データ取得に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deleteInventory(id: String) {
        Network.shared.apollo.perform(mutation: DeleteInventoryMutation(id: id)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let graphQLResult):
                    if graphQLResult.data?.deleteInventory == true {
                        // 削除成功時はwatcherが自動でデータを更新
                        print("✅ Inventory deleted successfully")
                    } else {
                        self?.errorMessage = "削除に失敗しました"
                    }
                case .failure(let error):
                    self?.errorMessage = "削除エラー: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func fetchInventoryStatusCounts() {
        Network.shared.apollo.fetch(
            query: GetInventoryStatusCountsQuery(),
            cachePolicy: .fetchIgnoringCacheData
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let graphQLResult):
                    if let counts = graphQLResult.data?.inventoryStatusCounts {
                        self?.activeCount = counts.active
                        self?.discardedCount = counts.discarded
                        self?.consumedCount = counts.consumed
                    }
                case .failure(let error):
                    print("Status counts fetch error:", error)
                }
            }
        }
    }
    
    // MARK: - Refresh Data
    func refreshAllData() async {
        await MainActor.run {
            isLoading = true
        }
        
        // 在庫データと統計データを並行して取得
        await withTaskGroup(of: Void.self) { group in
            // 在庫データの取得
            group.addTask { [weak self] in
                await self?.refreshInventoriesAsync()
            }
            
            // 統計データの取得
            group.addTask { [weak self] in
                await self?.refreshStatusCountsAsync()
            }
            
            // カテゴリデータの取得
            group.addTask { [weak self] in
                await self?.refreshCategoriesAsync()
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func refreshInventoriesAsync() async {
        return await withCheckedContinuation { continuation in
            let activeFilter = InventoryFilter(status: [GraphQLEnum(.active)])
            
            Network.shared.apollo.fetch(
                query: GetInventoriesQuery(sort: .some(GraphQLEnum(.expiryAsc)), filter: .some(activeFilter)),
                cachePolicy: .fetchIgnoringCacheData
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let graphQLResult):
                        self?.inventories = graphQLResult.data?.inventory ?? []
                    case .failure(let error):
                        self?.errorMessage = "在庫データの取得に失敗しました: \(error.localizedDescription)"
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    private func refreshStatusCountsAsync() async {
        return await withCheckedContinuation { continuation in
            Network.shared.apollo.fetch(
                query: GetInventoryStatusCountsQuery(),
                cachePolicy: .fetchIgnoringCacheData
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let graphQLResult):
                        if let counts = graphQLResult.data?.inventoryStatusCounts {
                            self?.activeCount = counts.active
                            self?.discardedCount = counts.discarded
                            self?.consumedCount = counts.consumed
                        }
                    case .failure(let error):
                        print("Status counts refresh error:", error)
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    private func refreshCategoriesAsync() async {
        return await withCheckedContinuation { continuation in
            Network.shared.apollo.fetch(
                query: GetCategoriesAndIngredientsQuery(),
                cachePolicy: .fetchIgnoringCacheData
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let graphQLResult):
                        self?.categories = graphQLResult.data?.categories ?? []
                    case .failure(let error):
                        print("Categories refresh error:", error)
                    }
                    continuation.resume()
                }
            }
        }
    }
}
