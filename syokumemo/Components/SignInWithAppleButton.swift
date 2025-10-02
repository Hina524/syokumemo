//
//  SignInWithAppleButton.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/01.
//

import SwiftUI
import AuthenticationServices

struct SignInWithAppleButton: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        Button(action: {
            viewModel.signInWithApple()
        }) {
            SignInWithAppleButtonRepresentable()
                .frame(height: 50)
        }
        .disabled(viewModel.isLoading)
    }
}

// MARK: - UIViewRepresentable for Apple Sign In Button
struct SignInWithAppleButtonRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: .black
        )
        
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        // 必要に応じて更新処理を追加
    }
}

// MARK: - Preview
struct SignInWithAppleButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleButton(viewModel: AuthenticationViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
