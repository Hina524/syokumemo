// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateIngredientMutation: GraphQLMutation {
  public static let operationName: String = "CreateIngredient"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateIngredient($input: NewIngredient!) { addIngredient(input: $input) { __typename id name category { __typename id name } } }"#
    ))

  public var input: NewIngredient

  public init(input: NewIngredient) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("addIngredient", AddIngredient.self, arguments: ["input": .variable("input")]),
    ] }

    public var addIngredient: AddIngredient { __data["addIngredient"] }

    /// AddIngredient
    ///
    /// Parent Type: `Ingredient`
    public struct AddIngredient: ShokumemoAPI.SelectionSet {
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

      /// AddIngredient.Category
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
