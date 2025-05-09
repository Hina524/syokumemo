// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct UpdateInventory: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    quantity: GraphQLNullable<FractionInput> = nil,
    unit: GraphQLNullable<String> = nil,
    expiryDate: GraphQLNullable<String> = nil,
    frozen: GraphQLNullable<Bool> = nil
  ) {
    __data = InputDict([
      "quantity": quantity,
      "unit": unit,
      "expiryDate": expiryDate,
      "frozen": frozen
    ])
  }

  public var quantity: GraphQLNullable<FractionInput> {
    get { __data["quantity"] }
    set { __data["quantity"] = newValue }
  }

  public var unit: GraphQLNullable<String> {
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
}
