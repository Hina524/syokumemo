//
//  TopBarView.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/06.
//

import SwiftUI

struct TopBarView: View {
    let title: String

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding()
            Spacer()
        }
        .frame(height: 50)
    }
}
