// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateQuantityMutation: GraphQLMutation {
  public static let operationName: String = "UpdateQuantity"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateQuantity($id: ID!, $input: UpdateQuantity!) { updateQuantity(id: $id, input: $input) { __typename id ingredient { __typename id name category { __typename id name } } quantity { __typename numerator denominator } unit } }"#
    ))

  public var id: ID
  public var input: UpdateQuantity

  public init(
    id: ID,
    input: UpdateQuantity
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
      .field("updateQuantity", UpdateQuantity.self, arguments: [
        "id": .variable("id"),
        "input": .variable("input")
      ]),
    ] }

    public var updateQuantity: UpdateQuantity { __data["updateQuantity"] }

    /// UpdateQuantity
    ///
    /// Parent Type: `Inventory`
    public struct UpdateQuantity: ShokumemoAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Inventory }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", ShokumemoAPI.ID.self),
        .field("ingredient", Ingredient.self),
        .field("quantity", Quantity.self),
        .field("unit", String.self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var ingredient: Ingredient { __data["ingredient"] }
      public var quantity: Quantity { __data["quantity"] }
      public var unit: String { __data["unit"] }

      /// UpdateQuantity.Ingredient
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

        /// UpdateQuantity.Ingredient.Category
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

      /// UpdateQuantity.Quantity
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
