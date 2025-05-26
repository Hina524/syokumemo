//
//  InputPurchaseHistoryPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/22.
//

import SwiftUI
import ShokumemoAPI

//let numberFormatter: NumberFormatter = {
//    let formatter = NumberFormatter()
//    formatter.numberStyle = .none
//    formatter.zeroSymbol  = ""
//    return formatter
//}()

struct InputPurchaseHistoryPage: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var isOnFractionInput = false
    @State private var isOnInputExpiryDate = false
    @State private var isOnGraphInput = false
    @State private var selectedDate = Date()
    @State private var setExpiryDateOneYearLater = false
    @State private var setDateNotToday: Bool = false
    @FocusState private var isFocused: Bool
    @StateObject var viewModel: InputPurchaseHistoryViewModel
    
    let inventoryData: InventoryDataForPurchaseHistory
    //    @StateObject var viewModel = InputPurchaseHistoryViewModel()
    
    init(inventoryData: InventoryDataForPurchaseHistory) {
        self.inventoryData = inventoryData
        self._viewModel = StateObject(wrappedValue: InputPurchaseHistoryViewModel(
            ingredientId: inventoryData.ingredientId,
            numerator: inventoryData.numerator,
            denominator: inventoryData.denominator ?? 1,
            unit: inventoryData.unit
        ))
    }
    
    var gesture: some Gesture {
        DragGesture()
            .onChanged{ value in
                if value.translation.height != 0 {
                    self.isFocused = false
                }
            }
    }
    
    var body: some View {
//        viewModel.form.ingredientId = inventoryData.ingredientId
        VStack {
            Form {
                // MARK: 在庫情報
                Section {
                    VStack {
                        HStack {
                            Text("食材名")
                                .font(.headline)
                            Spacer()
                            Text(inventoryData.ingredientName ?? "ナンモナイヨ")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .bold()
                        }
                        .padding(.bottom, 5)
                        HStack {
                            Text("数量")
                                .font(.headline)
                            Spacer()
                            Text("\(inventoryData.numerator)")
                            Text(" / ")
                            Text("\(inventoryData.denominator ?? 0)")
                            Text(" " + inventoryData.unit)
                        }
                    }
                }
                
                // MARK: 購入日
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
                
                
                // MARK: 食材追加ボタン
                Section {
                    Button("追加") {
                        viewModel.addPurchaseHistory()
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
            .navigationBarBackButtonHidden(true)
        }
        .onChange(of: viewModel.purchaseDidSucceed) { didSucceed in // <--- これを追加！
                    if didSucceed {
                        dismiss() // 成功フラグがtrueになったら画面を閉じる
                        // viewModel.purchaseDidSucceed = false // (任意)フラグをリセットする場合
                    }
                }
    }
}
