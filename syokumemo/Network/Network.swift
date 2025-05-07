//
//  Network.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import Apollo

class Network {
    static let shared = Network()

    private(set) lazy var apollo: ApolloClient = {
        let url = URL(string: "http://localhost:8080/query")!
        return ApolloClient(url: url)
    }()
}
