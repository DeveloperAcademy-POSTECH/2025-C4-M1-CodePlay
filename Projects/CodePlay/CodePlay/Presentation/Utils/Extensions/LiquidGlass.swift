//
//  LiquidGlass.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/14/25.
//

import SwiftUI
import UIKit

enum LiquidGlassStyle {
    case card
    case list
    case listbutton
}

extension View {
    func liquidGlass(
        style: LiquidGlassStyle,
        cornerRadius: CGFloat = 16,
        opacity: Double = 0.6
    ) -> some View {
        self.modifier(LiquidGlassModifier(style: style, cornerRadius: cornerRadius, opacity: opacity))
    }
}

struct LiquidGlassModifier: ViewModifier {
    let style: LiquidGlassStyle
    let cornerRadius: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        switch style {
        case .card:
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .inset(by: 0.5)
                        .fill(.ultraThinMaterial)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .neu0.opacity(0.6), .neu0.opacity(0.3),
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 0.1, y: 1.0)
                            )
                        )
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .neu0.opacity(0.4),
                                    .clear,
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 0.1, y: 1.0)
                            ), lineWidth: 1
                        )
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear, .neu0.opacity(0.5),
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 1.0, y: 0.0)
                            ), lineWidth: 1
                        )
                )
                .cornerRadius(cornerRadius)
                .shadow(color: .neu1000.opacity(0.25), radius: 5, x: 0, y: 5)

        case .list:
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .neu0.opacity(0.6), .neu0.opacity(0.3),
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 0.1, y: 1.0)
                            )
                        )
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .neu0.opacity(0.4),
                                    .clear,
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 0.1, y: 1.0)
                            ), lineWidth: 1
                        )
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear, .neu0.opacity(0.5),
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 1.0, y: 0.0)
                            ), lineWidth: 1
                        )
                )
                .cornerRadius(cornerRadius)
                .shadow(color: .neu1000.opacity(0.1), radius: 4, x: 0, y: 1)
            
        case .listbutton:
            content
                .background(
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)

                        Rectangle()
                            .fill(Color(UIColor.neu0.withAlphaComponent(0.1)))
                    }
                )
                .ignoresSafeArea()
        }
    }
}
