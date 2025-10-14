//
//  GraphPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import ShokumemoAPI
import Charts

typealias GraphIngredient = GetIngredientsAndParchaseHistoryQuery.Data.Ingredient

enum GraphNavigationPath: Hashable {
    case ingredient(GraphIngredient)
    case purchaseHistory(String) // IDのみを保持
    case selectLocation(historyId: String)
    case selectPurchaseUnit(historyId: String, ingredientId: String)
    
    static func == (lhs: GraphNavigationPath, rhs: GraphNavigationPath) -> Bool {
        switch (lhs, rhs) {
        case (.ingredient(let lhsIngredient), .ingredient(let rhsIngredient)):
            return lhsIngredient.id == rhsIngredient.id
        case (.purchaseHistory(let lhsId), .purchaseHistory(let rhsId)):
            return lhsId == rhsId
        case (.selectLocation(let lhsHistoryId), .selectLocation(let rhsHistoryId)):
            return lhsHistoryId == rhsHistoryId
        case (.selectPurchaseUnit(let lhsHistoryId, let lhsIngredientId), .selectPurchaseUnit(let rhsHistoryId, let rhsIngredientId)):
            return lhsHistoryId == rhsHistoryId && lhsIngredientId == rhsIngredientId
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .ingredient(let ingredient):
            hasher.combine("ingredient")
            hasher.combine(ingredient.id)
        case .purchaseHistory(let id):
            hasher.combine("purchaseHistory")
            hasher.combine(id)
        case .selectLocation(let historyId):
            hasher.combine("selectLocation")
            hasher.combine(historyId)
        case .selectPurchaseUnit(let historyId, let ingredientId):
            hasher.combine("selectPurchaseUnit")
            hasher.combine(historyId)
            hasher.combine(ingredientId)
        }
    }
}

struct IngredientRow: View {
    let ingredient: GraphIngredient
    
    var body: some View {
        NavigationLink(value: GraphNavigationPath.ingredient(ingredient)) {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Circle()
                                .fill(Color(hex: ingredient.category.colorCode))
                                .frame(width: 16, height: 16)
                            Text(ingredient.category.name)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Text(ingredient.name)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Chart {
                        ForEach(
                            ingredient.purchaseHistory
                                .compactMap { history -> LineData? in
                                    guard let date = DateFormatter.apiFormat.date(from: history.date) else { return nil }
                                    return LineData(id: history.id, date: date, price: history.price)
                                }
                                .sorted { $0.date < $1.date }
                        ) { data in
                            LineMark(
                                x: .value("日付", data.date),
                                y: .value("価格", data.price)
                            )
                            .foregroundStyle(Color(hex: ingredient.category.colorCode))
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(width: 90, height: 30)
                }
            }
        }
    }
}

struct GraphPage: View {
    @StateObject private var viewModel = GraphViewModel()
    @State private var rawSelectedDate: Date?
    @State private var path: [GraphNavigationPath] = []
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("読み込み中…")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    NavigationStack(path: $path) {
                        if viewModel.filteredIngredients.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("データがありません")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text("購入履歴がある食材が表示されます")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .refreshable {
                                viewModel.errorMessage = nil
                                await viewModel.refreshAllData()
                            }
                        } else {
                            List(viewModel.filteredIngredients, id: \.id) { ingredient in
                                IngredientRow(ingredient: ingredient)
                            }
                            .refreshable {
                                viewModel.errorMessage = nil
                                await viewModel.refreshAllData()
                            }
                            .listStyle(.plain)
                        }
                    .navigationDestination(for: GraphNavigationPath.self) { destination in
                        switch destination {
                        case .ingredient(let ingredient):
                            GraphContentPage(path: $path, ingredient: ingredient)
                        case .purchaseHistory(let historyId):
                            if let historyItem = findPurchaseHistory(id: historyId),
                               let ingredient = findIngredientByHistoryId(historyId: historyId) {
                                PurchaseHistoryDetailPage(
                                    historyItem: historyItem,
                                    ingredientId: ingredient.id
                                )
                            } else {
                                Text("購入履歴が見つかりません")
                            }
                        case .selectLocation, .selectPurchaseUnit:
                            // Sheet方式に変更したため不要
                            EmptyView()
                        }
                    }
                    }
                }
            }
            
            // フローティングボタン（絞り込み機能）
            if path.isEmpty && !viewModel.isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.showFilterMenu = true
                        }) {
                            Label("絞込み", systemImage: "arrow.up.and.down.text.horizontal")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(25)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showFilterMenu) {
            CategoryFilterView(
                selectedCategoryIds: $viewModel.selectedCategoryIds,
                categories: viewModel.categories
            )
        }
//        .onAppear {
//            viewModel.fetchGetPriceTrend()
//        }
    }
    
    private func findPurchaseHistory(id: String) -> GetIngredientsAndParchaseHistoryQuery.Data.Ingredient.PurchaseHistory? {
        for ingredient in viewModel.ingredients {
            if let historyItem = ingredient.purchaseHistory.first(where: { $0.id == id }) {
                return historyItem
            }
        }
        return nil
    }
    
    private func findIngredientByHistoryId(historyId: String) -> GraphIngredient? {
        for ingredient in viewModel.ingredients {
            if ingredient.purchaseHistory.contains(where: { $0.id == historyId }) {
                return ingredient
            }
        }
        return nil
    }
}

#Preview {
    GraphPage()
}
