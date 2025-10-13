// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct UpdatePurchaseHistory: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    date: GraphQLNullable<String> = nil,
    locationId: GraphQLNullable<ID> = nil,
    purchaseUnitId: GraphQLNullable<ID> = nil,
    price: GraphQLNullable<Int> = nil
  ) {
    __data = InputDict([
      "date": date,
      "locationId": locationId,
      "purchaseUnitId": purchaseUnitId,
      "price": price
    ])
  }

  public var date: GraphQLNullable<String> {
    get { __data["date"] }
    set { __data["date"] = newValue }
  }

  public var locationId: GraphQLNullable<ID> {
    get { __data["locationId"] }
    set { __data["locationId"] = newValue }
  }

  public var purchaseUnitId: GraphQLNullable<ID> {
    get { __data["purchaseUnitId"] }
    set { __data["purchaseUnitId"] = newValue }
  }

  public var price: GraphQLNullable<Int> {
    get { __data["price"] }
    set { __data["price"] = newValue }
  }
}
