//
//  ArtistMatch.swift
//  CodePlay
//
//  Created by 성현 on 7/19/25.
//

import Foundation

struct ArtistMatch: Identifiable, Equatable, Hashable {
    let id: UUID
    let rawText: String
    let artistName: String
    let appleMusicId: String
    let profileArtworkUrl: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        rawText: String,
        artistName: String,
        appleMusicId: String,
        profileArtworkUrl: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.rawText = rawText
        self.artistName = artistName
        self.appleMusicId = appleMusicId
        self.profileArtworkUrl = profileArtworkUrl
        self.createdAt = createdAt
    }
}
