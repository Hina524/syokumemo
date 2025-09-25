//
//  InputInventoryOnlyPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/09/24.
//

import SwiftUI
import ShokumemoAPI

struct InputInventoryOnlyPage: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = InputInventoryViewModel()
    @State private var selectedIngredient: GetCategoriesAndIngredientsQuery.Data.Category.Ingredient? = nil
    @State private var showCategorySelection = false
    @State private var path = [AppNavigationPath]()
    @State private var isOnFractionInput = false
    @State private var selectedDate = Date()
    @State private var setExpiryDateOneYearLater = false
    
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
                            .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    Text("在庫のみ入力")
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
                    
                    // MARK: 食材追加ボタン
                    Section {
                        Button("追加") {
                            viewModel.addInventory()
                        }
                        .alert("追加失敗", isPresented: $viewModel.isMutationError) {
                            Button("閉じる", role: .cancel) {
                                viewModel.isMutationError = false
                            }
                        } message: {
                            Text("入力を確認してください")
                        }
                        .alert("追加完了", isPresented: $viewModel.isShowSheet) {
                            Button("OK", role: .cancel) {
                                viewModel.resetForm()
                                appState.inputMode = .selection
                            }
                        } message: {
                            Text("在庫が追加されました")
                        }
                    }
                    
                    Section {
                        Text(viewModel.form.errorMessage ?? "エラーないよ")
                    }
                }
                .foregroundColor(.black)
                .tint(.orange)
                .onAppear {
                    viewModel.fetchCategoriesAndIngredients()
                }
                .navigationDestination(for: AppNavigationPath.self) { appNavigationPath in
                    switch appNavigationPath {
                    case .category(let categories):
                        CategorySelectionPage(
                            categories: categories, path: $path, viewModel: viewModel
                        )
                    case .ingredients(let category):
                        IngredientSelectionPage(path: $path, viewModel: viewModel, category: category)
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
    InputInventoryOnlyPage()
        .environmentObject(AppState())
}