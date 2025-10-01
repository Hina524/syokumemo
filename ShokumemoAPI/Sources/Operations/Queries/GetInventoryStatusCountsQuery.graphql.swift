// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetInventoryStatusCountsQuery: GraphQLQuery {
  public static let operationName: String = "GetInventoryStatusCounts"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetInventoryStatusCounts { inventoryStatusCounts { __typename active discarded consumed } }"#
    ))

  public init() {}

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("inventoryStatusCounts", InventoryStatusCounts.self),
    ] }

    public var inventoryStatusCounts: InventoryStatusCounts { __data["inventoryStatusCounts"] }

    /// InventoryStatusCounts
    ///
    /// Parent Type: `InventoryStatusCounts`
    public struct InventoryStatusCounts: ShokumemoAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.InventoryStatusCounts }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("active", Int.self),
        .field("discarded", Int.self),
        .field("consumed", Int.self),
      ] }

      public var active: Int { __data["active"] }
      public var discarded: Int { __data["discarded"] }
      public var consumed: Int { __data["consumed"] }
    }
  }
}
