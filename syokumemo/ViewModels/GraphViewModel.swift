//
//  GetIngredientsAndParchaseHistory.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/10.
//

import SwiftUI
import Apollo
import ShokumemoAPI

// データモデル
struct LineData: Identifiable {
    var id: String
    var date: Date
    var price: Double
}

class GraphViewModel: ObservableObject {
    @Published var ingredients: [GetIngredientsAndParchaseHistoryQuery.Data.Ingredient] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var lineData: [LineData] = []
    
    private var watcher: GraphQLQueryWatcher<GetIngredientsAndParchaseHistoryQuery>?
    
    init() {
        watcher = Network.shared.apollo.watch(
            query: GetIngredientsAndParchaseHistoryQuery(),
            cachePolicy: .returnCacheDataAndFetch
        ) { [weak self] result in
            switch result {
            case .success(let graphQLResult):
                // キャッシュ or ネットワークから返ってきた最新の items に差し替え
                self?.ingredients = graphQLResult.data?.ingredients ?? []
            case .failure(let error):
                print("Query watch error:", error)
            }
        }
    }
    func fetchGetPriceTrend() {
        isLoading = true
        
        Network.shared.apollo.fetch(query: GetIngredientsAndParchaseHistoryQuery()) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    self?.ingredients = graphQLResult.data?.ingredients ?? []
                case .failure(let error):
                    self?.errorMessage = "データ取得に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }
}

