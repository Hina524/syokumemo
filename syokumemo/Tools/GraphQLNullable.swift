//
//  GraphQLNullable.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/07.
//

import ApolloAPI

extension GraphQLNullable {
  // Optional<Wrapped> → GraphQLNullable<Wrapped> 変換用イニシャライザ
  // - note: `nil` を明示的な null と扱いたい場合は `.null` を、
  //         「値を送らない（undefined）」と扱いたい場合は `.none` に変更します。
  init(optionalValue value: Wrapped?) {
    if let v = value {
      self = .some(v)
    } else {
      // GraphQL 上で explicit null を送りたいなら .null、
      // 変数自体を省略したい（undefined）なら .none に。
      self = .null
    }
  }
}
