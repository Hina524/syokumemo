// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdatePurchaseHistoryMutation: GraphQLMutation {
  public static let operationName: String = "UpdatePurchaseHistory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdatePurchaseHistory($id: ID!, $input: UpdatePurchaseHistory!) { updatePurchaseHistory(id: $id, input: $input) { __typename id date location { __typename id name } purchaseUnit { __typename id name } price } }"#
    ))

  public var id: ID
  public var input: UpdatePurchaseHistory

  public init(
    id: ID,
    input: UpdatePurchaseHistory
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
      .field("updatePurchaseHistory", UpdatePurchaseHistory.self, arguments: [
        "id": .variable("id"),
        "input": .variable("input")
      ]),
    ] }

    public var updatePurchaseHistory: UpdatePurchaseHistory { __data["updatePurchaseHistory"] }

    /// UpdatePurchaseHistory
    ///
    /// Parent Type: `PurchaseHistory`
    public struct UpdatePurchaseHistory: ShokumemoAPI.SelectionSet {
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

      /// UpdatePurchaseHistory.Location
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

      /// UpdatePurchaseHistory.PurchaseUnit
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
