//
//  InputPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import ShokumemoAPI

typealias Category = GetCategoriesAndIngredientsQuery.Data.Category

let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    formatter.zeroSymbol  = ""
    return formatter
}()

struct InputInventoryPage: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = InputInventoryViewModel()
    @State private var selectedIngredient: GetCategoriesAndIngredientsQuery.Data.Category.Ingredient? = nil
    @State private var showCategorySelection = false
    @State private var path = [Category]()
    @State private var isOnFractionInput = false
    @State private var isOnInputExpiryDate = false
    @State private var isOnGraphInput = false
    @State private var selectedDate = Date()
    @State private var setExpiryDateOneYearLater = false
    @State private var setDateNotToday: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var gesture: some Gesture {
        DragGesture()
            .onChanged{ value in
                if value.translation.height != 0 {
                    self.isFocused = false
                }
            }
    }
    
    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                Form {
                    // MARK: 食材選択
                    Section {
                        if let name = viewModel.form.selectedIngredientName {
                            Text(name)
                        } else {
                            Text("未選択")
                        }
                    } header: {
                        (
                            Text("食材") + Text("*").foregroundColor(.red)
                        )
                        .font(.headline)
                    } footer: {
                        Text("<食材カテゴリ>から選択or追加")
                    }
                    
                    Section {
                        ForEach(viewModel.form.categories, id: \.id) { category in
                            NavigationLink(value: category) {
                                Text(category.name)
                            }
                        }
                    } header: {
                        (
                            Text("食材カテゴリ") + Text("*").foregroundColor(.red)
                        )
                        .font(.headline)
                    }
                    
                    // MARK: 数量
                    Section {
                        HStack {
                            if isOnFractionInput {
                                VStack {
                                    TextField("分子(半角数字)", value: $viewModel.form.numerator, format: .number)
                                        .keyboardType(.asciiCapableNumberPad)
                                        .focused($isFocused)
                                    Divider()
                                    TextField("分母(半角数字)", value: $viewModel.form.denominator, format: .number)
                                        .keyboardType(.asciiCapableNumberPad)
                                        .focused($isFocused)
                                }
                            }else{
                                TextField("数量(半角数字)", value: $viewModel.form.numerator, format: .number)
                                    .keyboardType(.asciiCapableNumberPad)
                                    .focused($isFocused)
                            }
                            
                            Spacer()
                            TextField("個", text: $viewModel.form.unit)
                                .focused($isFocused)
                        }
                        Toggle(isOn: $isOnFractionInput){
                            Text("分数入力")
                        }
                        
                    } header: {
                        (
                            Text("数量") + Text("*").foregroundColor(.red)
                        )
                        .font(.headline)
                    }
                    
                    // MARK: 消費期限
                    Section {
                        // 表示用のText（今日+1年 or selectedDate）
                        Text(
                            DateFormatter.displayFormat.string(
                                from: setExpiryDateOneYearLater
                                    ? Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
                                : viewModel.form.expiryDate
                            )
                        )

                        // Toggle（切り替えたら viewModel.form.expiryDate を更新）
                        Toggle(isOn: $setExpiryDateOneYearLater) {
                            if setExpiryDateOneYearLater {
                                Text("ON")
                            } else {
                                Text("消費期限を一年後に設定する")
                            }
                        }
                        .onChange(of: setExpiryDateOneYearLater) { newValue in
                            if newValue {
                                // ToggleがONになった → 今日から1年後をセット
                                viewModel.form.expiryDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
                            } else {
                                // ToggleがOFFになった → 選択された日付をセット
                                viewModel.form.expiryDate = selectedDate
                            }
                        }

                        // ToggleがOFFのときのみ、DatePicker表示＆変更時に更新
                        if !setExpiryDateOneYearLater {
                            DatePicker("消費期限", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .onChange(of: selectedDate) { newValue in
                                    viewModel.form.expiryDate = newValue
                                }
                        }
                    } header: {
                        Text("消費期限")
                            .font(.headline)
                    }

                    // MARK: 冷凍
                    Section {
                        Toggle(
                            viewModel.form.frozen ? "冷凍されている" : "冷凍されていない",
                            isOn: $viewModel.form.frozen
                        )
                    } header: {
                        Text("冷凍")
                            .font(.headline)
                    }
                    
                    //MARK: ↓Graphに必要な情報
                    Section {
                        Toggle(isOn: $isOnGraphInput) {
                            HStack {
                                if isOnGraphInput {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("以下全項目入力必須")
                                } else {
                                    Text("OFF")
                                }
                            }
                        }
                    } header: {
                        Text("金額推移グラフに必要な情報")
                            .font(.headline)
                    }
                    
                    // MARK: 購入日
                    if isOnGraphInput {
                        Section {
                            // 表示用のText（今日+1年 or selectedDate）
                            Text(
                                DateFormatter.displayFormat.string(
                                    from: setDateNotToday
                                    ?  selectedDate
                                    : viewModel.form.date
                                )
                            )
                            
                            // Toggle（切り替えたら viewModel.form.expiryDate を更新）
                            Toggle(isOn: $setDateNotToday) {
                                if setDateNotToday {
                                    Text("ON")
                                } else {
                                    Text("今日以外の日付に設定する")
                                }
                            }
                            .onChange(of: setDateNotToday) { newValue in
                                if newValue {
                                    // ToggleがONになった → 選択された日付をセット
                                    viewModel.form.date = selectedDate
                                    
                                } else {
                                    // ToggleがOFFになった → 今日に戻す
                                    viewModel.form.date = Date()
                                }
                            }
                            
                            // ToggleがOFFのときのみ、DatePicker表示＆変更時に更新
                            if setDateNotToday {
                                DatePicker("購入日", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                                    .onChange(of: selectedDate) { newValue in
                                        viewModel.form.date = newValue
                                    }
                            }
                        } header: {
                            Text("購入日")
                                .font(.headline)
                        }
                    }
                    
                    // MARK: 金額
                    if isOnGraphInput {
                        Section {
                            HStack {
                                TextField("金額", value: $viewModel.form.price, formatter: numberFormatter)
                                    .keyboardType(.decimalPad)
                                    .focused($isFocused)
                                Text("円")
                            }
                        } header: {
                            Text("金額")
                                .font(.headline)
                        }
                    }
                    
                    // MARK: 金額
                    if isOnGraphInput {
                        Section {
                            HStack {
                                TextField("金額", value: $viewModel.form.price, formatter: numberFormatter)
                                    .keyboardType(.decimalPad)
                                    .focused($isFocused)
                                Text("円")
                            }
                        } header: {
                            Text("金額")
                                .font(.headline)
                        }
                    }
                    
                    // MARK: 購入場所
                    if isOnGraphInput {
                        Section {
                            TextField("ヨークベニマル会津大学店", text: $viewModel.form.location)
                                .focused($isFocused)
                        } header: {
                            Text("購入場所")
                                .font(.headline)
                        }
                    }
                    
                    // MARK: 食材追加ボタン
                    Section {
                        Button("追加") {
                            if  isOnGraphInput {
                                viewModel.addInventoryAndPurchaseHistory()
                            } else if !isOnGraphInput{
                                viewModel.addInventory()
                            }
                        }
                        .alert("追加失敗", isPresented: $viewModel.isMutationError) {
                            // ダイアログ内で行うアクション処理...
                            Button("閉じる", role: .cancel) {
                                viewModel.isMutationError = false
                            }
                        } message: {
                            // アラートのメッセージ...
                            Text("入力を確認してください")
                        }
                    }
                    
                    Section {
                        Text(viewModel.form.errorMessage ?? "エラーないよ")
                    }
                }
                .foregroundColor(.black)
                .tint(.orange)
                .gesture(self.gesture)
                .navigationDestination(for: Category.self) { category in
                    CategorySelectionView(
                        path: $path,
                        viewModel: viewModel,
                        category: category
                    )
                }
            }
            .onAppear {
                viewModel.fetchCategoriesAndIngredients()
            }
        }
    }
}

#Preview {
    InputInventoryPage()
}
