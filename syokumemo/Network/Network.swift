//
//  Network.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI
import Apollo
import ApolloAPI
import FirebaseAuth

class Network {
    static let shared = Network()
    
    private var currentToken: String?
    
    private(set) lazy var apollo: ApolloClient = {
        let url = URL(string: Bundle.main.infoDictionary?["ENDPOINT_URL"] as! String)!
        
        let store = ApolloStore()
        let client = URLSessionClient()
        let provider = NetworkInterceptorProvider(client: client, store: store)
        let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url)
        
        return ApolloClient(networkTransport: transport, store: store)
    }()
    
    // MARK: - Authentication Header Setup
    func setupAuthenticationHeader(with token: String) {
        currentToken = token
        // Apollo Clientの再構築は必要なし、インターセプターで動的にヘッダーを追加
    }
    
    func clearAuthenticationHeader() {
        currentToken = nil
    }
    
    func getCurrentToken() -> String? {
        return currentToken
    }
    
    // MARK: - Automatic Token Refresh
    func refreshTokenIfNeeded() async {
        guard let user = Auth.auth().currentUser else {
            clearAuthenticationHeader()
            return
        }
        
        do {
            let token = try await user.getIDToken()
            setupAuthenticationHeader(with: token)
        } catch {
            print("Failed to refresh Firebase token: \(error)")
            clearAuthenticationHeader()
        }
    }
}

// MARK: - Custom Network Interceptor Provider
class NetworkInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        
        // 認証インターセプターを最初に追加
        interceptors.insert(AuthenticationInterceptor(), at: 0)
        
        return interceptors
    }
}

// MARK: - Authentication Interceptor
class AuthenticationInterceptor: ApolloInterceptor {
    public var id: String = UUID().uuidString
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        // Firebase IDトークンをヘッダーに追加
        if let token = Network.shared.getCurrentToken() {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
        }
        
        // 次のインターセプターに処理を渡す
        chain.proceedAsync(request: request, response: response, completion: completion)
    }
}
