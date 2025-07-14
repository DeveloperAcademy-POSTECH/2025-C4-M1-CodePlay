//
//  LiquidGlass.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/14/25.
//

import SwiftUI
import UIKit

extension View {
    func liquidGlass(cornerRadius: CGFloat = 16, opacity: Double = 0.6) -> some View {
        self.modifier(
            LiquidGlassModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.9
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .inset(by: 0.5)
                    .fill(.ultraThinMaterial)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.6), .white.opacity(0.3),
                            ]),
                            startPoint: UnitPoint(x: 0.0, y: 0.0),
                            endPoint: UnitPoint(x: 0.1, y: 1.0)
                        )
                    )
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.4),
                                .clear,
                            ]),
                            startPoint: UnitPoint(x: 0.0, y: 0.0),
                            endPoint: UnitPoint(x: 0.1, y: 1.0)
                        ), lineWidth: 1
                    )
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear, .white.opacity(0.5),
                            ]),
                            startPoint: UnitPoint(x: 0.0, y: 0.0),
                            endPoint: UnitPoint(x: 1.0, y: 0.0)
                        ), lineWidth: 1
                    )
            )
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 5)
    }
}
