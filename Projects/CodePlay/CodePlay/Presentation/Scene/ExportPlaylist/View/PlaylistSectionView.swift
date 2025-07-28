//
//  PlaylistEntryRow.swift
//  CodePlay
//
//  Created by 성현 on 7/24/25.
//

import SwiftUI

struct PlaylistSectionView: View {
    let artist: String
    let entries: [PlaylistEntry]
    @ObservedObject var wrapper: MusicViewModelWrapper
    
    // 삭제 확인 모달 상태 관리
    @State private var showDeleteAlert = false
    @State private var entryToDelete: PlaylistEntry?

    var body: some View {
        Section(header:
            Text(artist)
                .font(.title3)
                .bold()
        ) {
            ForEach(entries) { entry in
                CustomList(
                    imageUrl: entry.albumArtworkUrl,
                    title: entry.trackTitle,
                    albumName: entry.albumName,
                    trackId: entry.trackId,
                    isCurrentlyPlaying: wrapper.currentlyPlayingTrackId == entry.trackId,
                    isPlaying: wrapper.isPlaying,
                    playbackProgress: wrapper.playbackProgress,
                    onAlbumCoverTap: {
                        wrapper.togglePreview(for: entry.trackId)
                    },
                    onDeleteTap: {
                        // 삭제할 항목 저장하고 Alert 표시
                        entryToDelete = entry
                        showDeleteAlert = true
                    }
                )
            }
        }
        .alert("삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("아니요", role: .cancel) {
                entryToDelete = nil
            }
            Button("삭제", role: .destructive) {
                if let entry = entryToDelete {
                    deleteEntry(entry)
                }
                entryToDelete = nil
            }
        } 
    }
    
    // MARK: - Private Methods
    private func deleteEntry(_ entry: PlaylistEntry) {
        // TODO: MusicViewModelWrapper에 삭제 메서드 구현 후 호출
        print("삭제 실행: \(entry.trackTitle)")
        
        // 현재 재생 중인 곡이면 정지
        if wrapper.currentlyPlayingTrackId == entry.trackId {
            // TODO: wrapper.stopPreview() 구현 후 호출
            print("재생 중인 곡 정지: \(entry.trackTitle)")
        }
        
        // TODO: wrapper.deletePlaylistEntry(trackId: entry.trackId) 호출
    }
}

// MARK: - Preview
//#Preview {
//    // Mock data for preview
//    let mockEntries = [
//        PlaylistEntry(
//            trackId: "1",
//            trackTitle: "360",
//            albumName: "BRAT",
//            artistName: "Charli xcx",
//            albumArtworkUrl: ""
//        ),
//        PlaylistEntry(
//            trackId: "2", 
//            trackTitle: "Apple",
//            albumName: "BRAT",
//            artistName: "Charli xcx",
//            albumArtworkUrl: ""
//        )
//    ]
//    
//    // Mock wrapper
//    class MockMusicViewModelWrapper: MusicViewModelWrapper {
//        override init() {
//            super.init()
//        }
//    }
//    
//    NavigationView {
//        List {
//            PlaylistSectionView(
//                artist: "Charli xcx",
//                entries: mockEntries,
//                wrapper: MockMusicViewModelWrapper()
//            )
//        }
//    }
//}
//
