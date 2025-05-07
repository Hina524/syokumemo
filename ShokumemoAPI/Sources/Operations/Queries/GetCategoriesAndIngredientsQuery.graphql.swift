// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetCategoriesAndIngredientsQuery: GraphQLQuery {
  public static let operationName: String = "GetCategoriesAndIngredients"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetCategoriesAndIngredients { categories { __typename id name ingredients { __typename id name } } }"#
    ))

  public init() {}

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("categories", [Category].self),
    ] }

    public var categories: [Category] { __data["categories"] }

    /// Category
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
        .field("ingredients", [Ingredient].self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var ingredients: [Ingredient] { __data["ingredients"] }

      /// Category.Ingredient
      ///
      /// Parent Type: `Ingredient`
      public struct Ingredient: ShokumemoAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Ingredient }
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
