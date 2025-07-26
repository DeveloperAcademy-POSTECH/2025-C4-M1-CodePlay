//
//  ExportPlaylistView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
internal import Combine
import MusicKit


// MARK: 아티스트별 인기곡을 가져오는 뷰 (hifi 04_1부분)
struct ExportPlaylistView: View {
    @EnvironmentObject var wrapper: MusicViewModelWrapper
    @State private var progress : Double = 0.0
    let rawText: RawText?

    init(rawText: RawText?) {
        self.rawText = rawText
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            
            GIFImage(gifName: "ArtistLoadLight", width: 280, height: 280)
                            .frame(width: 280, height: 280)
            
            
            GradientProgressBar(progress: progress)
            
            
            Text("아티스트 라인업을 통해\n플레이리스트를 만드는 중...")
                .multilineTextAlignment(.center)
                .font(.HlgBold())
                .foregroundColor(.neutral900)
            
            Spacer().frame(height : 12)
            
            Text("잠시만 기다려 주세요")
                .font(.BmdRegular())
                .foregroundColor(.neutral700)

            Spacer()

            NavigationLink(
                destination: MadePlaylistView(), // 생성 완료 후 이동
                isActive: $wrapper.navigateToMadePlaylist
            ) {
                EmptyView()
            }
        }
        .backgroundWithBlur()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            wrapper.onAppear(with: rawText)
        }
    }

//    private func progressMessage(for step: Int) -> String {
//        switch step {
//        case 0: return "🎬 준비 중..."
//        case 1: return "🔍 아티스트 검색 중..."
//        case 2: return "🎶 인기곡 가져오는 중..."
//        case 3: return "✅ 완료!"
//        default: return ""
//        }
//    }
}
