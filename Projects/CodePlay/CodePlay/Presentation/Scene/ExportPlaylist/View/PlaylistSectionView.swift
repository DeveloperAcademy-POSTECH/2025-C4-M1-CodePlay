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

    var body: some View {
        Section(header:
            Text(artist)
                .font(.BlgBold())
                .foregroundColor(.neu900)
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
                    }
                )
            }
        }
    }
}

