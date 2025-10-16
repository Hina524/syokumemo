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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            viewModel.signInWithApple()
        }) {
            SignInWithAppleButtonRepresentable(colorScheme: colorScheme)
                .frame(width: 280, height: 60)
        }
        .disabled(viewModel.isLoading)
        .accessibilityLabel("Apple でサインイン")
        .accessibilityHint("Apple ID を使ってアプリにサインインします")
    }
}

// MARK: - UIViewRepresentable for Apple Sign In Button
struct SignInWithAppleButtonRepresentable: UIViewRepresentable {
    let colorScheme: ColorScheme
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let buttonStyle: ASAuthorizationAppleIDButton.Style = colorScheme == .dark ? .white : .black
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: buttonStyle
        )
        
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        // ASAuthorizationAppleIDButtonのスタイルは初期化後に変更できないため、
        // カラースキームが変更された場合は親ビューの再描画で対応される
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
