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
    private var tokenRefreshTimer: Timer?
    
    init() {
        observeAuthState()
        setupTokenRefreshTimer()
        setupAuthenticationNotificationObserver()
        
        // アプリ起動時に既存の認証状態でトークンをリフレッシュ
        Task {
            await refreshTokenOnAppLaunch()
        }
    }
    
    deinit {
        if let listener = authStateListener {
            authService.removeAuthStateListener(listener)
        }
        tokenRefreshTimer?.invalidate()
        cancellables.removeAll()
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
    
    // MARK: - Retry Sign In
    func retrySignIn() {
        signInWithApple()
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
    
    // MARK: - Token Refresh Timer
    private func setupTokenRefreshTimer() {
        // 50分ごとに自動トークン更新（Firebaseトークンは60分で失効）
        tokenRefreshTimer = Timer.scheduledTimer(withTimeInterval: 50 * 60, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshTokenSilently()
            }
        }
    }
    
    private func refreshTokenSilently() async {
        guard isAuthenticated else { return }
        
        do {
            let token = try await authService.refreshToken()
            Network.shared.setupAuthenticationHeader(with: token)
        } catch {
            print("Silent token refresh failed: \(error)")
        }
    }
    
    // MARK: - Authentication Notification Observer
    private func setupAuthenticationNotificationObserver() {
        NotificationCenter.default.publisher(for: .authenticationRequired)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleForceLogout()
            }
            .store(in: &cancellables)
    }
    
    private func handleForceLogout() {
        do {
            try authService.signOut()
            errorMessage = "セッションが無効になりました。再度ログインしてください。"
        } catch {
            errorMessage = "ログアウト処理でエラーが発生しました。"
        }
    }
    
    // MARK: - Scene Phase Handling
    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // アプリがアクティブになった際にトークン有効性をチェック
            Task {
                await checkTokenValidityOnResume()
            }
        case .background:
            // バックグラウンドに入る際の処理（必要に応じて）
            break
        case .inactive:
            // 非アクティブ状態の処理（必要に応じて）
            break
        @unknown default:
            break
        }
    }
    
    private func checkTokenValidityOnResume() async {
        guard isAuthenticated else { return }
        
        let isValid = await authService.isTokenValid()
        if !isValid {
            await refreshTokenSilently()
        }
    }
    
    // MARK: - App Launch Token Refresh
    private func refreshTokenOnAppLaunch() async {
        // 既に認証されているユーザーがいる場合のみトークンをリフレッシュ
        guard let currentUser = Auth.auth().currentUser else { return }
        
        do {
            let token = try await currentUser.getIDToken(forcingRefresh: true)
            Network.shared.setupAuthenticationHeader(with: token)
            print("App launch token refresh successful")
        } catch {
            print("App launch token refresh failed: \(error)")
            // 失敗した場合はサイレントにログアウト
            do {
                try authService.signOut()
            } catch {
                print("Failed to sign out after token refresh failure: \(error)")
            }
        }
    }
}
