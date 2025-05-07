//
//  SplashScreenPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

struct SplashScreenPage: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opsity = 0.5
    
    var body: some View {
        if isActive {
            AppPage()
        } else {
            VStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 218.19, height: 95)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenPage()
}
