//
//  Font.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI

extension Font {
    enum KoddiUDOnGothicWeight {
        case regular
        case bold

        var value: String {
            switch self {
            case .regular: return "KoddiUDOnGothic-Regular"
            case .bold: return "KoddiUDOnGothic-Bold"
            }
        }
    }

    static func koddi(_ weight: KoddiUDOnGothicWeight, size: CGFloat) -> Font {
        return Font.custom(weight.value, size: size)
    }

    // MARK: - Headings
    static func HlgBold() -> Font {
        koddi(.bold, size: 24)
    }

    static func HlgRegular() -> Font {
        koddi(.regular, size: 24)
    }

    static func HmdBold() -> Font {
        koddi(.bold, size: 20)
    }

    static func HmdRegular() -> Font {
        koddi(.regular, size: 20)
    }

    // MARK: - Body
    static func BlgBold() -> Font {
        koddi(.bold, size: 17)
    }

    static func BlgRegular() -> Font {
        koddi(.regular, size: 17)
    }

    static func BmdBold() -> Font {
        koddi(.bold, size: 14)
    }

    static func BmdRegular() -> Font {
        koddi(.regular, size: 14)
    }

    static func BsmBold() -> Font {
        koddi(.bold, size: 12)
    }

    static func BsmRegular() -> Font {
        koddi(.regular, size: 12)
    }
}
