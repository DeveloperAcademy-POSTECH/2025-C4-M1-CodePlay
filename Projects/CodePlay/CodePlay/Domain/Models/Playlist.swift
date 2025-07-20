//
//  Playlist.swift
//  CodePlay
//
//  Created by 성현 on 7/19/25.
//

import SwiftData
import Foundation

@Model
final class Playlist {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var entries: [PlaylistEntry] = []

    init(id: UUID = UUID(), title: String, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}

