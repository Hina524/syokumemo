// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetLocationsQuery: GraphQLQuery {
  public static let operationName: String = "GetLocations"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetLocations { locations { __typename id name } }"#
    ))

  public init() {}

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("locations", [Location].self),
    ] }

    public var locations: [Location] { __data["locations"] }

    /// Location
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
  }
}
