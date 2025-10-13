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
                        .foregroundColor(.accentColor)
                    }
                    Spacer()
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(height: 44)
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - ChartAnnotation Component
struct ChartAnnotation: View {
    let selectedData: LineData
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(selectedData.price)円")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text(selectedData.date, format: Date.FormatStyle(date: .numeric, time: .none))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}



// MARK: - MAIN
struct GraphContentPage: View {
    @StateObject private var viewModel = GraphViewModel()
    @State private var rawSelectedDate: Date?
    @Binding var path: [GraphNavigationPath]
    let ingredient: GetIngredientsAndParchaseHistoryQuery.Data.Ingredient
    @Environment(\.dismiss) private var dismiss
    
    
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
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("期間選択", selection: $viewModel.selectedPeriod) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .onChange(of: viewModel.selectedPeriod) { _, newValue in
                            viewModel.selectPeriod(newValue, for: ingredient)
                        }
                    }
                    
                    // MARK: - グラフ
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("平均")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                HStack(alignment: .firstTextBaseline) {
                                    Text(viewModel.getAveragePrice(for: ingredient))
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    Text("円")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text(viewModel.getDisplayDateRange(for: ingredient))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            // 購入単位選択メニュー
                            Menu {
                                ForEach(viewModel.availablePurchaseUnits, id: \.self) { unit in
                                    Button(action: {
                                        viewModel.selectPurchaseUnit(unit, for: ingredient)
                                    }) {
                                        HStack {
                                            Text(unit)
                                            if unit == viewModel.selectedPurchaseUnit {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("購入単位")
                                        .font(.subheadline)
                                        .foregroundColor(.accentColor)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        
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
                                .foregroundStyle(Color(hex: ingredient.category.colorCode))
                                .symbol(Circle())
                            }
                            if let selectedData = viewModel.getSelectedDataPoint(rawSelectedDate, in: ingredient) {
                                RuleMark(
                                    x: .value("Selected", selectedData.date)
                                )
                                .foregroundStyle(Color(hex: ingredient.category.colorCode).opacity(0.3))
                                .offset(yStart: -10)
                                .zIndex(-1)
                                .annotation(
                                    position: .top,
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
                        .id("\(viewModel.selectedPeriod.rawValue)-\(ingredient.id)")
                        .chartXSelection(value: $rawSelectedDate)
                        .chartYScale(domain: viewModel.getYAxisRange(for: ingredient))
                        .chartXAxis {
                            AxisMarks(values: .stride(by: viewModel.getXAxisStride(), count: viewModel.getXAxisStrideCount())) { value in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                                    .foregroundStyle(.gray.opacity(0.3))
                                if let date = value.as(Date.self) {
                                    AxisValueLabel {
                                        Text(viewModel.getXAxisLabel(for: date))
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .chartPlotStyle { plotArea in
                            plotArea
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                        
                        // カスタム凡例
                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: ingredient.category.colorCode))
                                    .frame(width: 8, height: 8)
                                Text(viewModel.selectedPurchaseUnit ?? "全て")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                    
                    // MARK: - データリスト
                    List {
                        ForEach(viewModel.getSortedPurchaseHistoryForList(for: ingredient), id: \.id) { historyItem in
                            Button(action: {
                                path.append(GraphNavigationPath.purchaseHistory(historyItem.id))
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(historyItem.price)円")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.black)
                                        
                                        Text(historyItem.purchaseUnit.name)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("購入日")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        if let date = DateFormatter.apiFormat.date(from: historyItem.date) {
                                            Text(DateFormatter.displayFormat.string(from: date))
                                                .font(.body)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
        .onAppear {
            viewModel.setupPurchaseUnits(for: ingredient)
        }
        .onChange(of: ingredient) { _, newIngredient in
            viewModel.setupPurchaseUnits(for: newIngredient)
        }
    }
}

//#Preview {
//    GraphContentPage()
//}
