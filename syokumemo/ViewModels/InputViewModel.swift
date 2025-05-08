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
    @Published var ingredientId: Int?
    @Published var categoryId: Int?
    @Published var numerator: Int?
    @Published var denominator: Int?
    @Published var unit: String?
    @Published var expiryDate: String = ""
    @Published var frozen: Bool = false
    @Published var location: String = ""
    @Published var price: Double = 0.0
    
    // GetCategoriesAndIngredients
    @Published var categories: [GetCategoriesAndIngredientsQuery.Data.Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func addInventory() {
        // Apolloの生成した型を使う
        guard let numerator = numerator,
              let denominator = denominator,
              let ingredientId = ingredientId,
              let unit = unit else { return }
        
        let fractionInput = FractionInput(
            numerator: numerator,
            denominator: denominator
        )
        
        let input = NewInventory(
            ingredientId: String(ingredientId), // IDはGraphQLID型に変換
            quantity: fractionInput,
            unit: unit,
            expiryDate: expiryDate == "" ? .null : .init(stringLiteral: expiryDate),
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
