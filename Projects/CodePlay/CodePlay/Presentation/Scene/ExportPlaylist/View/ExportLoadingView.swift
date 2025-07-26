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
        VStack(spacing: 12) {
            Spacer()
            
            Image("SendMusic")
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 320)
            
            Spacer(minLength: 0)
            
            //            ProgressView(value: progress)
            //                .progressViewStyle(.linear)
            //                .padding(.horizontal, 32)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경
                    Capsule()
                        .frame(height: 6)
                        .foregroundColor(Color.gray.opacity(0.2))
                    
                    // 그라디언트 프로그래스
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
            .padding(.horizontal, 48)
            
            Text("Apple Music으로\n플레이리스트를 보내는 중...")
                .font(.HlgBold())
                .multilineTextAlignment(.center)
                .foregroundColor(.neutral900)
            
            //            Spacer().frame(height: 5)
            
            Text("잠시만 기다려 주세요")
                .font(.BmdRegular())
                .foregroundColor(.neutral700)
    
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
