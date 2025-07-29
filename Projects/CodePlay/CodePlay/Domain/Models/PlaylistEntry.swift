//
//  PlaylistEntry.swift
//  CodePlay
//
//  Created by 성현 on 7/19/25.
//

import Foundation
import SwiftData

@Model
final class PlaylistEntry {
    @Attribute(.unique) var id: UUID
    var playlistId: UUID
    var artistMatchId: UUID
    var artistName: String
    var appleMusicId: String
    var trackTitle: String
    var trackId: String
    var trackPreviewUrl: String
    var profileArtworkUrl: String
    var albumArtworkUrl: String
    var albumName: String
    var createdAt: Date
    @Relationship var playlist: Playlist? 

    init(
        id: UUID = UUID(),
        playlistId: UUID,
        artistMatchId: UUID,
        artistName: String,
        appleMusicId: String,
        trackTitle: String,
        trackId: String,
        trackPreviewUrl: String,
        profileArtworkUrl: String,
        albumArtworkUrl: String,
        albumName: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.playlistId = playlistId
        self.artistMatchId = artistMatchId
        self.artistName = artistName
        self.appleMusicId = appleMusicId
        self.trackTitle = trackTitle
        self.trackId = trackId
        self.trackPreviewUrl = trackPreviewUrl
        self.profileArtworkUrl = profileArtworkUrl
        self.albumArtworkUrl = albumArtworkUrl
        self.albumName = albumName
        self.createdAt = createdAt
    }
}
