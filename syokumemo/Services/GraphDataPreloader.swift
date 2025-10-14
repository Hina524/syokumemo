//
//  GraphDataPreloader.swift
//  syokumemo
//
//  Created by KONISHI Hina on 2025/10/14.
//

import SwiftUI
import Apollo
import ShokumemoAPI

class GraphDataPreloader: ObservableObject {
    static let shared = GraphDataPreloader()
    private var isPreloaded = false
    private var isPreloading = false
    
    private init() {}
    
    func preloadGraphDataInBackground() {
        guard !isPreloaded && !isPreloading else { return }
        
        isPreloading = true
        
        Task {
            // バックグラウンドでGraphデータをプリフェッチ
            Network.shared.apollo.fetch(
                query: GetIngredientsAndParchaseHistoryQuery(),
                cachePolicy: .fetchIgnoringCacheData
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isPreloading = false
                    switch result {
                    case .success:
                        self?.isPreloaded = true
                        print("Graph data preloaded successfully")
                    case .failure(let error):
                        print("Graph data preload failed: \(error)")
                    }
                }
            }
            
            // カテゴリデータも同時にプリフェッチ
            Network.shared.apollo.fetch(
                query: GetCategoriesAndIngredientsQuery(),
                cachePolicy: .fetchIgnoringCacheData
            ) { result in
                switch result {
                case .success:
                    print("Categories data preloaded successfully")
                case .failure(let error):
                    print("Categories data preload failed: \(error)")
                }
            }
        }
    }
    
    func resetPreloadState() {
        isPreloaded = false
        isPreloading = false
    }
}