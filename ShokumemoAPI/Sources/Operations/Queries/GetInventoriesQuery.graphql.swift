// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetInventoriesQuery: GraphQLQuery {
  public static let operationName: String = "GetInventories"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetInventories($sort: InventorySort) { inventory(sort: $sort) { __typename id ingredient { __typename id name category { __typename id name colorCode } } quantity { __typename numerator denominator } unit expiryDate frozen status } }"#
    ))

  public var sort: GraphQLNullable<GraphQLEnum<InventorySort>>

  public init(sort: GraphQLNullable<GraphQLEnum<InventorySort>>) {
    self.sort = sort
  }

  public var __variables: Variables? { ["sort": sort] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("inventory", [Inventory].self, arguments: ["sort": .variable("sort")]),
    ] }

    public var inventory: [Inventory] { __data["inventory"] }

    /// Inventory
    ///
    /// Parent Type: `Inventory`
    public struct Inventory: ShokumemoAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Inventory }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", ShokumemoAPI.ID.self),
        .field("ingredient", Ingredient.self),
        .field("quantity", Quantity.self),
        .field("unit", String.self),
        .field("expiryDate", String.self),
        .field("frozen", Bool.self),
        .field("status", GraphQLEnum<ShokumemoAPI.InventoryStatus>.self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var ingredient: Ingredient { __data["ingredient"] }
      public var quantity: Quantity { __data["quantity"] }
      public var unit: String { __data["unit"] }
      public var expiryDate: String { __data["expiryDate"] }
      public var frozen: Bool { __data["frozen"] }
      public var status: GraphQLEnum<ShokumemoAPI.InventoryStatus> { __data["status"] }

      /// Inventory.Ingredient
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
        ] }

        public var id: ShokumemoAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var category: Category { __data["category"] }

        /// Inventory.Ingredient.Category
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
      }

      /// Inventory.Quantity
      ///
      /// Parent Type: `Fraction`
      public struct Quantity: ShokumemoAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Fraction }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("numerator", Int.self),
          .field("denominator", Int.self),
        ] }

        public var numerator: Int { __data["numerator"] }
        public var denominator: Int { __data["denominator"] }
      }
    }
  }
}
