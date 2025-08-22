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
    @Published var visibleDomain: ClosedRange<Date>?
    @Published var isDataExplorationMode = false
    @Published var selectedDataPoint: LineData?
    
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
    
    func selectPeriod(_ period: TimePeriod, for ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient) {
        selectedPeriod = period
        isDataExplorationMode = false // 期間選択時はデータ閲覧モードを解除
        selectedDataPoint = nil
        updateVisibleDomain(for: ingredient)
    }
    
    func updateVisibleDomain(for ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient) {
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
        
        visibleDomain = startDate...latestDate
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
    
    func getAveragePrice(for ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient) -> String {
        let filteredHistory = filteredPurchaseHistory(for: ingredient)
        guard !filteredHistory.isEmpty else { return "データなし" }
        
        let totalPrice = filteredHistory.reduce(0.0) { $0 + $1.price }
        let averagePrice = totalPrice / Double(filteredHistory.count)
        
        return String(format: "%.2f", averagePrice) + "円"
    }
    
    var visibleDomainLength: TimeInterval {
        switch selectedPeriod {
        case .week: return 7 * 24 * 60 * 60
        case .month: return 30 * 24 * 60 * 60  
        case .sixMonths: return 180 * 24 * 60 * 60
        case .year: return 365 * 24 * 60 * 60
        }
    }
    
    func enterDataExplorationMode(with dataPoint: LineData) {
        isDataExplorationMode = true
        selectedDataPoint = dataPoint
    }
    
    func exitDataExplorationMode() {
        isDataExplorationMode = false
        selectedDataPoint = nil
    }
    
    func findNearestDataPoint(to date: Date, in ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient) -> LineData? {
        let dataPoints = ingredient.purchaseHistory.compactMap { history -> LineData? in
            guard let historyDate = DateFormatter.apiFormat.date(from: history.date) else { return nil }
            return LineData(id: history.id, date: historyDate, price: history.price)
        }
        
        return dataPoints.min { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }
    }
    
    func getPriceForSelectedDate(_ selectedDate: Date, in ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient) -> Double? {
        return findNearestDataPoint(to: selectedDate, in: ingredient)?.price
    }
    
    func getSelectedDataPoint(_ rawSelectedDate: Date?, in ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient) -> LineData? {
        guard let rawDate = rawSelectedDate else { return nil }
        return findNearestDataPoint(to: rawDate, in: ingredient)
    }
}
