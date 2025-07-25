//
//  ExportLoadingView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/21/25.
//

import SwiftUI

// MARK: 애플뮤직 플레이리스트로 전송하는 뷰 (hifi 06_1부분)
struct ExportLoadingView: View {
    @State private var progress: Double = 0.0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            GIFImage(gifName: "PlaylistLoadLight", width: 360, height: 400)
                .frame(width: 360, height: 400)
            
            Text("Apple Music으로 전송 중...")
                .font(.title3)

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 5)) {
                progress = 1.0
            }
        }
    }
}

#Preview {
    ExportLoadingView()
}
