//
//  CachedAsyncImage.swift
//  CodePlay
//
//  Created by 광로 on 9/10/25.
//

import SwiftUI
internal import Combine

struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    let content: (AsyncImagePhase) -> Content
    
    @StateObject private var imageLoader = CachedImageLoader()
    @State private var initialPhase: AsyncImagePhase?
    
    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        content(initialPhase ?? imageLoader.phase)
            .onAppear {
                if let url = url {
                    // 즉시 캐시 확인
                    if let cachedImage = ImageCacheManager.shared.getImage(for: url.absoluteString) {
                        initialPhase = .success(Image(uiImage: cachedImage))
                    } else {
                        imageLoader.loadImage(from: url.absoluteString)
                    }
                }
            }
            .onChange(of: url) { newUrl in
                if let newUrl = newUrl {
                    // URL 변경 시에도 즉시 캐시 확인
                    if let cachedImage = ImageCacheManager.shared.getImage(for: newUrl.absoluteString) {
                        initialPhase = .success(Image(uiImage: cachedImage))
                    } else {
                        initialPhase = nil
                        imageLoader.loadImage(from: newUrl.absoluteString)
                    }
                }
            }
    }
}

class CachedImageLoader: ObservableObject {
    @Published var phase: AsyncImagePhase = .empty
    
    private let cacheManager = ImageCacheManager.shared
    
    func loadImage(from urlString: String) {
        Task { @MainActor in
            // 로딩 상태로 설정
            self.phase = .empty
            
            if let image = await cacheManager.loadImage(from: urlString) {
                self.phase = .success(Image(uiImage: image))
            } else {
                self.phase = .failure(URLError(.badURL))
            }
        }
    }
}
