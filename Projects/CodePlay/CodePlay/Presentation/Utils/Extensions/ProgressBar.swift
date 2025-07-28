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
                    .frame(height: 6)
                    .foregroundColor(Color.gray.opacity(0.2))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color("Secondary"), Color("Primary")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(progress), height: 6)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, 16)
    }
}

struct GradientProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        GradientProgressBar(progress: 1.0)
    }
}
