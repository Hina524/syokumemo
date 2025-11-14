//
//  InputPurchaseHistoryOnlyPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/09/24.
//

import SwiftUI
import ShokumemoAPI

struct InputPurchaseHistoryPage: View {
    @EnvironmentObject var appState: AppState
    @StateObject var inventoryViewModel = InputInventoryViewModel() // 食材選択用
    @StateObject var purchaseHistoryViewModel = InputPurchaseHistoryViewModel() // 購入履歴登録用
    @State private var path = [AppNavigationPath]()
    @State private var setDateNotToday: Bool = false
    @State private var selectedDate = Date()
    @State private var isOnFractionInput = false
    @State private var showPurchaseUnitHelp = false
    @State private var showPurchaseUnitError = false
    @AppStorage("hasShownPurchaseUnitHelp") private var hasShownPurchaseUnitHelp = false
    
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
                    Text("購入履歴のみ入力")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding()
            }
            
            NavigationStack(path: $path) {
                Form {
                    // MARK: 食材選択
                    Section {
                        NavigationLink(value: AppNavigationPath.category(inventoryViewModel.categories)) {
                            if let name = inventoryViewModel.form.selectedIngredientName {
                                Text(name)
                            } else {
                                Text("未選択")
                            }
                        }
                    } header: {
                        Text("食材")
                            .font(.headline)
                    }
                    
                    // MARK: 購入日
                    Section {
                        Text(
                            DateFormatter.displayFormat.string(
                                from: setDateNotToday
                                ? selectedDate
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
                                purchaseHistoryViewModel.form.date = selectedDate
                            } else {
                                purchaseHistoryViewModel.form.date = Date()
                            }
                        }
                        
                        if setDateNotToday {
                            DatePicker("購入日", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .onChange(of: selectedDate) { newValue in
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
                            if inventoryViewModel.form.ingredientId.isEmpty {
                                showPurchaseUnitError = true
                            } else {
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
                        .foregroundColor(.primary)
                    } header: {
                        HStack(spacing: 4) {
                            Text("購入単位")
                                .font(.headline)
                            Button(action: {
                                showPurchaseUnitHelp = true
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.accentColor)
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                            .popover(isPresented: $showPurchaseUnitHelp) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("購入単位の入力方法")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("**例1:** 3個入りのトマトを324円で購入")
                                            .font(.subheadline)
                                        Text("→ 金額: 324, 購入単位: 3個入り")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("**例2:** 100g 76円の鶏胸肉を購入")
                                            .font(.subheadline)
                                        Text("→ 金額: 76, 購入単位: 100g")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .presentationCompactAdaptation(.popover)
                            }
                        }
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
                    
                    
                    // MARK: 追加ボタン
                    Section {
                        Button("追加する") {
                            purchaseHistoryViewModel.syncFromInventoryViewModel(inventoryViewModel)
                            purchaseHistoryViewModel.addPurchaseHistory()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .alert("先に食材を選択してください", isPresented: $showPurchaseUnitError) {
                            Button("閉じる", role: .cancel) { }
                        }
                        .alert("追加失敗", isPresented: $purchaseHistoryViewModel.isMutationError) {
                            Button("閉じる", role: .cancel) {
                                purchaseHistoryViewModel.isMutationError = false
                            }
                        } message: {
                            Text("入力を確認してください")
                        }
                        .alert("追加完了", isPresented: $purchaseHistoryViewModel.purchaseDidSucceed) {
                            Button("OK", role: .cancel) {
                                inventoryViewModel.resetForm()
                                purchaseHistoryViewModel.resetForm()
                                appState.inputMode = .selection
                            }
                        } message: {
                            Text("購入履歴が追加されました")
                        }
                    }
                    
                    Section {
                        Text(purchaseHistoryViewModel.form.errorMessage ?? "エラーないよ")
                    }
                }
                .tint(.orange)
                .gesture(self.gesture)
                .onAppear {
                    inventoryViewModel.fetchCategoriesAndIngredients()
                    purchaseHistoryViewModel.fetchLocations()
                    
                    if !hasShownPurchaseUnitHelp {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showPurchaseUnitHelp = true
                            hasShownPurchaseUnitHelp = true
                        }
                    }
                }
                .onChange(of: inventoryViewModel.form.ingredientId) { newIngredientId in
                    purchaseHistoryViewModel.form.ingredientId = newIngredientId
                    if !newIngredientId.isEmpty {
                        purchaseHistoryViewModel.fetchPurchaseUnitsByIngredient(ingredientId: newIngredientId)
                    }
                }
                .navigationDestination(for: AppNavigationPath.self) { appNavigationPath in
                    switch appNavigationPath {
                    case .category(let categories):
                        SelectCategoryPage(
                            path: $path, viewModel: inventoryViewModel
                        )
                    case .ingredients(let category):
                        SelectIngredientPage(path: $path, viewModel: inventoryViewModel, category: category)
                    case .locations:
                        SelectLocationPage(path: $path, viewModel: purchaseHistoryViewModel)
                    case .purchaseUnits:
                        SelectPurchaseUnitPage(path: $path, viewModel: purchaseHistoryViewModel)
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    InputPurchaseHistoryPage()
        .environmentObject(AppState())
}
