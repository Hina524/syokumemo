//
//  AuthenticationCoordinator.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/01.
//

import Foundation
import AuthenticationServices
import UIKit

class AuthenticationCoordinator: NSObject {
    
    weak var viewModel: AuthenticationViewModel?
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - Start Apple Sign In
    func startSignInWithApple() {
        let authService = AuthenticationService.shared
        let request = authService.startSignInWithAppleFlow()
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthenticationCoordinator: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Apple Sign In成功
            Task {
                do {
                    let _ = try await AuthenticationService.shared.authenticateWithFirebase(credential: appleIDCredential)
                    
                    await MainActor.run {
                        self.viewModel?.handleAuthenticationSuccess()
                    }
                } catch {
                    await MainActor.run {
                        self.viewModel?.handleAuthenticationError(error)
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Apple Sign In失敗
        DispatchQueue.main.async {
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    // ユーザーがキャンセルした場合は何もしない
                    self.viewModel?.handleAuthenticationCanceled()
                case .failed:
                    self.viewModel?.handleAuthenticationError(AuthenticationError.signInFailed("Apple Sign In failed"))
                case .invalidResponse:
                    self.viewModel?.handleAuthenticationError(AuthenticationError.signInFailed("Invalid response from Apple"))
                case .notHandled:
                    self.viewModel?.handleAuthenticationError(AuthenticationError.signInFailed("Sign in not handled"))
                case .unknown:
                    self.viewModel?.handleAuthenticationError(AuthenticationError.signInFailed("Unknown error occurred"))
                @unknown default:
                    self.viewModel?.handleAuthenticationError(AuthenticationError.signInFailed("Unexpected error occurred"))
                }
            } else {
                self.viewModel?.handleAuthenticationError(error)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthenticationCoordinator: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available for presentation")
        }
        return window
    }
}

