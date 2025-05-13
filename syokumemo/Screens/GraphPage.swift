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
                                .foregroundStyle(.blue)
                                .symbol(Circle())
                            }
                            
                            
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
}

#Preview {
    GraphPage()
}
