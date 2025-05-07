// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct FractionInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    numerator: Int,
    denominator: Int
  ) {
    __data = InputDict([
      "numerator": numerator,
      "denominator": denominator
    ])
  }

  public var numerator: Int {
    get { __data["numerator"] }
    set { __data["numerator"] = newValue }
  }

  public var denominator: Int {
    get { __data["denominator"] }
    set { __data["denominator"] = newValue }
  }
}
