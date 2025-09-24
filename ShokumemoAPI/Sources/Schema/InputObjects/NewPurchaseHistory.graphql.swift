// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct NewPurchaseHistory: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    ingredientId: ID,
    date: String,
    locationId: ID,
    purchaseUnitId: ID,
    price: Int
  ) {
    __data = InputDict([
      "ingredientId": ingredientId,
      "date": date,
      "locationId": locationId,
      "purchaseUnitId": purchaseUnitId,
      "price": price
    ])
  }

  public var ingredientId: ID {
    get { __data["ingredientId"] }
    set { __data["ingredientId"] = newValue }
  }

  public var date: String {
    get { __data["date"] }
    set { __data["date"] = newValue }
  }

  public var locationId: ID {
    get { __data["locationId"] }
    set { __data["locationId"] = newValue }
  }

  public var purchaseUnitId: ID {
    get { __data["purchaseUnitId"] }
    set { __data["purchaseUnitId"] = newValue }
  }

  public var price: Int {
    get { __data["price"] }
    set { __data["price"] = newValue }
  }
}
