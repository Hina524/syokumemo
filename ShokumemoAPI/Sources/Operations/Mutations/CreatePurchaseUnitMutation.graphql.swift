// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreatePurchaseUnitMutation: GraphQLMutation {
  public static let operationName: String = "CreatePurchaseUnit"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreatePurchaseUnit($input: NewPurchaseUnit!) { createPurchaseUnit(input: $input) { __typename id name ingredient { __typename id name } } }"#
    ))

  public var input: NewPurchaseUnit

  public init(input: NewPurchaseUnit) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createPurchaseUnit", CreatePurchaseUnit.self, arguments: ["input": .variable("input")]),
    ] }

    public var createPurchaseUnit: CreatePurchaseUnit { __data["createPurchaseUnit"] }

    /// CreatePurchaseUnit
    ///
    /// Parent Type: `PurchaseUnit`
    public struct CreatePurchaseUnit: ShokumemoAPI.SelectionSet {
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

      /// CreatePurchaseUnit.Ingredient
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
