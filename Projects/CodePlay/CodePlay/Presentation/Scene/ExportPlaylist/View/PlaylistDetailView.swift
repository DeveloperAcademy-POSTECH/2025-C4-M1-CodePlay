//
//  PlaylistDetailView.swift
//  CodePlay
//
//  Created by 성현 on 7/29/25.
//

import SwiftUI
import SwiftData

struct PlaylistDetailView: View {
    let playlist: Playlist
    @EnvironmentObject var wrapper: MusicViewModelWrapper
    @Query var allEntries: [PlaylistEntry]

    var body: some View {
        let entries = allEntries.filter { $0.playlistId == playlist.id }
        let groupedEntries = Dictionary(grouping: entries, by: { $0.artistName })

        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(groupedEntries.keys.sorted(), id: \.self) { artist in
                        PlaylistSectionView(artist: artist, entries: groupedEntries[artist] ?? [], wrapper: wrapper)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 80)
            }

            Text("총 \(entries.count)곡")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .navigationTitle(playlist.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
