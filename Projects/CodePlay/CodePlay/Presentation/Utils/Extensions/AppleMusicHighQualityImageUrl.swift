//
//  AppleMusicHighQualityImageUrl.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/30/25.
//

import Foundation

extension String {
    func appleMusicHighQualityImageURL(targetSize: Int = 592) -> String {
        if self.contains("{w}x{h}") {
            // 템플릿 URL 처리
            return self
                .replacingOccurrences(of: "{w}", with: String(targetSize))
                .replacingOccurrences(of: "{h}", with: String(targetSize))
                .replacingOccurrences(of: "{f}", with: "webp")
        } else {
            // 기존 크기 패턴 교체
            let pattern = "\\d+x\\d+"
            let replacement = "\(targetSize)x\(targetSize)"
            
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(location: 0, length: self.count)
                return regex.stringByReplacingMatches(
                    in: self,
                    options: [],
                    range: range,
                    withTemplate: replacement
                )
            }
        }
        return self
    }
}
