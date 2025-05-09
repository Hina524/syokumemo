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
    @State private var onFraction = false
    @State private var onInputDate = false
    @State private var selectedDate = Date()
    
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
                            if onFraction {
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
                        Toggle(isOn: $onFraction){
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
                        Toggle(isOn: $onInputDate) {
                            if onInputDate {
                                Text(DateFormatter.displayFormat.string(from: selectedDate))
                            } else {
                                Text("OFF")
                            }
                        }
                        .onChange(of: onInputDate) { isOn in
                            viewModel.form.expiryDate = isOn ? selectedDate : .none
                        }
                        
                        if onInputDate {
                            DatePicker("消費期限", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .onChange(of: selectedDate) { newValue in
                                    if onInputDate {
                                        viewModel.form.expiryDate = selectedDate
                                    }
                                }
                        }
                    } header: {
                        Text("消費期限")
                            .font(.headline)
                    }
                    // MARK: 金額
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
                    
                    // MARK: 購入場所
                    Section {
                        TextField("ヨークベニマル会津大学店", text: $viewModel.form.location)
                            .focused($isFocused)
                    } header: {
                        Text("購入場所")
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
                    
                    Section {
                        Text(viewModel.form.errorMessage ?? "エラーないよ")
                    }
                }
                .foregroundColor(.brown)
                .tint(.pink)
                .gesture(self.gesture)
                .navigationDestination(for: Category.self) { category in
                    CategorySelectionView(
                        path: $path,
                        viewModel: viewModel,
                        category: category
                    )
                }
                
                // MARK: 食材追加ボタン
                Button("追加") {
                    viewModel.addInventory()
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
                
                Text("*").foregroundColor(.red) + Text("がついている項目は必ず入力してください。")
                
                
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
