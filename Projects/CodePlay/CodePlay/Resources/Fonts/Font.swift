//
//  Font.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI

enum KoddiUDOnGothic: String, CaseIterable {
    case regular = "KoddiUDOnGothic-Regular"
    case Bold = "KoddiUDOnGothic-SemiBold"
}

extension Font {
    static func KoddiUDOnGothic(_ type: KoddiUDOnGothic, size: CGFloat) -> Font {
        .custom(type.rawValue, size: size)
    }
    //MARK: - Headings
    static let HlgBold: Font = .KoddiUDOnGothic(.Bold, size: 24)
    static let HlgRegular: Font = .KoddiUDOnGothic(.regular, size: 24)
    static let HmdBold: Font = .KoddiUDOnGothic(.Bold, size: 20)
    static let HmdRegular: Font = .KoddiUDOnGothic(.regular, size: 20)

    //MARK: - Body
    static let BlgBold: Font = .KoddiUDOnGothic(.Bold, size: 17)
    static let BlgRegular: Font = .KoddiUDOnGothic(.regular, size: 17)

    static let BmdBold: Font = .KoddiUDOnGothic(.Bold, size: 14)
    static let BmdRegular: Font = .KoddiUDOnGothic(.regular, size: 14)

    static let BsmBold: Font = .KoddiUDOnGothic(.Bold, size: 12)
    static let BsmRegular: Font = .KoddiUDOnGothic(.regular, size: 12)
    
}

