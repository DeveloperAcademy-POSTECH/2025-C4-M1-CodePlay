//
//  Background.swift
//  CodePlay
//
//  Created by 성현 on 7/22/25.
//

import SwiftUI

struct Background: View {
    var body: some View {
        let W = UIScreen.main.bounds.width
        let H = UIScreen.main.bounds.height

        ZStack {
            Circle()
                .fill(Color("Secondary").opacity(0.3))
                .frame(width: W * 0.83, height: W * 0.83)
                .position(
                    x: W * 0.83 / 2 - W * 0.18,
                    y: W * 0.83 / 2 - W * 0.06
                )

            Circle()
                .fill(Color("Primary").opacity(0.3))
                .frame(width: W * 1.15, height: W * 1.15)
                .position(
                    x: W * 1.15 / 2 + W * 0.48,
                    y: W * 1.15 / 2 + W * 0.24
                )

            VisualEffectBlur(blurStyle: .systemThinMaterial)
                .ignoresSafeArea()
        }
        .frame(width: W, height: H)
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    Background()
}
