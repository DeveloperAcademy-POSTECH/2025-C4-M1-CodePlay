//
//  EmptyView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/22/25.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("아직 인식한 페스티벌 라인업이 없습니다.")
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: 420)
        .padding(.horizontal, 72)
        .liquidGlass()
    }
}

#Preview {
    EmptyView()
}
