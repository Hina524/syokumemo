//
//  InventoryInputViewModel.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import SwiftUI
import Apollo
import ShokumemoAPI

class InputViewModel: ObservableObject {
    // addInventory
    @Published var ingredientName: String?
    @Published var ingredientId: String = ""
    @Published var categoryId: Int?
    @Published var numerator: Int = 1
    @Published var denominator: Int?
    @Published var unit: String = ""
    @Published var expiryDate: Date? // デフォルトは現在日付

    @Published var frozen: Bool = false
    @Published var location: String = ""
    @Published var price: Double = 0.0
    
    // GetCategoriesAndIngredients
    @Published var categories: [GetCategoriesAndIngredientsQuery.Data.Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // カテゴリから食材を選んだ時に使うものたち
    @Published var selectedIngredientName: String?
    
    func addInventory() {
        
        let fractionInput = FractionInput(
            numerator: numerator,
            denominator: denominator == .none ? 1 : .init(integerLiteral: denominator!)
        )

        let input = NewInventory(
            ingredientId: ingredientId, // IDはGraphQLID型に変換
            quantity: fractionInput,
            unit: unit,
            expiryDate: expiryDate == .none ? .null : .init(stringLiteral: DateFormatter.apiFormat.string(from: expiryDate!)),
            frozen: frozen == false ? .null : .init(booleanLiteral: frozen),
            location: location == "" ? .null : .init(stringLiteral: location),
            price: price == 0.0 ? .null : .init(floatLiteral: price)
        )
        
        let mutation = CreateInventoryMutation(input: input)
        
        isLoading = true
        Network.shared.apollo.perform(mutation: mutation) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let _ = graphQLResult.data?.addInventory {
                        //                        completion(true)
                    } else if let errors = graphQLResult.errors {
                        self?.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        //                        completion(false)
                    }
                case .failure(let error):
                    self?.errorMessage = "登録に失敗しました: \(error.localizedDescription)"
                    //                    completion(false)
                }
            }
        }
    }
    
    
    
    func fetchCategoriesAndIngredients() {
        isLoading = true
        
        Network.shared.apollo.fetch(query: GetCategoriesAndIngredientsQuery()) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data {
                        self?.categories = data.categories
                    } else if let errors = graphQLResult.errors {
                        self?.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                    }
                case .failure(let error):
                    self?.errorMessage = "データ取得に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }
}
