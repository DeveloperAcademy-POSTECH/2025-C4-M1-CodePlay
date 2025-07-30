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
        if UITraitCollection.current.userInterfaceStyle == .dark {
            appearance.backgroundEffect = UIBlurEffect(style: .dark)
        } else {
            appearance.backgroundEffect = UIBlurEffect(style: .light)
        }
        appearance.backgroundColor = UIColor.neu0.withAlphaComponent(0.1)

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
