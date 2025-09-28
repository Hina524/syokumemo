// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateLocationMutation: GraphQLMutation {
  public static let operationName: String = "UpdateLocation"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateLocation($id: ID!, $input: UpdateLocationInput!) { updateLocation(id: $id, input: $input) { __typename id name } }"#
    ))

  public var id: ID
  public var input: UpdateLocationInput

  public init(
    id: ID,
    input: UpdateLocationInput
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
      .field("updateLocation", UpdateLocation.self, arguments: [
        "id": .variable("id"),
        "input": .variable("input")
      ]),
    ] }

    public var updateLocation: UpdateLocation { __data["updateLocation"] }

    /// UpdateLocation
    ///
    /// Parent Type: `Location`
    public struct UpdateLocation: ShokumemoAPI.SelectionSet {
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
