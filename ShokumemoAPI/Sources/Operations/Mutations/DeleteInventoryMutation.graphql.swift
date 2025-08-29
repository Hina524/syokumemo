// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteInventoryMutation: GraphQLMutation {
  public static let operationName: String = "DeleteInventory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DeleteInventory($id: ID!) { deleteInventory(id: $id) }"#
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
      .field("deleteInventory", Bool.self, arguments: ["id": .variable("id")]),
    ] }

    public var deleteInventory: Bool { __data["deleteInventory"] }
  }
}
