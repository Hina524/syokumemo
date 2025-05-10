// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetIngredientsAndParchaseHistoryQuery: GraphQLQuery {
  public static let operationName: String = "GetIngredientsAndParchaseHistory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetIngredientsAndParchaseHistory { ingredients { __typename id name purchaseHistory { __typename id date location price } } }"#
    ))

  public init() {}

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("ingredients", [Ingredient].self),
    ] }

    public var ingredients: [Ingredient] { __data["ingredients"] }

    /// Ingredient
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
        .field("purchaseHistory", [PurchaseHistory].self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var purchaseHistory: [PurchaseHistory] { __data["purchaseHistory"] }

      /// Ingredient.PurchaseHistory
      ///
      /// Parent Type: `PurchaseHistory`
      public struct PurchaseHistory: ShokumemoAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.PurchaseHistory }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ShokumemoAPI.ID.self),
          .field("date", String.self),
          .field("location", String.self),
          .field("price", Double.self),
        ] }

        public var id: ShokumemoAPI.ID { __data["id"] }
        public var date: String { __data["date"] }
        public var location: String { __data["location"] }
        public var price: Double { __data["price"] }
      }
    }
  }
}
