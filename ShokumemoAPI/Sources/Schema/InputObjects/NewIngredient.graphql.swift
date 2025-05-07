// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct NewIngredient: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    name: String,
    categoryId: ID
  ) {
    __data = InputDict([
      "name": name,
      "categoryId": categoryId
    ])
  }

  public var name: String {
    get { __data["name"] }
    set { __data["name"] = newValue }
  }

  public var categoryId: ID {
    get { __data["categoryId"] }
    set { __data["categoryId"] = newValue }
  }
}
