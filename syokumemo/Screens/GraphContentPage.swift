//
//  GraphContentPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/06/25.
//


import SwiftUI
import ShokumemoAPI
import Charts

struct GraphContentPage: View {
    @StateObject private var viewModel = GraphViewModel()
    @State private var rawSelectedDate: Date?
    let ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("戻る")
                                .font(.body)
                        }
                        .foregroundColor(.black)
                    }
                    Spacer()
                }
                
                Text(ingredient.name)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding()
            .frame(height: 50)
            .navigationBarBackButtonHidden(true)
            
            if viewModel.isLoading {
                ProgressView("読み込み中…")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                HStack {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(action: {
                            viewModel.selectPeriod(period)
                        }) {
                            Text(period.rawValue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    viewModel.selectedPeriod == period ? Color.gray : Color.clear
                                )
                                .foregroundColor(viewModel.selectedPeriod == period ? .white : .black)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("平均")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(viewModel.getAveragePrice(for: ingredient))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text(viewModel.getDisplayDateRange(for: ingredient))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Section(
                    ) {
                        Chart {
                            ForEach(
                                viewModel.filteredPurchaseHistory(for: ingredient)
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
                        .chartXSelection(value: $rawSelectedDate)
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                                if let dateValue = value.as(Date.self) {
                                    AxisValueLabel {
                                        switch viewModel.selectedPeriod {
                                        case .week, .month:
                                            Text(dateValue.formattedJapaneseDay())
                                        case .sixMonths, .year:
                                            Text(dateValue.formattedJapaneseMonth())
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}
    
    //#Preview {
    //    GraphContentPage()
    //}
