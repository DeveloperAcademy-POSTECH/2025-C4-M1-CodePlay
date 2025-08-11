//
//  ProgressBar.swift
//  CodePlay
//
//  Created by 광로 on 7/26/25.
//

import SwiftUI

struct GradientProgressBar: View {
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 8)
                    .foregroundColor(Color.gray.opacity(0.2))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(asset: Asset.secondary), Color(asset: Asset.primary)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(progress), height: 8)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 48)
    }
}

struct GradientProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        GradientProgressBar(progress: 1.0)
    }
}
