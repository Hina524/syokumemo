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
