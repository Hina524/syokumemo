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

enum TimePeriod: String, CaseIterable {
    case week = "週"
    case month = "月"
    case sixMonths = "6ヶ月"
    case year = "年"
}

class GraphViewModel: ObservableObject {
    @Published var ingredients: [GetIngredientsAndParchaseHistoryQuery.Data.Ingredient] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var lineData: [LineData] = []
    @Published var selectedPeriod: TimePeriod = .month
    
    private var watcher: GraphQLQueryWatcher<GetIngredientsAndParchaseHistoryQuery>?
    
    init() {
        isLoading = true
        
        watcher = Network.shared.apollo.watch(
            query: GetIngredientsAndParchaseHistoryQuery(),
            cachePolicy: .returnCacheDataAndFetch
        ) { [weak self] result in
            
            
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    // キャッシュ or ネットワークから返ってきた最新の items に差し替え
                    self?.ingredients = graphQLResult.data?.ingredients ?? []
                case .failure(let error):
                    print("Query watch error:", error)
                    self?.errorMessage = "データ取得に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func selectPeriod(_ period: TimePeriod) {
        selectedPeriod = period
    }
    
    func filteredPurchaseHistory(for ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient) -> [GetIngredientsAndParchaseHistoryQuery.Data.Ingredient.PurchaseHistory] {
        let calendar = Calendar.current
        
        // データの最新日付を取得
        let latestDate = ingredient.purchaseHistory
            .compactMap { DateFormatter.apiFormat.date(from: $0.date) }
            .max() ?? Date()
        
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: latestDate) ?? latestDate
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: latestDate) ?? latestDate
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: latestDate) ?? latestDate
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: latestDate) ?? latestDate
        }
        
        return ingredient.purchaseHistory.filter { history in
            guard let date = DateFormatter.apiFormat.date(from: history.date) else { return false }
            return date >= startDate && date <= latestDate
        }
    }
    
    func getDisplayDateRange(for ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient) -> String {
        let filteredHistory = filteredPurchaseHistory(for: ingredient)
        guard !filteredHistory.isEmpty else { return "" }
        
        let dates = filteredHistory.compactMap { DateFormatter.apiFormat.date(from: $0.date) }
        guard let minDate = dates.min(), let maxDate = dates.max() else { return "" }
        
        return "\(DateFormatter.displayFormat.string(from: minDate))〜\(DateFormatter.displayFormat.string(from: maxDate))"
    }
}
