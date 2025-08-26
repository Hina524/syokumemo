//
//  GraphContentPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/06/25.
//


import SwiftUI
import ShokumemoAPI
import Charts

// MARK: - NavigationHeader Component
struct NavigationHeader: View {
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button(action: onDismiss) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("戻る")
                                .font(.body)
                        }
                        .foregroundColor(.black)
                    }
                    Spacer()
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding()
            .frame(height: 50)
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - ChartAnnotation Component
struct ChartAnnotation: View {
    let selectedData: LineData
    
    var body: some View {
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

// MARK: - TimePeriodSelector Component
struct TimePeriodSelector: View {
    let ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient
    let viewModel: GraphViewModel
    
    var body: some View {
        HStack {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: {
                    viewModel.selectPeriod(period, for: ingredient)
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
    }
}

// MARK: - PriceSummary Component
struct PriceSummary: View {
    let ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient
    let viewModel: GraphViewModel
    
    var body: some View {
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
    }
}

// MARK: - PriceChart Component
struct PriceChart: View {
    let ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient
    let viewModel: GraphViewModel
    @Binding var rawSelectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PriceSummary(ingredient: ingredient, viewModel: viewModel)
            
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
                        ChartAnnotation(selectedData: selectedData)
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
    }
}

// MARK: - MAIN
struct GraphContentPage: View {
    @StateObject private var viewModel = GraphViewModel()
    @State private var rawSelectedDate: Date?
    let ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient
    @Environment(\.dismiss) private var dismiss
    
    var maxPrice: Double {
        let historyData = ingredient.purchaseHistory.compactMap { history -> Double? in
            return history.price
        }
        return historyData.max() ?? 0
    }
    
    var body: some View {
        VStack {
            NavigationHeader(title: ingredient.name) {
                dismiss()
            }
            
            VStack {
                if viewModel.isLoading {
                    ProgressView("読み込み中…")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    TimePeriodSelector(ingredient: ingredient, viewModel: viewModel)
                    
                    // MARK: - グラフ
                    
                    PriceChart(
                        ingredient: ingredient,
                        viewModel: viewModel,
                        rawSelectedDate: $rawSelectedDate
                    )
                }
            }
            Spacer()
        }
    }
}

//#Preview {
//    GraphContentPage()
//}
