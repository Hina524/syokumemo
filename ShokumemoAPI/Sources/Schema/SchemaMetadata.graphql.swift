// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == ShokumemoAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == ShokumemoAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == ShokumemoAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == ShokumemoAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Category": return ShokumemoAPI.Objects.Category
    case "Fraction": return ShokumemoAPI.Objects.Fraction
    case "Ingredient": return ShokumemoAPI.Objects.Ingredient
    case "Inventory": return ShokumemoAPI.Objects.Inventory
    case "Mutation": return ShokumemoAPI.Objects.Mutation
    case "PurchaseHistory": return ShokumemoAPI.Objects.PurchaseHistory
    case "Query": return ShokumemoAPI.Objects.Query
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
