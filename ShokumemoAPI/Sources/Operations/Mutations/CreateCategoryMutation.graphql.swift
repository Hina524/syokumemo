// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateCategoryMutation: GraphQLMutation {
  public static let operationName: String = "CreateCategory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateCategory($input: NewCategory!) { createCategory(input: $input) { __typename id name colorCode } }"#
    ))

  public var input: NewCategory

  public init(input: NewCategory) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createCategory", CreateCategory.self, arguments: ["input": .variable("input")]),
    ] }

    public var createCategory: CreateCategory { __data["createCategory"] }

    /// CreateCategory
    ///
    /// Parent Type: `Category`
    public struct CreateCategory: ShokumemoAPI.SelectionSet {
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
