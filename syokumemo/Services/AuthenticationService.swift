//
//  AuthenticationService.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/01.
//

import Foundation
import FirebaseAuth
import CryptoKit
import AuthenticationServices

class AuthenticationService: NSObject {
    static let shared = AuthenticationService()
    
    private var currentNonce: String?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Nonce Generation
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    // MARK: - SHA256 Hash
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // MARK: - Apple Sign In Flow
    func startSignInWithAppleFlow() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        return request
    }
    
    // MARK: - Firebase Authentication
    func authenticateWithFirebase(credential: ASAuthorizationAppleIDCredential) async throws -> AuthDataResult {
        guard let nonce = currentNonce else {
            throw AuthenticationError.invalidNonce
        }
        
        guard let appleIDToken = credential.identityToken else {
            throw AuthenticationError.invalidToken
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthenticationError.invalidTokenData
        }
        
        // Firebase認証用のcredentialを作成
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )
        
        // Firebase認証を実行
        let result = try await Auth.auth().signIn(with: credential)
        
        // nonceをクリア
        currentNonce = nil
        
        return result
    }
    
    // MARK: - Authentication State
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getIDToken(forceRefresh: Bool = false) async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.notAuthenticated
        }
        
        return try await user.getIDToken(forcingRefresh: forceRefresh)
    }
    
    // MARK: - Token Refresh
    func refreshToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.notAuthenticated
        }
        
        return try await user.getIDToken(forcingRefresh: true)
    }
    
    // MARK: - Token Validation
    func isTokenValid() async -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }
        
        do {
            _ = try await user.getIDToken(forcingRefresh: false)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Auth State Listener
    func addAuthStateListener(_ listener: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { (_, user) in
            listener(user)
        }
    }
    
    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}

// MARK: - Authentication Errors
enum AuthenticationError: LocalizedError {
    case invalidNonce
    case invalidToken
    case invalidTokenData
    case notAuthenticated
    case signInFailed(String)
    case tokenRefreshFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidNonce:
            return "Invalid nonce. Sign in failed."
        case .invalidToken:
            return "Unable to fetch identity token."
        case .invalidTokenData:
            return "Unable to serialize token string from data."
        case .notAuthenticated:
            return "User is not authenticated."
        case .signInFailed(let message):
            return message
        case .tokenRefreshFailed:
            return "Failed to refresh authentication token."
        }
    }
}
