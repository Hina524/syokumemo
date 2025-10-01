// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InventoryFilter: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    ingredientId: GraphQLNullable<ID> = nil,
    status: GraphQLNullable<[GraphQLEnum<InventoryStatus>]> = nil
  ) {
    __data = InputDict([
      "ingredientId": ingredientId,
      "status": status
    ])
  }

  public var ingredientId: GraphQLNullable<ID> {
    get { __data["ingredientId"] }
    set { __data["ingredientId"] = newValue }
  }

  public var status: GraphQLNullable<[GraphQLEnum<InventoryStatus>]> {
    get { __data["status"] }
    set { __data["status"] = newValue }
  }
}
