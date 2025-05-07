// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct NewInventory: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    ingredientId: ID,
    quantity: FractionInput,
    unit: String,
    expiryDate: GraphQLNullable<String> = nil,
    frozen: GraphQLNullable<Bool> = nil,
    location: GraphQLNullable<String> = nil,
    price: GraphQLNullable<Double> = nil
  ) {
    __data = InputDict([
      "ingredientId": ingredientId,
      "quantity": quantity,
      "unit": unit,
      "expiryDate": expiryDate,
      "frozen": frozen,
      "location": location,
      "price": price
    ])
  }

  public var ingredientId: ID {
    get { __data["ingredientId"] }
    set { __data["ingredientId"] = newValue }
  }

  public var quantity: FractionInput {
    get { __data["quantity"] }
    set { __data["quantity"] = newValue }
  }

  public var unit: String {
    get { __data["unit"] }
    set { __data["unit"] = newValue }
  }

  public var expiryDate: GraphQLNullable<String> {
    get { __data["expiryDate"] }
    set { __data["expiryDate"] = newValue }
  }

  public var frozen: GraphQLNullable<Bool> {
    get { __data["frozen"] }
    set { __data["frozen"] = newValue }
  }

  public var location: GraphQLNullable<String> {
    get { __data["location"] }
    set { __data["location"] = newValue }
  }

  public var price: GraphQLNullable<Double> {
    get { __data["price"] }
    set { __data["price"] = newValue }
  }
}
