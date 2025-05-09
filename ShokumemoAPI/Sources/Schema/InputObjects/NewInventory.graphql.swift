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
    expiryDate: String,
    frozen: Bool
  ) {
    __data = InputDict([
      "ingredientId": ingredientId,
      "quantity": quantity,
      "unit": unit,
      "expiryDate": expiryDate,
      "frozen": frozen
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

  public var expiryDate: String {
    get { __data["expiryDate"] }
    set { __data["expiryDate"] = newValue }
  }

  public var frozen: Bool {
    get { __data["frozen"] }
    set { __data["frozen"] = newValue }
  }
}
