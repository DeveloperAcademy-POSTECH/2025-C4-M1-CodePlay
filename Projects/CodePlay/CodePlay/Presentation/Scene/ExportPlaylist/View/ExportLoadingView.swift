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
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 146)
            
            if colorScheme == .light {
                GIFImage(gifName: "PlaylistLoadLight", width: 320, height: 320)
                    .scaledToFit()
                    .frame(width: 320, height: 320)
            } else {
                GIFImage(gifName: "PlaylistLoadDark", width: 320, height: 320)
                    .scaledToFit()
                    .frame(width: 320, height: 320)
            }
            
            GradientProgressBar(progress: progress)
                .padding(.bottom, 60)
            
            VStack(spacing: 12) {
                Text("Apple Music으로\n플레이리스트를 보내는 중...")
                    .font(.HlgBold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.neu900)
                
                Text("잠시만 기다려 주세요")
                    .font(.BmdRegular())
                    .foregroundColor(.neu700)
            }
            .frame(maxWidth: 321)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 5)) {
                progress = 1.0
            }
        }
        .backgroundWithBlur()
    }
}


#Preview {
    ExportLoadingView()
}
