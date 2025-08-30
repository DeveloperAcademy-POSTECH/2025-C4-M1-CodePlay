//
//  CoachMarkView.swift
//  CodePlay
//
//  Created by 광로 on 8/29/25.
//

import SwiftUI
import Lottie

struct CoachMarkView: View {
    @Binding var isPresented: Bool
    var onCompleted: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                GeometryReader { geometry in
                    LottieView(animation: .named("drag"))
                        .looping()
                        .frame(width: geometry.size.width * 1.15, height: geometry.size.width * 1.15)
                        .clipped()
                }
                .frame(height: UIScreen.main.bounds.width)
                .padding(.horizontal, 0)
                
                Text("화면을 드래그하여 \n영역을 지정해 보세요!")
                    .font(.HlgBold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .lineSpacing(2)
                
                Spacer().frame(height: 20)
                
                Button(action: {
                    onCompleted?()
                }) {
                    Text("이해했어요")
                        .font(.BlgBold())
                        .foregroundColor(.neu900)
                        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                        .frame(height: 60)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 999))
                }
                .padding(.horizontal, 120)
                Spacer().frame(height: 165)
            }
        }
    }
}

#Preview {
    CoachMarkView(isPresented: .constant(true))
}
