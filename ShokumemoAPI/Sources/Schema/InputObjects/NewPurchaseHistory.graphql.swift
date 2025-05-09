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
    quantity: FractionInput,
    unit: String,
    date: GraphQLNullable<String> = nil,
    location: String,
    price: Double
  ) {
    __data = InputDict([
      "ingredientId": ingredientId,
      "quantity": quantity,
      "unit": unit,
      "date": date,
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

  public var date: GraphQLNullable<String> {
    get { __data["date"] }
    set { __data["date"] = newValue }
  }

  public var location: String {
    get { __data["location"] }
    set { __data["location"] = newValue }
  }

  public var price: Double {
    get { __data["price"] }
    set { __data["price"] = newValue }
  }
}
