//
//  GraphPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import ShokumemoAPI
import Charts

struct GraphPage: View {
    @StateObject private var viewModel = GraphViewModel()
    var list = ["aaa"]
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("読み込み中…")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                List(viewModel.ingredients, id: \.id) { ingredient in
                    Section(header: Text(ingredient.name)) {
                        Chart {
//                            ForEach(
//                                ingredient.purchaseHistory
//                                    .sorted { $0.purchasedAt < $1.purchasedAt }
//                                    .compactMap { history in
//                                        guard let date = ISO8601DateFormatter().date(from: history.purchasedAt) else { return nil }
//                                        return LineData(id: history.id, date: date, price: history.price)
//                                    }
//                            ) { data in
//                                LineMark(
//                                    x: .value("日付", data.date),
//                                    y: .value("価格", data.price)
//                                )
//                                .foregroundStyle(.blue)
//                                .symbol(Circle())
//                            }
                            
                            ForEach(
                                ingredient.purchaseHistory
                                    .compactMap { history in
                                        guard let date = ISO8601DateFormatter().date(from: history.date) else { return nil }
                                        return LineData(id: history.id, date: date, price: history.price)
                                    }
                                    .sorted { $0.date < $1.date }
                            ) { (data: LineData) in
                                LineMark(
                                    x: .value("日付", data.date),
                                    y: .value("価格", data.price)
                                )
                                .foregroundStyle(.blue)
                                .symbol(Circle())
                            }
                            // comment area もうグラフいっかな　スライドやるか... setuhaaru　謎の沼d
//                            ForEach(list, id:\.self) { val in
//                                LineMark(
//                                    x: .value("日付", "a"),
//                                    y: .value("価格", "a")
//                                )
//                                .foregroundStyle(.blue)
//                                .symbol(Circle())
//                            }
                        }
                        .frame(height: 200)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchGetPriceTrend()
        }
    }
    
    private func formattedDate(from isoDate: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: isoDate) ?? Date()
    }
}

#Preview {
    GraphPage()
}
