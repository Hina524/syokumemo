// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetIngredientsAndParchaseHistoryQuery: GraphQLQuery {
  public static let operationName: String = "GetIngredientsAndParchaseHistory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetIngredientsAndParchaseHistory { ingredients { __typename id name category { __typename id name colorCode } purchaseUnits { __typename id name } purchaseHistory { __typename id date location { __typename id name } purchaseUnit { __typename id name } price } } }"#
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
        .field("category", Category.self),
        .field("purchaseUnits", [PurchaseUnit].self),
        .field("purchaseHistory", [PurchaseHistory].self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var category: Category { __data["category"] }
      public var purchaseUnits: [PurchaseUnit] { __data["purchaseUnits"] }
      public var purchaseHistory: [PurchaseHistory] { __data["purchaseHistory"] }

      /// Ingredient.Category
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
          .field("colorCode", String.self),
        ] }

        public var id: ShokumemoAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var colorCode: String { __data["colorCode"] }
      }

      /// Ingredient.PurchaseUnit
      ///
      /// Parent Type: `PurchaseUnit`
      public struct PurchaseUnit: ShokumemoAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.PurchaseUnit }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ShokumemoAPI.ID.self),
          .field("name", String.self),
        ] }

        public var id: ShokumemoAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
      }

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
          .field("location", Location.self),
          .field("purchaseUnit", PurchaseUnit.self),
          .field("price", Int.self),
        ] }

        public var id: ShokumemoAPI.ID { __data["id"] }
        public var date: String { __data["date"] }
        public var location: Location { __data["location"] }
        public var purchaseUnit: PurchaseUnit { __data["purchaseUnit"] }
        public var price: Int { __data["price"] }

        /// Ingredient.PurchaseHistory.Location
        ///
        /// Parent Type: `Location`
        public struct Location: ShokumemoAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Location }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ShokumemoAPI.ID.self),
            .field("name", String.self),
          ] }

          public var id: ShokumemoAPI.ID { __data["id"] }
          public var name: String { __data["name"] }
        }

        /// Ingredient.PurchaseHistory.PurchaseUnit
        ///
        /// Parent Type: `PurchaseUnit`
        public struct PurchaseUnit: ShokumemoAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.PurchaseUnit }
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
}
