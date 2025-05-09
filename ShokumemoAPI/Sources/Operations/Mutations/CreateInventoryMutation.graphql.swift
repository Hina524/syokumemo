// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateInventoryMutation: GraphQLMutation {
  public static let operationName: String = "CreateInventory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateInventory($input: NewInventory!) { addInventory(input: $input) { __typename id ingredient { __typename id name } quantity { __typename numerator denominator } unit expiryDate frozen expired soonExpiry soonDays } }"#
    ))

  public var input: NewInventory

  public init(input: NewInventory) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("addInventory", AddInventory.self, arguments: ["input": .variable("input")]),
    ] }

    public var addInventory: AddInventory { __data["addInventory"] }

    /// AddInventory
    ///
    /// Parent Type: `Inventory`
    public struct AddInventory: ShokumemoAPI.SelectionSet {
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
        .field("expired", Bool.self),
        .field("soonExpiry", Bool.self),
        .field("soonDays", Int?.self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var ingredient: Ingredient { __data["ingredient"] }
      public var quantity: Quantity { __data["quantity"] }
      public var unit: String { __data["unit"] }
      public var expiryDate: String { __data["expiryDate"] }
      public var frozen: Bool { __data["frozen"] }
      public var expired: Bool { __data["expired"] }
      public var soonExpiry: Bool { __data["soonExpiry"] }
      public var soonDays: Int? { __data["soonDays"] }

      /// AddInventory.Ingredient
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

      /// AddInventory.Quantity
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
