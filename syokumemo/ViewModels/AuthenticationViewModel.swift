//
//  AuthenticationViewModel.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/01.
//

import SwiftUI
import FirebaseAuth
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    private let authService = AuthenticationService.shared
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    private lazy var coordinator = AuthenticationCoordinator(viewModel: self)
    
    init() {
        observeAuthState()
    }
    
    deinit {
        if let listener = authStateListener {
            authService.removeAuthStateListener(listener)
        }
    }
    
    // MARK: - Authentication State Management
    private func observeAuthState() {
        authStateListener = authService.addAuthStateListener { [weak self] user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                if user != nil {
                    self?.errorMessage = nil
                    // 認証成功時にネットワークトークンを設定
                    Task {
                        await self?.updateNetworkToken()
                    }
                } else {
                    // サインアウト時にネットワークトークンをクリア
                    Network.shared.clearAuthenticationHeader()
                }
            }
        }
    }
    
    private func updateNetworkToken() async {
        do {
            let token = try await authService.getIDToken()
            Network.shared.setupAuthenticationHeader(with: token)
        } catch {
            print("Failed to update network token: \(error)")
        }
    }
    
    // MARK: - Sign In
    func signInWithApple() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        coordinator.startSignInWithApple()
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try authService.signOut()
            Network.shared.clearAuthenticationHeader()
            errorMessage = nil
        } catch {
            errorMessage = "サインアウトに失敗しました: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Token Management
    func getIDToken() async throws -> String {
        return try await authService.getIDToken()
    }
    
    
    // MARK: - Authentication Result Handlers
    func handleAuthenticationSuccess() {
        isLoading = false
        errorMessage = nil
        // isAuthenticatedはauth state listenerで自動更新される
        
        // 認証成功後に即座にトークンを更新
        Task {
            await updateNetworkToken()
        }
    }
    
    func handleAuthenticationError(_ error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
    }
    
    func handleAuthenticationCanceled() {
        isLoading = false
        // エラーメッセージは表示しない（ユーザーが意図的にキャンセルした）
    }
    
    // MARK: - User Profile
    var displayName: String {
        return currentUser?.displayName ?? "ユーザー"
    }
    
    var email: String? {
        return currentUser?.email
    }
    
    var userID: String? {
        return currentUser?.uid
    }
}