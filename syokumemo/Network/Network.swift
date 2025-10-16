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
        print("Debug: All Info.plist keys: \(Bundle.main.infoDictionary?.keys.sorted() ?? [])")
        print("Debug: ENDPOINT_URL raw value: \(Bundle.main.infoDictionary?["ENDPOINT_URL"] ?? "nil")")
        
        guard let endpointString = Bundle.main.infoDictionary?["ENDPOINT_URL"] as? String,
              !endpointString.isEmpty,
              let url = URL(string: endpointString) else {
            print("Debug: ENDPOINT_URL not found or empty in Info.plist")
            print("Debug: Available keys: \(Bundle.main.infoDictionary?.keys.sorted() ?? [])")
            fatalError("ENDPOINT_URL not found in Info.plist or invalid URL format. Check Config.xcconfig settings.")
        }
        
        print("Using endpoint: \(endpointString)")
        
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
    
    // MARK: - Force Token Refresh
    func forceRefreshToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.notAuthenticated
        }
        
        let token = try await user.getIDToken(forcingRefresh: true)
        setupAuthenticationHeader(with: token)
        return token
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
        
        // エラーインターセプターをレスポンス処理前に追加
        if let responseCodeIndex = interceptors.firstIndex(where: { $0 is ResponseCodeInterceptor }) {
            interceptors.insert(ErrorInterceptor(), at: responseCodeIndex + 1)
        }
        
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

// MARK: - Error Interceptor
class ErrorInterceptor: ApolloInterceptor {
    public var id: String = UUID().uuidString
    private static let maxRetryCount = 1
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        // レスポンスがある場合のみ処理
        guard let response = response else {
            chain.proceedAsync(request: request, response: response, completion: completion)
            return
        }
        
        // 401エラーの場合、トークンをリフレッシュして再試行
        if response.httpResponse.statusCode == 401 {
            handleUnauthorizedError(chain: chain, request: request, response: response, completion: completion)
        } else {
            chain.proceedAsync(request: request, response: response, completion: completion)
        }
    }
    
    private func handleUnauthorizedError<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        // リトライ回数をチェック
        let retryCount = request.additionalHeaders["X-Retry-Count"].flatMap { Int($0) } ?? 0
        
        if retryCount >= Self.maxRetryCount {
            // 最大リトライ回数に達した場合、ログアウトを促す
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .authenticationRequired, object: nil)
            }
            chain.proceedAsync(request: request, response: response, completion: completion)
            return
        }
        
        // トークンリフレッシュを試行
        Task {
            do {
                _ = try await Network.shared.forceRefreshToken()
                
                // リトライ回数を増やして再実行
                let newRequest = request
                newRequest.addHeader(name: "X-Retry-Count", value: "\(retryCount + 1)")
                
                // 新しいトークンでヘッダーを更新
                if let token = Network.shared.getCurrentToken() {
                    newRequest.addHeader(name: "Authorization", value: "Bearer \(token)")
                }
                
                // リクエストを再実行
                chain.retry(request: newRequest, completion: completion)
            } catch {
                // トークンリフレッシュ失敗時はログアウトを促す
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .authenticationRequired, object: nil)
                }
                chain.proceedAsync(request: request, response: response, completion: completion)
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let authenticationRequired = Notification.Name("authenticationRequired")
}
