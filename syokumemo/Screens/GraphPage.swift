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

struct GraphPage: View {
    @StateObject private var viewModel = GraphViewModel()
    @State private var rawSelectedDate: Date?
    @State private var path: [GraphIngredient] = []
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("読み込み中…")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                NavigationStack(path: $path) {
                    List(viewModel.ingredients, id: \.id) { ingredient in
                        NavigationLink(value: ingredient) {
                            Section(
                            ) {
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
                                    .foregroundStyle(.green)
                                    .lineStyle(StrokeStyle(lineWidth: 2.5)) // 線を少し太く
                                }
                            }
                            
                            // ★ここを追加：X軸とY軸を非表示にするモディファイア★
                            .chartXAxis(.hidden) // X軸を非表示
                            .chartYAxis(.hidden) // Y軸を非表示
                            
                            
                            
                            // ★ミニチャートのサイズを固定する場合、frameモディファイアも追加★
                            .frame(width: 90, height: 30) // 必要に応じてサイズを調整
                            
                                }
                            }
//                    .listRowBackground(Color.green.opacity(0.15))
                        }
                    }
                    .navigationDestination(for: GraphIngredient.self) { ingredient in
                        GraphContentPage(ingredient: ingredient)
                    }
                }
                .listStyle(.plain)
            }
        }
//        .onAppear {
//            viewModel.fetchGetPriceTrend()
//        }
    }
}

#Preview {
    GraphPage()
}
