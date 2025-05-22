//
//  EditInventoryPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/05/09.
//

import SwiftUI
import ShokumemoAPI

struct EditInventoryPage: View {
    
    @Binding var path: [Inventory]
    @StateObject var viewModel = EditInventoryViewModel()
    
    var inventory: Inventory
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    path.removeLast()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("消費期限リスト")
                            .font(.body)
                    }
                    .foregroundColor(.black)
                }
                Spacer()
            }
            
            Text(inventory.ingredient.name)
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding()
        .frame(height: 50)
        .navigationBarBackButtonHidden(true)
    }
}
