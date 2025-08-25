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
    
    // 利益
    struct ProfitOverTime {
        var date: Date
        var profit: Double
    }
    
    // 利益データ
    var data: [ProfitOverTime] {
        let calendar = Calendar.current
        return [
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!, profit: 100),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 2, day: 1))!, profit: 280),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 3, day: 1))!, profit: 200),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 4, day: 1))!, profit: 380),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 5, day: 1))!, profit: 400),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 6, day: 1))!, profit: 370),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 7, day: 1))!, profit: 430),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 8, day: 1))!, profit: 500),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 9, day: 1))!, profit: 530),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 10, day: 1))!, profit: 400),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 11, day: 1))!, profit: 370),
            ProfitOverTime(date: calendar.date(from: DateComponents(year: 2024, month: 12, day: 1))!, profit: 470),
        ]
    }
    
    //    @State var rawSelectedDate: Date?
    var selectedDate: Date? {
        // グラフから受け取った生の値(rawSelectedDate)と、dataの配列の各日付の時間差を比較し、最も近い日付を返す
        guard let rawDate = rawSelectedDate else { return nil }
        let closest = data.min(by: { abs($0.date.timeIntervalSince(rawDate)) < abs($1.date.timeIntervalSince(rawDate)) })
        return closest?.date
    }
    
    var maxPrice: Double {
        let historyData = ingredient.purchaseHistory.compactMap { history -> Double? in
            return history.price
        }
        return historyData.max() ?? 0
    }
    
    var body: some View {
        VStack {
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
            }
            
            
            
            VStack {
                if viewModel.isLoading {
                    ProgressView("読み込み中…")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    //                    HStack {
                    //                        ForEach(TimePeriod.allCases, id: \.self) { period in
                    //                            Button(action: {
                    //                                viewModel.selectPeriod(period, for: ingredient)
                    //                            }) {
                    //                                Text(period.rawValue)
                    //                                    .padding(.horizontal, 12)
                    //                                    .padding(.vertical, 6)
                    //                                    .background(
                    //                                        viewModel.selectedPeriod == period ? Color.gray : Color.clear
                    //                                    )
                    //                                    .foregroundColor(viewModel.selectedPeriod == period ? .white : .black)
                    //                                    .cornerRadius(16)
                    //                            }
                    //                        }
                    //                    }
                    //                    .padding(.horizontal)
                    
                    // MARK: - グラフ
                    
                    VStack/*(alignment: .leading, spacing: 8) */{
                        // サマリー表示モード（常に表示）
                        //                        VStack(alignment: .leading, spacing: 4) {
                        //                            Text("平均")
                        //                                .font(.caption)
                        //                                .foregroundColor(.gray)
                        //                            Text(viewModel.getAveragePrice(for: ingredient))
                        //                                .font(.title)
                        //                                .fontWeight(.bold)
                        //                                .foregroundColor(.black)
                        //                            Text(viewModel.getDisplayDateRange(for: ingredient))
                        //                                .font(.caption)
                        //                                .foregroundColor(.gray)
                        //                        }
                        //                        .padding(.horizontal)
                        
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
//                               .foregroundStyle(.green)
                                .symbol(Circle())
                            }
                            if let selectedData = viewModel.getSelectedDataPoint(rawSelectedDate, in: ingredient) {
                                // 選択されたデータポイントの真上に縦線を表示
                                RuleMark(
                                    x: .value("Selected", selectedData.date)
                                )
                                .foregroundStyle(.gray.opacity(0.3))
                                .offset(yStart: -10)
                                .zIndex(-1)
                                .annotation(
                                    position: .top
                                    ,
                                    spacing: 0,
                                    overflowResolution: .init(
                                        x: .fit(to: .chart),
                                        y: .disabled
                                    )
                                ) {
                                    VStack(spacing: 2) {
                                        Text(String(format: "%.0f円", selectedData.price))
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        Text(selectedData.date, format: Date.FormatStyle(date: .numeric, time: .none))
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        .chartXSelection(value: $rawSelectedDate)
//                        .chartScrollableAxes(.horizontal)
//                        .chartXVisibleDomain(length: viewModel.visibleDomainLength)
//                        .chartXAxis {
//                            AxisMarks(values: .automatic(desiredCount: 5)) { value in
//                                if let dateValue = value.as(Date.self) {
//                                    AxisValueLabel {
//                                        switch viewModel.selectedPeriod {
//                                        case .week, .month:
//                                            Text(dateValue.formattedJapaneseDay())
//                                        case .sixMonths, .year:
//                                            Text(dateValue.formattedJapaneseMonth())
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        .chartYScale(domain: 0 ... (maxPrice + 100))
                        .frame(height: 300)
                        .padding()
                    }
                    
                    // MARK: - 移植先グラフ
                    
                    VStack {
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
//                               .foregroundStyle(.green)
                                .symbol(Circle())
                            }
//                            .symbol(by: .value("departmentName", "A"))
                            if let selectedDate {
                                // 選択した時にRuleMarkを追加
                                RuleMark(
                                    x: .value("Selected", selectedDate, unit: .month)
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
                                    Text(selectedDate, format: Date.FormatStyle(date: .numeric, time: .none))
                                        .padding()
                                        .background(Color.red)
                                }
                            }
                        }
                        .chartXSelection(value: $rawSelectedDate) // タップした位置のX軸上の値を取得
                        .frame(height: 300)
                        .padding()
                    }
                }
            }
        }
    }
}

//#Preview {
//    GraphContentPage()
//}
