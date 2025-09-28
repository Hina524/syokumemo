// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdatePurchaseUnitMutation: GraphQLMutation {
  public static let operationName: String = "UpdatePurchaseUnit"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdatePurchaseUnit($id: ID!, $input: UpdatePurchaseUnitInput!) { updatePurchaseUnit(id: $id, input: $input) { __typename id name ingredient { __typename id name } } }"#
    ))

  public var id: ID
  public var input: UpdatePurchaseUnitInput

  public init(
    id: ID,
    input: UpdatePurchaseUnitInput
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
      .field("updatePurchaseUnit", UpdatePurchaseUnit.self, arguments: [
        "id": .variable("id"),
        "input": .variable("input")
      ]),
    ] }

    public var updatePurchaseUnit: UpdatePurchaseUnit { __data["updatePurchaseUnit"] }

    /// UpdatePurchaseUnit
    ///
    /// Parent Type: `PurchaseUnit`
    public struct UpdatePurchaseUnit: ShokumemoAPI.SelectionSet {
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

      /// UpdatePurchaseUnit.Ingredient
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
