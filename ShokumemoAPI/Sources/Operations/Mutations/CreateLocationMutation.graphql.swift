// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateLocationMutation: GraphQLMutation {
  public static let operationName: String = "CreateLocation"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateLocation($input: NewLocation!) { createLocation(input: $input) { __typename id name } }"#
    ))

  public var input: NewLocation

  public init(input: NewLocation) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: ShokumemoAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ShokumemoAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createLocation", CreateLocation.self, arguments: ["input": .variable("input")]),
    ] }

    public var createLocation: CreateLocation { __data["createLocation"] }

    /// CreateLocation
    ///
    /// Parent Type: `Location`
    public struct CreateLocation: ShokumemoAPI.SelectionSet {
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
