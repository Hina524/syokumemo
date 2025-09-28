//
//  LocationSelectionPage.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/09/28.
//

import SwiftUI
import ShokumemoAPI

struct LocationSelectionPage: View {
    @Binding var path: [AppNavigationPath]
    @ObservedObject var viewModel: InputPurchaseHistoryViewModel
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    path.removeLast()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                            .font(.body)
                    }
                    .foregroundColor(.black)
                }
                Spacer()
            }
            Text("購入場所選択")
        }
        .padding()
        .frame(height: 50)
        
        List {
            ForEach(viewModel.locations, id: \.id) { location in
                Button(action: {
                    viewModel.selectedLocationName = location.name
                    viewModel.form.locationId = location.id
                    path.removeAll()
                }) {
                    Text(location.name)
                        .foregroundColor(.black)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}