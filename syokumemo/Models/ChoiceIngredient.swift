//
//  ChoiceIngredient.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/08.
//

import ShokumemoAPI

typealias Ingredient = GetCategoriesAndIngredientsQuery.Data.Category.Ingredient
typealias Category = GetCategoriesAndIngredientsQuery.Data.Category

enum ChoiceIngredient: Hashable {
    case category(Category)
    case ingredient(Ingredient)
}
