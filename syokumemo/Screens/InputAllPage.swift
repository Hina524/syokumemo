//
//  InputInvestoryPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import ShokumemoAPI

typealias Category = GetCategoriesAndIngredientsQuery.Data.Category
typealias Ingredient = GetCategoriesAndIngredientsQuery.Data.Category.Ingredient

enum AppNavigationPath: Hashable {
    case category([Category])
    case ingredients(Category)
    case purchaseHistoryPage(inventoryData: InventoryDataForPurchaseHistory)
    case combinedInput
    case inventoryOnly
    case purchaseHistoryOnly
    case locations
    case purchaseUnits
}

let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    formatter.zeroSymbol  = ""
    return formatter
}()

struct InputAllPage: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = InputInventoryViewModel()
    @StateObject var purchaseHistoryViewModel = InputPurchaseHistoryViewModel()
    @State private var selectedIngredient: GetCategoriesAndIngredientsQuery.Data.Category.Ingredient? = nil
    @State private var showCategorySelection = false
    @State private var path = [AppNavigationPath]()
    @State private var isOnFractionInput = false
    @State private var selectedDate = Date()
    @State private var setExpiryDateOneYearLater = false
    @State private var setDateNotToday: Bool = false
    @State private var purchaseDate = Date()
    
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
            // 戻るボタンとタイトル（カテゴリ選択時は非表示）
            if path.isEmpty {
                ZStack {
                    HStack {
                        Button(action: {
                            appState.inputMode = .selection
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("戻る")
                                    .font(.body)
                            }
                            .foregroundColor(.accentColor)
                        }
                        Spacer()
                    }
                    Text("在庫と購入履歴を同時に入力")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding()
            }
            
            NavigationStack(path: $path) {
                Form {
                    // MARK: 食材選択
                    Section {
                        NavigationLink(value: AppNavigationPath.category(viewModel.categories)) {
                            if let name = viewModel.form.selectedIngredientName {
                                Text(name)
                            } else {
                                Text("未選択")
                            }
                        }
                    } header: {
                        Text("食材")
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
                        Text("数量")
                            .font(.headline)
                    } footer: {
                        Text("3個や5日分などの表記がおすすめ！もちろん200gなどでも！")
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
                    
                    // MARK: 購入日
                    Section {
                        Text(
                            DateFormatter.displayFormat.string(
                                from: setDateNotToday
                                ? purchaseDate
                                : purchaseHistoryViewModel.form.date
                            )
                        )
                        
                        Toggle(isOn: $setDateNotToday) {
                            if setDateNotToday {
                                Text("ON")
                            } else {
                                Text("今日以外の日付に設定する")
                            }
                        }
                        .onChange(of: setDateNotToday) { newValue in
                            if newValue {
                                purchaseHistoryViewModel.form.date = purchaseDate
                            } else {
                                purchaseHistoryViewModel.form.date = Date()
                            }
                        }
                        
                        if setDateNotToday {
                            DatePicker("購入日", selection: $purchaseDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .onChange(of: purchaseDate) { newValue in
                                    purchaseHistoryViewModel.form.date = newValue
                                }
                        }
                    } header: {
                        Text("購入日")
                            .font(.headline)
                    }
                    
                    // MARK: 金額
                    Section {
                        HStack {
                            TextField("金額", value: $purchaseHistoryViewModel.form.price, formatter: numberFormatter)
                                .keyboardType(.decimalPad)
                                .focused($isFocused)
                            Text("円")
                        }
                    } header: {
                        Text("金額")
                            .font(.headline)
                    }
                    
                    // MARK: 購入単位
                    Section {
                        Button(action: {
                            if viewModel.form.ingredientId.isEmpty {
                                purchaseHistoryViewModel.form.errorMessage = "先に食材を選択してください"
                                purchaseHistoryViewModel.isMutationError = true
                            } else {
                                purchaseHistoryViewModel.form.ingredientId = viewModel.form.ingredientId
                                if purchaseHistoryViewModel.purchaseUnits.isEmpty {
                                    purchaseHistoryViewModel.fetchPurchaseUnitsByIngredient(ingredientId: viewModel.form.ingredientId)
                                }
                                path.append(.purchaseUnits)
                            }
                        }) {
                            HStack {
                                if let name = purchaseHistoryViewModel.selectedPurchaseUnitName {
                                    Text(name)
                                } else {
                                    Text("未選択")
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.black)
                    } header: {
                        Text("購入単位")
                            .font(.headline)
                    }
                    
                    // MARK: 購入場所
                    Section {
                        NavigationLink(value: AppNavigationPath.locations) {
                            if let name = purchaseHistoryViewModel.selectedLocationName {
                                Text(name)
                            } else {
                                Text("未選択")
                            }
                        }
                    } header: {
                        Text("購入場所")
                            .font(.headline)
                    }
                    
                    
                    // MARK: 食材追加ボタン
                    Section {
                        Button("追加する") {
                            purchaseHistoryViewModel.syncFromInventoryViewModel(viewModel)
                            purchaseHistoryViewModel.addInventoryAndPurchaseHistory(
                                numerator: viewModel.form.numerator,
                                denominator: viewModel.form.denominator,
                                unit: viewModel.form.unit,
                                expiryDate: viewModel.form.expiryDate,
                                frozen: viewModel.form.frozen
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .alert("追加失敗", isPresented: $purchaseHistoryViewModel.isMutationError) {
                            Button("閉じる", role: .cancel) {
                                purchaseHistoryViewModel.isMutationError = false
                            }
                        } message: {
                            Text(purchaseHistoryViewModel.form.errorMessage ?? "入力を確認してください")
                        }
                        .alert("追加完了", isPresented: $purchaseHistoryViewModel.purchaseDidSucceed) {
                            Button("OK", role: .cancel) {
                                viewModel.resetForm()
                                purchaseHistoryViewModel.resetForm()
                                appState.inputMode = .selection
                            }
                        } message: {
                            Text("在庫と購入履歴が追加されました")
                        }
                    }
                    
                    Section {
                        Text(viewModel.form.errorMessage ?? "エラーないよ")
                    }
                }
                .tint(.orange)
                //                .gesture(self.gesture)
                .onAppear {
                    viewModel.fetchCategoriesAndIngredients()
                    purchaseHistoryViewModel.fetchLocations()
                }
                .onChange(of: viewModel.form.ingredientId) { newIngredientId in
                    purchaseHistoryViewModel.form.ingredientId = newIngredientId
                    if !newIngredientId.isEmpty {
                        purchaseHistoryViewModel.fetchPurchaseUnitsByIngredient(ingredientId: newIngredientId)
                    }
                }
                .navigationDestination(for: AppNavigationPath.self) { appNavigationPath in // (4) 遷移先を設定
                    switch appNavigationPath {
                    case .category(let categories):
                        SelectCategoryPage(
                            path: $path, viewModel: viewModel
                        )
                    case .ingredients(let category):
                        SelectIngredientPage(path: $path, viewModel: viewModel, category: category)
                    case .locations:
                        SelectLocationPage(path: $path, viewModel: purchaseHistoryViewModel)
                    case .purchaseUnits:
                        SelectPurchaseUnitPage(path: $path, viewModel: purchaseHistoryViewModel)
                    case .combinedInput:
                        InputAllPage()
                    case .inventoryOnly:
                        Text("在庫のみ入力画面（未実装）")
                    case .purchaseHistoryOnly:
                        Text("購入履歴のみ入力画面（未実装）")
                    case .purchaseHistoryPage:
                        EmptyView()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    InputAllPage()
}
