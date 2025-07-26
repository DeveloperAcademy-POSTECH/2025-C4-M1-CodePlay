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
    let rawText: RawText?

    init(rawText: RawText?) {
        self.rawText = rawText
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            
            GIFImage(gifName: "ArtistLoadLight", width: 320, height: 320)
                            .frame(width: 320, height: 320)
            
            
            GradientProgressBar(progress: Double(wrapper.progressStep) / 3.0)
                .padding(.bottom, 60)
            
            VStack(spacing: 4) {
                Text("라인업의 아티스트별\n인기곡을 가져오는 중...")
                    .multilineTextAlignment(.center)
                    .font(.HlgBold())
                    .foregroundColor(.neu900)
                
                Text("잠시만 기다려 주세요")
                    .font(.BlgRegular())
                    .foregroundColor(.neu700)
            }

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

}
