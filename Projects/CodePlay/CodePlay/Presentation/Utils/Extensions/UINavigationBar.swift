//
//  UINavigationBar.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/24/25.
//

import UIKit

extension UINavigationBar {
    static func applyLiquidGlassStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .light) // or .systemUltraThinMaterial
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.1)

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}


