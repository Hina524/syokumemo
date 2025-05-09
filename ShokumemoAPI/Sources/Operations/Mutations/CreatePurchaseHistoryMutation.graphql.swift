// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreatePurchaseHistoryMutation: GraphQLMutation {
  public static let operationName: String = "CreatePurchaseHistory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreatePurchaseHistory($input: NewPurchaseHistory!) { addPurchaseHistory(input: $input) { __typename id ingredient { __typename id name category { __typename id name } } date location price } }"#
    ))

  public var input: NewPurchaseHistory

  public init(input: NewPurchaseHistory) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("addPurchaseHistory", AddPurchaseHistory.self, arguments: ["input": .variable("input")]),
    ] }

    public var addPurchaseHistory: AddPurchaseHistory { __data["addPurchaseHistory"] }

    /// AddPurchaseHistory
    ///
    /// Parent Type: `PurchaseHistory`
    public struct AddPurchaseHistory: ShokumemoAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.PurchaseHistory }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", ShokumemoAPI.ID.self),
        .field("ingredient", Ingredient.self),
        .field("date", String.self),
        .field("location", String.self),
        .field("price", Double.self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var ingredient: Ingredient { __data["ingredient"] }
      public var date: String { __data["date"] }
      public var location: String { __data["location"] }
      public var price: Double { __data["price"] }

      /// AddPurchaseHistory.Ingredient
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

        /// AddPurchaseHistory.Ingredient.Category
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
}
