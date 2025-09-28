// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct NewPurchaseUnit: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    ingredientId: ID,
    name: String
  ) {
    __data = InputDict([
      "ingredientId": ingredientId,
      "name": name
    ])
  }

  public var ingredientId: ID {
    get { __data["ingredientId"] }
    set { __data["ingredientId"] = newValue }
  }

  public var name: String {
    get { __data["name"] }
    set { __data["name"] = newValue }
  }
}
