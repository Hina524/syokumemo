// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteIngredientMutation: GraphQLMutation {
  public static let operationName: String = "DeleteIngredient"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DeleteIngredient($id: ID!) { deleteIngredient(id: $id) }"#
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
      .field("deleteIngredient", Bool.self, arguments: ["id": .variable("id")]),
    ] }

    public var deleteIngredient: Bool { __data["deleteIngredient"] }
  }
}
