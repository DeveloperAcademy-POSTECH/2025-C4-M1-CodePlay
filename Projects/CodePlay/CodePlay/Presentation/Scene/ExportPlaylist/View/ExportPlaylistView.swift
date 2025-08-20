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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    let selectedArtists: [String]
    let playlist: Playlist

    init(selectedArtists: [String], playlist: Playlist) {
        self.selectedArtists = selectedArtists
        self.playlist = playlist
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            
            if colorScheme == .light {
                GIFImage(gifName: "ArtistLoadLight", width: 320, height: 320)
                    .scaledToFit()
                    .frame(width: 320, height: 320)
            } else {
                GIFImage(gifName: "ArtistLoadDark", width: 320, height: 320)
                    .scaledToFit()
                    .frame(width: 320, height: 320)
            }

            GradientProgressBar(progress: Double(wrapper.progressStep) / 3.0)
                .padding(.bottom, 60)
            
            VStack(spacing: 12) {
                Text("라인업의 아티스트별\n인기곡을 가져오는 중...")
                    .multilineTextAlignment(.center)
                    .font(.HlgBold())
                    .foregroundColor(.neu900)
                    .lineSpacing(4)
                
                Text("잠시만 기다려 주세요")
                    .font(.BlgRegular())
                    .foregroundColor(.neu700)
                    .lineSpacing(4)
            }

            Spacer()

            NavigationLink(
                destination: MadePlaylistView(playlist: playlist), // 생성 완료 후 이동
                isActive: $wrapper.navigateToMadePlaylist
            ) {
                EmptyView()
            }
            .hidden()
        }
        .backgroundWithBlur()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                let rawText = RawText(text: selectedArtists.joined(separator: ", "))
                await wrapper.onAppear(with: rawText, for: playlist, using: modelContext)
            }
        }
    }
}
