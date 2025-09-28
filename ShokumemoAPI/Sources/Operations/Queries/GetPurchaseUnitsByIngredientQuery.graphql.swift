// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetPurchaseUnitsByIngredientQuery: GraphQLQuery {
  public static let operationName: String = "GetPurchaseUnitsByIngredient"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetPurchaseUnitsByIngredient($ingredientId: ID!) { purchaseUnitsByIngredient(ingredientId: $ingredientId) { __typename id name ingredient { __typename id name } } }"#
    ))

  public var ingredientId: ID

  public init(ingredientId: ID) {
    self.ingredientId = ingredientId
  }

  public var __variables: Variables? { ["ingredientId": ingredientId] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("purchaseUnitsByIngredient", [PurchaseUnitsByIngredient].self, arguments: ["ingredientId": .variable("ingredientId")]),
    ] }

    public var purchaseUnitsByIngredient: [PurchaseUnitsByIngredient] { __data["purchaseUnitsByIngredient"] }

    /// PurchaseUnitsByIngredient
    ///
    /// Parent Type: `PurchaseUnit`
    public struct PurchaseUnitsByIngredient: ShokumemoAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.PurchaseUnit }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", ShokumemoAPI.ID.self),
        .field("name", String.self),
        .field("ingredient", Ingredient.self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var ingredient: Ingredient { __data["ingredient"] }

      /// PurchaseUnitsByIngredient.Ingredient
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
