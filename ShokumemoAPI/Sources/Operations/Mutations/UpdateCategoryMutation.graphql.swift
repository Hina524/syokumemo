// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateCategoryMutation: GraphQLMutation {
  public static let operationName: String = "UpdateCategory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateCategory($id: ID!, $input: UpdateCategoryInput!) { updateCategory(id: $id, input: $input) { __typename id name colorCode } }"#
    ))

  public var id: ID
  public var input: UpdateCategoryInput

  public init(
    id: ID,
    input: UpdateCategoryInput
  ) {
    self.id = id
    self.input = input
  }

  public var __variables: Variables? { [
    "id": id,
    "input": input
  ] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateCategory", UpdateCategory.self, arguments: [
        "id": .variable("id"),
        "input": .variable("input")
      ]),
    ] }

    public var updateCategory: UpdateCategory { __data["updateCategory"] }

    /// UpdateCategory
    ///
    /// Parent Type: `Category`
    public struct UpdateCategory: ShokumemoAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Category }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", ShokumemoAPI.ID.self),
        .field("name", String.self),
        .field("colorCode", String.self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var colorCode: String { __data["colorCode"] }
    }
  }
}
