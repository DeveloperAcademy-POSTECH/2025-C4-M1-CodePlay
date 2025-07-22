//
//  SwiftUIView.swift
//  CodePlay
//
//  Created by 성현 on 7/19/25.
//

import SwiftUI

struct MadePlaylistView: View {
    @EnvironmentObject var wrapper: MusicViewModelWrapper

    var body: some View {
        // 플레이리스트 영역
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(wrapper.playlistEntries, id: \.id) { entry in
                    CustomList(
                        imageUrl: entry.albumArtworkUrl,
                        title: entry.trackTitle,
                        artist: entry.artistName,
                        trackId: entry.trackId,
                        isCurrentlyPlaying: wrapper.currentlyPlayingTrackId == entry.trackId,
                        isPlaying: wrapper.isPlaying,
                        onAlbumCoverTap: {
                            wrapper.togglePreview(for: entry.trackId)
                        }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let index = wrapper.playlistEntries.firstIndex(where: { $0.id == entry.id }) {
                                wrapper.deleteEntry(at: IndexSet(integer: index))
                            }
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
                .onDelete { indexSet in
                    wrapper.deleteEntry(at: indexSet)
                }
            }
        }

        Spacer()
        
        // Apple Music 내보내기 버튼
        BottomButton(title: "Apple Music으로 전송") {
            wrapper.exportToAppleMusic()
        }
        .padding(.horizontal, 16)// Home Indicator 공간
        
        .background(Color.white)
        .navigationTitle("플레이리스트")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // 뒤로가기 액션
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
        .background(
            NavigationLink(destination: ExportLoadingView(), isActive: $wrapper.isExporting) {
                EmptyView()
            }
        )
        .fullScreenCover(isPresented: $wrapper.isExportCompleted) {
            ExportSuccessView()
        }
    }
}


