//
//  FestivalNoneView.swift
//  CodePlay
//
//  Created by 서연 on 7/29/25.
//

import MusicKit
import SwiftData
import SwiftUI

struct FestivalNoneView: View {
    @EnvironmentObject var wrapper: PosterViewModelWrapper
    @Environment(\.dismiss) private var dismiss
    @State private var recognizedText = ""
    @State private var isPresented = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .center) {
                Spacer().frame(height: 8)

                Text("페스티벌 인식에 실패했습니다")
                    .font(.HlgBold())
                    .foregroundColor(Color.neu900)
                    .lineSpacing(2)

                Spacer().frame(height: 6)

                Text("페스티벌 라인업 포스터를 다시 촬영해 주세요")
                    .font(.BmdRegular())
                    .foregroundColor(Color.neu700)
                    .lineSpacing(2)

                Spacer().frame(height: 36)

                Image("Festivalfail")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 36.5)
                    .frame(maxWidth: .infinity, maxHeight: 320)

                Spacer()

                BottomButton(title: "다시 촬영하기", kind: .line) {
                    wrapper.shouldNavigateToFestivalCheck = false
                    wrapper.scannedText = nil
                    recognizedText = ""
                    isPresented = true
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
            }
        }
        .backgroundWithBlur()
        .edgesIgnoringSafeArea(.bottom)
        .fullScreenCover(isPresented: $isPresented) {
            CameraLiveTextView(
                recognizedText: $recognizedText,
                isPresented: $isPresented,
                shouldAutoNavigate: false
            )
            .ignoresSafeArea()
            .environmentObject(wrapper)
        }
        .onChange(of: recognizedText) { newText in
                    // 텍스트가 인식되면 수동으로 FestivalCheckView로 이동
                    if !newText.isEmpty && !isPresented {
                        wrapper.shouldNavigateToFestivalCheck = true
                        dismiss()
                    }
                }
    }
}

#Preview {
    FestivalNoneView()
}
