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
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isShowSheet = false
    private var watcher: GraphQLQueryWatcher<GetInventoriesQuery>?
    
    var expiredInventories: [GetInventoriesQuery.Data.Inventory] {
        return inventories.filter { Date.isExpired($0.expiryDate) }
    }
    
    var todayInventories: [GetInventoriesQuery.Data.Inventory] {
        return inventories.filter { Date.isToday($0.expiryDate) }
    }
    
    var futureInventories: [GetInventoriesQuery.Data.Inventory] {
        return inventories.filter { Date.isFuture($0.expiryDate) }
    }
    
    var discardedCount: Int {
        return inventories.filter { $0.status == .discarded }.count
    }
    
    var activeCount: Int {
        return inventories.filter { $0.status == .active }.count
    }
    
    var consumedCount: Int {
        return inventories.filter { $0.status == .consumed }.count
    }
    
    init(sort: InventorySort? = .expiryAsc ) {
        
        let gqlSort: GraphQLNullable<GraphQLEnum<InventorySort>> =
        sort.map { .some(GraphQLEnum($0)) } ?? .none
        
        watcher = Network.shared.apollo.watch(
            query: GetInventoriesQuery(sort: gqlSort),
            cachePolicy: .returnCacheDataAndFetch
        ) { [weak self] result in
            switch result {
            case .success(let graphQLResult):
                // キャッシュ or ネットワークから返ってきた最新の items に差し替え
                self?.inventories = graphQLResult.data?.inventory ?? []
            case .failure(let error):
                print("Query watch error:", error)
            }
        }
    }
    
    func fetchInventories(sort: InventorySort? = .expiryAsc) {
        isLoading = true
        
        let gqlSort: GraphQLNullable<GraphQLEnum<InventorySort>> =
        sort.map { .some(GraphQLEnum($0)) } ?? .none

        Network.shared.apollo.fetch(query: GetInventoriesQuery(sort: gqlSort)) { [weak self] result in
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
}
