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
                .font(.BlgBold())
                .foregroundColor(.neu900)
        ) {
            ForEach(entries) { entry in
                CustomList(
                    imageUrl: entry.albumArtworkUrl ?? "",
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
        wrapper.deletePlaylistEntry(trackId: entry.trackId)
    }
}
