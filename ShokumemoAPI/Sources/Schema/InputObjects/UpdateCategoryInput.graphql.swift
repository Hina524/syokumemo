// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct UpdateCategoryInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    name: String,
    colorCode: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "name": name,
      "colorCode": colorCode
    ])
  }

  public var name: String {
    get { __data["name"] }
    set { __data["name"] = newValue }
  }

  public var colorCode: GraphQLNullable<String> {
    get { __data["colorCode"] }
    set { __data["colorCode"] = newValue }
  }
}
