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
    @State private var rawSelectedDate: Date?
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("読み込み中…")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                List(viewModel.ingredients, id: \.id) { ingredient in
                    Section(
                        header: Text(ingredient.name)
                            .font(.headline)
                    ) {
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
                                .symbol(Circle())
                                if let rawSelectedDate {
                                    // 選択した時にRuleMarkを追加
                                    RuleMark(
                                        x: .value("Selected", rawSelectedDate, unit: .month)
                                    )
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .offset(yStart: -10)
                                    .zIndex(-1)// RuleMarkがLineMarkの後ろに来るように。defaultは0
                                    .annotation( // 注釈の作成
                                        position: .top, //
                                        spacing: 0,
                                        overflowResolution: .init(
                                            x: .fit(to: .chart), // X軸では注釈がグラフの端の境界を超えないようにfitさせる
                                            y: .disabled // Y軸では注釈がグラフのすぐ上に来るようにするようにオーバーフロー解決を無効にする
                                        )
                                    ) {
                                        Text(rawSelectedDate, format: Date.FormatStyle(date: .numeric, time: .none))
                                            .padding()
                                            .background(Color.cyan)
                                    }
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding(.top, 65)
                        .chartXSelection(value: $rawSelectedDate) // タップした位置のX軸上の値を取得
                        //  .chartScrollableAxes(.horizontal)
                                                .chartXAxis {
                                                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                                                        if let dateValue = value.as(Date.self) {
                                                            AxisValueLabel {
                                                                Text(dateValue.formattedJapaneseMonth())
                                                            }
                                                        }
                            }
                        }
                    }
                  //  .frame(height: 400)
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
