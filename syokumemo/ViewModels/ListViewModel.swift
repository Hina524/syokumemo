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
    private var watcher: GraphQLQueryWatcher<GetInventoriesQuery>?
    
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
}
