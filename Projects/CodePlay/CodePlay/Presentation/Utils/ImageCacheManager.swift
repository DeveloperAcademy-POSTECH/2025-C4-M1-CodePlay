//
//  ImageCacheManager.swift
//  CodePlay
//
//  Created by 광로 on 9/10/25.
//

import Foundation
import UIKit

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let urlSession: URLSession
    
    private init() {
        self.urlSession = URLSession.shared
        cache.countLimit = 150
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    /// 캐시에서 이미지 가져오기
    func getImage(for url: String) -> UIImage? {
        return cache.object(forKey: NSString(string: url))
    }
    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: NSString(string: url))
    }
    /// URL에서 이미지 로드 (캐시 확인 → 네트워크 → 캐시 저장)
    func loadImage(from urlString: String) async -> UIImage? {
        if let cachedImage = getImage(for: urlString) {
            return cachedImage
        }
        guard let url = URL(string: urlString) else {
            return nil
        }
        do {
            let (data, _) = try await urlSession.data(from: url)
            guard let image = UIImage(data: data) else {
                return nil
            }
            setImage(image, for: urlString)
            return image
            
        } catch {
            return nil
        }
    }
    func clearCache() {
        cache.removeAllObjects()
    }
    func removeImage(for url: String) {
        cache.removeObject(forKey: NSString(string: url))
    }
}
