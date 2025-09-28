// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateIngredientMutation: GraphQLMutation {
  public static let operationName: String = "UpdateIngredient"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateIngredient($id: ID!, $input: UpdateIngredientInput!) { updateIngredient(id: $id, input: $input) { __typename id name category { __typename id name } } }"#
    ))

  public var id: ID
  public var input: UpdateIngredientInput

  public init(
    id: ID,
    input: UpdateIngredientInput
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
      .field("updateIngredient", UpdateIngredient.self, arguments: [
        "id": .variable("id"),
        "input": .variable("input")
      ]),
    ] }

    public var updateIngredient: UpdateIngredient { __data["updateIngredient"] }

    /// UpdateIngredient
    ///
    /// Parent Type: `Ingredient`
    public struct UpdateIngredient: ShokumemoAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Ingredient }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", ShokumemoAPI.ID.self),
        .field("name", String.self),
        .field("category", Category.self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var category: Category { __data["category"] }

      /// UpdateIngredient.Category
      ///
      /// Parent Type: `Category`
      public struct Category: ShokumemoAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Category }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ShokumemoAPI.ID.self),
          .field("name", String.self),
        ] }

        public var id: ShokumemoAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
      }
    }
  }
}
