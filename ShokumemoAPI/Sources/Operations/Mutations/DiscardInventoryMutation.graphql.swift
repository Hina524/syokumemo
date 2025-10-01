// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DiscardInventoryMutation: GraphQLMutation {
  public static let operationName: String = "DiscardInventory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DiscardInventory($id: ID!) { discardInventory(id: $id) { __typename id status } }"#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("discardInventory", DiscardInventory.self, arguments: ["id": .variable("id")]),
    ] }

    public var discardInventory: DiscardInventory { __data["discardInventory"] }

    /// DiscardInventory
    ///
    /// Parent Type: `Inventory`
    public struct DiscardInventory: ShokumemoAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Inventory }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", ShokumemoAPI.ID.self),
        .field("status", GraphQLEnum<ShokumemoAPI.InventoryStatus>.self),
      ] }

      public var id: ShokumemoAPI.ID { __data["id"] }
      public var status: GraphQLEnum<ShokumemoAPI.InventoryStatus> { __data["status"] }
    }
  }
}
