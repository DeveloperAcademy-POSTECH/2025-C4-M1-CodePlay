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
                                    .neu900.opacity(0.3), .neu900.opacity(0.1),
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 0.1, y: 1.0)
                            )
                        )
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .neu900.opacity(0.4),
                                    .clear,
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 0.1, y: 1.0)
                            ), lineWidth: 1
                        )
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear, .neu900.opacity(0.2),
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 1.0, y: 0.0)
                            ), lineWidth: 1
                        )
                )
                .cornerRadius(cornerRadius)
                .shadow(color: .neu50.opacity(0.15), radius: 5, x: 0, y: 5)

        case .list:
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .neu900.opacity(0.3), .neu900.opacity(0.2),
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 0.1, y: 1.0)
                            )
                        )
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .neu900.opacity(0.2),
                                    .clear,
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 0.1, y: 1.0)
                            ), lineWidth: 1
                        )
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear, .neu900.opacity(0.3),
                                ]),
                                startPoint: UnitPoint(x: 0.0, y: 0.0),
                                endPoint: UnitPoint(x: 1.0, y: 0.0)
                            ), lineWidth: 1
                        )
                )
                .cornerRadius(cornerRadius)
                .shadow(color: .neu50.opacity(0.1), radius: 4, x: 0, y: 1)
            
//        case .listbutton:
//            content
//                .background(
//                    ZStack {
//                        Rectangle()
//                            .fill(.ultraThinMaterial)
//
//                        Rectangle()
//                            .fill(Color.white.opacity(0.1))
//                    }
//                )
//                .ignoresSafeArea()
            
        case .listbutton:
            content
                .background(
                    ZStack {
                        Rectangle().fill(.ultraThinMaterial)
                        Rectangle().fill(Color.neu900.opacity(0.05)) // 최소한의 빛 반사 효과
                    }
                )
                .ignoresSafeArea()
            
        
        }
    }
}

#Preview("Card Style") {
    Text("카드 스타일")
        .padding()
        .frame(width: 200, height: 100)
        .liquidGlass(style: .card)
        .padding()
        .background(Color.red)
}

#Preview("List Style") {
    VStack {
        Text("리스트 스타일")
            .padding()
            .liquidGlass(style: .list)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}

#Preview("ListButton Style") {
    VStack {
        Text("리스트 버튼 스타일")
            .padding()
            .liquidGlass(style: .listbutton)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
